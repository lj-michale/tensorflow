/* Copyright 2023 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#ifndef TENSORFLOW_COMPILER_XLA_PJRT_ABSTRACT_TFRT_CPU_BUFFER_H_
#define TENSORFLOW_COMPILER_XLA_PJRT_ABSTRACT_TFRT_CPU_BUFFER_H_

#include <cstddef>
#include <cstdint>
#include <memory>
#include <string>
#include <utility>
#include <vector>

#include "absl/base/thread_annotations.h"
#include "absl/log/check.h"
#include "absl/synchronization/mutex.h"
#include "tensorflow/compiler/xla/pjrt/pjrt_client.h"
#include "tensorflow/compiler/xla/pjrt/pjrt_future.h"
#include "tensorflow/compiler/xla/pjrt/tracked_tfrt_cpu_device_buffer.h"
#include "tensorflow/compiler/xla/runtime/cpu_event.h"
#include "tensorflow/compiler/xla/shape.h"
#include "tensorflow/compiler/xla/status.h"
#include "tensorflow/compiler/xla/statusor.h"
#include "tensorflow/compiler/xla/util.h"
#include "tfrt/host_context/async_value_ref.h"  // from @tf_runtime

namespace xla {

void CopyCpuBufferToLiteral(const Shape& device_shape,
                            TrackedTfrtCpuDeviceBuffer* device_buffer,
                            MutableLiteralBase* literal);

// A RAII helper class used to set an AsyncValueRef<CpuEvent> to a ready state
// upon destruction. In many cases in PjRt implementation, there will be
// multiple return statements in the function, all of which require setting some
// AsyncValueRef<CpuEvent> to be ready. This class could make such code more
// robust by using setting the AsyncValue in the destructor.
class MarkEventReadyOnExit {
 public:
  explicit MarkEventReadyOnExit(tfrt::AsyncValueRef<runtime::CpuEvent> event)
      : event_(std::move(event)) {}

  MarkEventReadyOnExit(const MarkEventReadyOnExit&) = delete;
  MarkEventReadyOnExit& operator=(const MarkEventReadyOnExit&) = delete;
  MarkEventReadyOnExit(MarkEventReadyOnExit&&) = default;
  MarkEventReadyOnExit& operator=(MarkEventReadyOnExit&&) = default;

  ~MarkEventReadyOnExit() {
    if (event_) event_.SetStateConcrete();
  }

  tfrt::AsyncValueRef<runtime::CpuEvent> Release() && {
    return std::move(event_);
  }

 private:
  tfrt::AsyncValueRef<runtime::CpuEvent> event_;
};

class AbstractTfrtCpuBuffer : public PjRtBuffer {
 public:
  AbstractTfrtCpuBuffer(
      Shape on_device_shape,
      std::unique_ptr<TrackedTfrtCpuDeviceBuffer> tracked_device_buffer);
  ~AbstractTfrtCpuBuffer() override;

  const Shape& on_device_shape() const override { return on_device_shape_; }

  StatusOr<std::unique_ptr<ExternalReference>> AcquireExternalReference()
      override;

  StatusOr<std::unique_ptr<ExternalReference>> ReleaseDeviceMemoryOwnership(
      bool wait_for_operations_to_complete) override;

  StatusOr<size_t> GetOnDeviceSizeInBytes() const override;

  PjRtFuture<Status> CopyRawToHost(void* dst, int64_t offset,
                                   int64_t transfer_size) override {
    return PjRtFuture<Status>(Unimplemented("CopyRawToHost not implemented"));
  }

  void Delete() override;

  bool IsDeleted() override;

  void CopyToRemoteDevice(
      PjRtFuture<StatusOr<std::string>> serialized_descriptor,
      RemoteSendCallback on_done) override {
    on_done(Unimplemented("CopyToRemoteDevice not implemented."),
            /*sends_were_enqueued=*/false);
  }

  void CopyToRemoteDeviceScattered(
      PjRtFuture<StatusOr<std::vector<std::string>>> serialized_descriptors,
      std::vector<RemoteSendCallback> callbacks,
      const xla::PjRtBuffer::ScatterDetails& scatter_details) override {
    for (const auto& on_done : callbacks) {
      on_done(Unimplemented("Implement CopyToRemoteDeviceScattered."),
              /*sends_were_enqueued=*/false);
    }
  }

  PjRtFuture<Status> GetReadyFuture() override;

  bool IsOnCpu() const override { return true; }

  // Acquires the device buffer for shared read-only usages, and it also adds
  // the `usage_event` to it. Any donation event in the future is expected to be
  // serialized after all the usage events added through this method. Returns
  // nullptr if the buffer is already donated or there is outstanding external
  // references.
  TrackedTfrtCpuDeviceBuffer* AcquireUsage(
      tfrt::AsyncValueRef<runtime::CpuEvent> usage_event);

  // A helper class for managing a pending donation. It should be committed upon
  // success. Otherwise, the donated buffer is returned to the
  // AbstractTfrtCpuBuffer.
  class DonationTransaction {
   public:
    explicit DonationTransaction(
        AbstractTfrtCpuBuffer* buffer,
        std::unique_ptr<TrackedTfrtCpuDeviceBuffer> device_buffer)
        : buffer_(buffer), device_buffer_(std::move(device_buffer)) {
      CHECK(buffer_);
    }
    DonationTransaction(const DonationTransaction&) = delete;
    DonationTransaction& operator=(const DonationTransaction&) = delete;
    DonationTransaction(DonationTransaction&&) = default;
    DonationTransaction& operator=(DonationTransaction&& other) {
      Abort();

      buffer_ = other.buffer_;
      device_buffer_ = std::move(other.device_buffer_);
      return *this;
    }

    ~DonationTransaction() { Abort(); }

    // Commit the donation. The rvalue ref qualifier is used to ensure the
    // semantic that it can be committed at most once.
    void Commit() && {
      buffer_->CommitDonation();
      device_buffer_.reset();
    }

    TrackedTfrtCpuDeviceBuffer* device_buffer() const {
      return device_buffer_.get();
    }

   private:
    void Abort() {
      if (device_buffer_) buffer_->AbortDonation(std::move(device_buffer_));
    }

    AbstractTfrtCpuBuffer* buffer_ = nullptr;
    std::unique_ptr<TrackedTfrtCpuDeviceBuffer> device_buffer_;
  };

  // Acquires the device buffer for exclusive donation. The caller of this
  // method is expected to use the usage events and definition events to
  // serialize this donation with previous usages. After this method is called,
  // calls to AcquireUsage() will fail. Returns error status if the buffer is
  // already donated or there is outstanding external references.
  StatusOr<DonationTransaction> AcquireDonation();

 protected:
  virtual absl::string_view buffer_name() const = 0;

  bool IsEmptyTuple() const {
    return on_device_shape_.IsTuple() &&
           on_device_shape_.tuple_shapes_size() == 0;
  }

  void DropExternalReference() {
    absl::MutexLock lock(&mu_);
    CHECK_GT(external_reference_counter_, 0);
    --external_reference_counter_;
  }

  // Commits the pending donation by setting `pending_donation_` to false.
  // `pending_donation_` must be true before calling this method.
  void CommitDonation();

  // Aborts the pending donation by returning the donated buffer, and setting
  // `pending_donation_` to false. `pending_donation_` must be true before
  // calling this method.
  void AbortDonation(std::unique_ptr<TrackedTfrtCpuDeviceBuffer> device_buffer);

  // Similar to Delete, drops the buffer's reference to its associated device
  // memory, leaving the buffer in an invalid state, but returns the
  // TrackedTfrtCpuDeviceBuffer rather than freeing the device memory, so that
  // another framework can take ownership of it. The buffer returned from
  // Release may be safely dropped at any time even if it still has pending
  // async operations. The client should call Await before calling Release with
  // wait_for_operations_to_complete=false, to ensure that the host has
  // synchronized past any outstanding write operations to the buffer. If
  // wait_for_operations_to_complete=true the host will block until any
  // potentially outstanding asynchronous operations have completed before
  // returning, in which case it is safe to read or mutate the returned buffer.
  // If the buffer was shared via an external reference it is the client's
  // responsibility that accesses via that reference do not interfere with
  // accesses via the buffer returned from Release.
  StatusOr<std::unique_ptr<TrackedTfrtCpuDeviceBuffer>> Release(
      bool wait_for_operations_to_complete);

  // Releases the device buffer by returning a unique_ptr of it. If there is
  // outstanding donation or usage holds, this method blocks until those holds
  // are committed or dropped.
  std::unique_ptr<TrackedTfrtCpuDeviceBuffer> ReleaseBufferLocked()
      ABSL_LOCKS_EXCLUDED(mu_);

  const Shape on_device_shape_;

  mutable absl::Mutex mu_;
  std::unique_ptr<TrackedTfrtCpuDeviceBuffer> tracked_device_buffer_
      ABSL_GUARDED_BY(mu_);
  // Count of external references on the buffer.
  int external_reference_counter_ ABSL_GUARDED_BY(mu_) = 0;
  // `pending_donation_` indicates whether a donation is pending. The destructor
  // of the AbstractTfrtCpuBuffer will wait for a pending donation, as the
  // donation might fail. Note that concurrent calls to AcquireUsage() and
  // AcquireDonation() might fail even if the pending donation is aborted later.
  bool pending_donation_ ABSL_GUARDED_BY(mu_) = false;
};

}  // namespace xla

#endif  // TENSORFLOW_COMPILER_XLA_PJRT_ABSTRACT_TFRT_CPU_BUFFER_H_
