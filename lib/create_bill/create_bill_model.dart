import '/flutter_flow/flutter_flow_util.dart';
import 'create_bill_widget.dart' show CreateBillWidget;
import 'package:flutter/material.dart';

class CreateBillModel extends FlutterFlowModel<CreateBillWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
