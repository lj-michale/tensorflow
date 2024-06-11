/* Copyright 2024 The OpenXLA Authors.

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

#include "xla/service/cpu/runtime/thunk.h"

#include "tsl/platform/test.h"

namespace xla::cpu {
namespace {

TEST(ThunkTest, CompletionEvent) {
  auto event = Thunk::ReadyCompletionEvent();
  ASSERT_TRUE(event.IsAvailable());
  ASSERT_EQ(event->num_tasks, 1);
}

}  // namespace
}  // namespace xla::cpu
