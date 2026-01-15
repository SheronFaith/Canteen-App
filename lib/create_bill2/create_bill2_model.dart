import '/flutter_flow/flutter_flow_util.dart';
import 'create_bill2_widget.dart' show CreateBill2Widget;
import 'package:flutter/material.dart';

class CreateBill2Model extends FlutterFlowModel<CreateBill2Widget> {
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
