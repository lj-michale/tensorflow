// RUN: flatbuffer_translate -mlir-to-tflite-flatbuffer %s -o - | flatbuffer_translate --tflite-flatbuffer-to-mlir - -o - | FileCheck %s
// Ensure lstm roundtrip exactly

func.func @main(%arg0: tensor<1x4xf32>, %arg1: tensor<4x4xf32>, %arg2: tensor<4x4xf32>, %arg3: tensor<4x4xf32>, %arg4: tensor<4x4xf32>, %arg5: tensor<4x4xf32>, %arg6: tensor<4x4xf32>, %arg7: tensor<4x4xf32>, %arg8: tensor<4x4xf32>, %arg9: tensor<4xf32>, %arg10: tensor<4xf32>, %arg11: tensor<4xf32>, %arg12: tensor<1x4xf32>, %arg13: tensor<4xf32>, %arg14: tensor<4xf32>, %arg15: tensor<4xf32>, %arg16: tensor<4x4xf32>, %arg17: tensor<4xf32>, %arg18: tensor<4xf32>, %arg19: tensor<4xf32>, %arg20: tensor<4xf32>, %arg21: tensor<4xf32>) -> tensor<1x4xf32> {
  %cst0 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %cst1 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %24 = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %cst0, %cst1, %arg18, %arg19, %arg20, %arg21) ({}) {cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32} : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
  func.return %24 : tensor<1x4xf32>
// CHECK-LABEL: main
// separate lines since there is no region for this op. third_party/tensorflow/compiler/mlir/lite/ir/tfl_ops.td: 3252
// CHECK-DAG: %[[RES0:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK-DAG: %[[RES1:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK: %[[RES2:.*]] = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %[[RES0]], %[[RES1]], %arg18, %arg19, %arg20, %arg21)
// CHECK-SAME: <{asymmetric_quantize_inputs = false, cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32}> ({
// CHECK: }) : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
// CHECK: return %[[RES2]]

}

// -----

func.func @testFullyQuantizedLSTM(%arg0: tensor<1x528x!quant.uniform<i8:f32, 0.037248000502586365:-19>>, %arg1: tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.059801999479532242>>, %arg2: tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.031925998628139496>>, %arg3: tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.056272000074386597>>, %arg4: tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.063763998448848724>>, %arg5: tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.013358999975025654>>, %arg6: tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.022830000147223473>>, %arg7: tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.032276000827550888>>, %arg8: tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.035427000373601913>>, %arg9: tensor<2048x!quant.uniform<i32:f32, 4.2675782196965883E-7>>, %arg10: tensor<2048x!quant.uniform<i32:f32, 1.0742187583900886E-7>>, %arg11: tensor<2048x!quant.uniform<i32:f32, 1.6406249869760359E-7>>, %arg12: tensor<2048x!quant.uniform<i32:f32, 1.523437447303877E-7>>, %arg13: tensor<640x2048x!quant.uniform<i8<-127:127>:f32, 0.021174000576138496>>, %arg14: tensor<640x!quant.uniform<i32:f32, 1.601389680352559E-4>>, %arg15: tensor<2048x!quant.uniform<i16:f32, 4.3700000969693065E-4>>, %arg16: tensor<2048x!quant.uniform<i16:f32, 1.1000000085914508E-4>>, %arg17: tensor<2048x!quant.uniform<i16:f32, 1.6799999866634607E-4>>, %arg18: tensor<2048x!quant.uniform<i16:f32, 1.55999994603917E-4>>, %arg19: tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>>, %arg20: tensor<1x2048x!quant.uniform<i16:f32, 4.8799999058246613E-4>>) -> tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>> {
    %cst = "tfl.no_value"() {value = unit} : () -> none
    %0 = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %cst, %cst, %cst, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg19, %arg20, %arg15, %arg16, %arg17, %arg18) ({}) {cell_clip = 1.000000e+01 : f32, fused_activation_function = "TANH", input_to_input_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0049890000373125076>>, input_to_forget_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0078849997371435165>>, input_to_cell_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0087630003690719604>>, input_to_output_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0057529998011887074>>, effective_hidden_scale_intermediate = tensor<0x!quant.uniform<i8:f32, 0.0075630000792443752:2>>, kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.01 : f32} : (tensor<1x528x!quant.uniform<i8:f32, 0.037248000502586365:-19>>, tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.059801999479532242>>, tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.031925998628139496>>, tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.056272000074386597>>, tensor<2048x528x!quant.uniform<i8<-127:127>:f32, 0.063763998448848724>>, tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.013358999975025654>>, tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.022830000147223473>>, tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.032276000827550888>>, tensor<2048x640x!quant.uniform<i8<-127:127>:f32, 0.035427000373601913>>, none, none, none, tensor<2048x!quant.uniform<i32:f32, 4.2675782196965883E-7>>, tensor<2048x!quant.uniform<i32:f32, 1.0742187583900886E-7>>, tensor<2048x!quant.uniform<i32:f32, 1.6406249869760359E-7>>, tensor<2048x!quant.uniform<i32:f32, 1.523437447303877E-7>>, tensor<640x2048x!quant.uniform<i8<-127:127>:f32, 0.021174000576138496>>, tensor<640x!quant.uniform<i32:f32, 1.601389680352559E-4>>, tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>>, tensor<1x2048x!quant.uniform<i16:f32, 4.8799999058246613E-4>>, tensor<2048x!quant.uniform<i16:f32, 4.3700000969693065E-4>>, tensor<2048x!quant.uniform<i16:f32, 1.1000000085914508E-4>>, tensor<2048x!quant.uniform<i16:f32, 1.6799999866634607E-4>>, tensor<2048x!quant.uniform<i16:f32, 1.55999994603917E-4>>) -> tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>>
    func.return %0 : tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>>
// CHECK-LABEL: testFullyQuantizedLSTM
// CHECK: %[[CST:.*]] = "tfl.no_value"() <{value}> : () -> none
// CHECK: %[[RES0:.*]] = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %[[CST]], %[[CST]], %[[CST]], %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg19, %arg20, %arg15, %arg16, %arg17, %arg18)
// CHECK-SAME: <{asymmetric_quantize_inputs = false, cell_clip = 1.000000e+01 : f32, effective_hidden_scale_intermediate = tensor<0x!quant.uniform<i8:f32, 0.0075630000792443752:2>>, fused_activation_function = "TANH", input_to_cell_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0087630003690719604>>, input_to_forget_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0078849997371435165>>, input_to_input_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0049890000373125076>>, input_to_output_intermediate = tensor<0x!quant.uniform<i16:f32, 0.0057529998011887074>>, kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.00999999977 : f32}> ({
// CHECK: }) : (tensor<1x528x!quant.uniform<i8:f32, 0.037248000502586365:-19>>, tensor<2048x528x!quant.uniform<i8:f32, 0.059801999479532242>>, tensor<2048x528x!quant.uniform<i8:f32, 0.031925998628139496>>, tensor<2048x528x!quant.uniform<i8:f32, 0.056272000074386597>>, tensor<2048x528x!quant.uniform<i8:f32, 0.063763998448848724>>, tensor<2048x640x!quant.uniform<i8:f32, 0.013358999975025654>>, tensor<2048x640x!quant.uniform<i8:f32, 0.022830000147223473>>, tensor<2048x640x!quant.uniform<i8:f32, 0.032276000827550888>>, tensor<2048x640x!quant.uniform<i8:f32, 0.035427000373601913>>, none, none, none, tensor<2048x!quant.uniform<i32:f32, 4.2675782196965883E-7>>, tensor<2048x!quant.uniform<i32:f32, 1.0742187583900886E-7>>, tensor<2048x!quant.uniform<i32:f32, 1.6406249869760359E-7>>, tensor<2048x!quant.uniform<i32:f32, 1.523437447303877E-7>>, tensor<640x2048x!quant.uniform<i8:f32, 0.021174000576138496>>, tensor<640x!quant.uniform<i32:f32, 1.6013896674849093E-4>>, tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>>, tensor<1x2048x!quant.uniform<i16:f32, 4.8799999058246613E-4>>, tensor<2048x!quant.uniform<i16:f32, 4.3700000969693065E-4>>, tensor<2048x!quant.uniform<i16:f32, 1.1000000085914508E-4>>, tensor<2048x!quant.uniform<i16:f32, 1.6799999866634607E-4>>, tensor<2048x!quant.uniform<i16:f32, 1.55999994603917E-4>>) -> tensor<1x640x!quant.uniform<i8:f32, 0.09671100229024887:10>>
}

// -----

// CHECK-LABEL: testUnidirectionalSequenceLstmWithIntermediates
func.func @testUnidirectionalSequenceLstmWithIntermediates(%arg0: tensor<? x ? x ? x f32>, %arg1: tensor<? x ? x f32>, %arg2: tensor<? x ? x f32>, %arg3: tensor<? x ? x f32>, %arg4: tensor<? x ? x f32>, %arg5: tensor<? x ? x f32>, %arg6: tensor<? x ? x f32>, %arg7: tensor<? x ? x f32>, %arg8: tensor<? x ? x f32>, %arg9: tensor<? x f32>, %arg10: tensor<? x f32>, %arg11: tensor<? x f32>, %arg12: tensor<? x f32>, %arg13: tensor<? x f32>, %arg14: tensor<? x f32>, %arg15: tensor<? x f32>, %arg16: tensor<? x ? x f32>, %arg17: tensor<? x f32>, %arg18: tensor<? x ? x f32>, %arg19: tensor<? x ? xf32>, %arg20: tensor<? x f32>, %arg21: tensor<? x f32>, %arg22: tensor<? x f32>, %arg23: tensor<? x f32>) -> tensor<? x ? x ? x f32> {
  // CHECK: "tfl.unidirectional_sequence_lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %arg18, %arg19, %arg20, %arg21, %arg22, %arg23) <{asymmetric_quantize_inputs = false, cell_clip = 1.000000e+01 : f32, diagonal_recurrent_tensors = false, effective_hidden_scale_intermediate = tensor<0x!quant.uniform<i8:f32, 0.0077881771139800549>>, fused_activation_function = "TANH", input_to_cell_intermediate = tensor<0xf32>, input_to_forget_intermediate = tensor<0xf32>, input_to_input_intermediate = tensor<0xf32>, input_to_output_intermediate = tensor<0xf32>, proj_clip = 0.000000e+00 : f32, time_major = false}> : (tensor<?x?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?x?xf32>, tensor<?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>) -> tensor<?x?x?xf32>
  %0 = "tfl.unidirectional_sequence_lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %arg18, %arg19, %arg20, %arg21, %arg22, %arg23) {cell_clip = 1.000000e+01 : f32, effective_hidden_scale_intermediate = tensor<0x!quant.uniform<i8:f32, 0.0077881771139800549>>, fused_activation_function = "TANH", input_to_cell_intermediate = tensor<0xf32>, input_to_forget_intermediate = tensor<0xf32>, input_to_input_intermediate = tensor<0xf32>, input_to_output_intermediate = tensor<0xf32>, proj_clip = 0.000000e+00 : f32, time_major = false} : (tensor<?x?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?x?xf32>, tensor<?xf32>, tensor<?x?xf32>, tensor<?x?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>, tensor<?xf32>) -> tensor<?x?x?xf32>
  func.return %0 : tensor<?x?x?xf32>
}

// -----

// CHECK-LABEL: testLSTMAsymAttributeTrue
func.func @testLSTMAsymAttributeTrue(%arg0: tensor<1x4xf32>, %arg1: tensor<4x4xf32>, %arg2: tensor<4x4xf32>, %arg3: tensor<4x4xf32>, %arg4: tensor<4x4xf32>, %arg5: tensor<4x4xf32>, %arg6: tensor<4x4xf32>, %arg7: tensor<4x4xf32>, %arg8: tensor<4x4xf32>, %arg9: tensor<4xf32>, %arg10: tensor<4xf32>, %arg11: tensor<4xf32>, %arg12: tensor<1x4xf32>, %arg13: tensor<4xf32>, %arg14: tensor<4xf32>, %arg15: tensor<4xf32>, %arg16: tensor<4x4xf32>, %arg17: tensor<4xf32>, %arg18: tensor<4xf32>, %arg19: tensor<4xf32>, %arg20: tensor<4xf32>, %arg21: tensor<4xf32>) -> tensor<1x4xf32> {
  %cst0 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %cst1 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %24 = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %cst0, %cst1, %arg18, %arg19, %arg20, %arg21) ({}) {asymmetric_quantize_inputs = true, cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32} : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
  func.return %24 : tensor<1x4xf32>

// CHECK-DAG: %[[RES0:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK-DAG: %[[RES1:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK: %[[RES2:.*]] = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %[[RES0]], %[[RES1]], %arg18, %arg19, %arg20, %arg21)
// CHECK-SAME: <{asymmetric_quantize_inputs = true, cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32}> ({
// CHECK: }) : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
// CHECK: return %[[RES2]]

}

// -----

// CHECK-LABEL: testLSTMAsymAttributeFalse
func.func @testLSTMAsymAttributeFalse(%arg0: tensor<1x4xf32>, %arg1: tensor<4x4xf32>, %arg2: tensor<4x4xf32>, %arg3: tensor<4x4xf32>, %arg4: tensor<4x4xf32>, %arg5: tensor<4x4xf32>, %arg6: tensor<4x4xf32>, %arg7: tensor<4x4xf32>, %arg8: tensor<4x4xf32>, %arg9: tensor<4xf32>, %arg10: tensor<4xf32>, %arg11: tensor<4xf32>, %arg12: tensor<1x4xf32>, %arg13: tensor<4xf32>, %arg14: tensor<4xf32>, %arg15: tensor<4xf32>, %arg16: tensor<4x4xf32>, %arg17: tensor<4xf32>, %arg18: tensor<4xf32>, %arg19: tensor<4xf32>, %arg20: tensor<4xf32>, %arg21: tensor<4xf32>) -> tensor<1x4xf32> {
  %cst0 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %cst1 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %24 = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %cst0, %cst1, %arg18, %arg19, %arg20, %arg21) ({}) {asymmetric_quantize_inputs = false, cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32} : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
  func.return %24 : tensor<1x4xf32>

// CHECK-DAG: %[[RES0:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK-DAG: %[[RES1:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK: %[[RES2:.*]] = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %[[RES0]], %[[RES1]], %arg18, %arg19, %arg20, %arg21)
// CHECK-SAME: <{asymmetric_quantize_inputs = false, cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32}> ({
// CHECK: }) : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
// CHECK: return %[[RES2]]

}

// -----

// CHECK-LABEL: testLSTMAsymAttributeDefault
func.func @testLSTMAsymAttributeDefault(%arg0: tensor<1x4xf32>, %arg1: tensor<4x4xf32>, %arg2: tensor<4x4xf32>, %arg3: tensor<4x4xf32>, %arg4: tensor<4x4xf32>, %arg5: tensor<4x4xf32>, %arg6: tensor<4x4xf32>, %arg7: tensor<4x4xf32>, %arg8: tensor<4x4xf32>, %arg9: tensor<4xf32>, %arg10: tensor<4xf32>, %arg11: tensor<4xf32>, %arg12: tensor<1x4xf32>, %arg13: tensor<4xf32>, %arg14: tensor<4xf32>, %arg15: tensor<4xf32>, %arg16: tensor<4x4xf32>, %arg17: tensor<4xf32>, %arg18: tensor<4xf32>, %arg19: tensor<4xf32>, %arg20: tensor<4xf32>, %arg21: tensor<4xf32>) -> tensor<1x4xf32> {
  %cst0 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %cst1 = "tfl.pseudo_const" () {value = dense<0.0> : tensor<1x4xf32>} : () -> tensor<1x4xf32> loc("Const")
  %24 = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %cst0, %cst1, %arg18, %arg19, %arg20, %arg21) ({}) {cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32} : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
  func.return %24 : tensor<1x4xf32>

// CHECK-DAG: %[[RES0:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK-DAG: %[[RES1:.*]] = "tfl.pseudo_const"() <{value = dense<{{.*}}> : tensor<1x4xf32>}> {tfl.is_variable} : () -> tensor<1x4xf32>
// CHECK: %[[RES2:.*]] = "tfl.lstm"(%arg0, %arg1, %arg2, %arg3, %arg4, %arg5, %arg6, %arg7, %arg8, %arg9, %arg10, %arg11, %arg12, %arg13, %arg14, %arg15, %arg16, %arg17, %[[RES0]], %[[RES1]], %arg18, %arg19, %arg20, %arg21)
// CHECK-SAME: <{asymmetric_quantize_inputs = false, cell_clip = 0.000000e+00 : f32, fused_activation_function = "NONE", kernel_type = #tfl<lstm_kernel_type_attr FULL>, proj_clip = 0.000000e+00 : f32}> ({
// CHECK: }) : (tensor<1x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4x4xf32>, tensor<4xf32>, tensor<1x4xf32>, tensor<1x4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>, tensor<4xf32>) -> tensor<1x4xf32>
// CHECK: return %[[RES2]]

}

