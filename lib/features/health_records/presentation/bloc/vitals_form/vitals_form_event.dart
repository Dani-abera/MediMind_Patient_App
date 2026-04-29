import 'package:equatable/equatable.dart';

abstract class VitalsFormEvent extends Equatable {
  const VitalsFormEvent();
  @override
  List<Object?> get props => [];
}

class VitalsFormFieldChanged extends VitalsFormEvent {
  const VitalsFormFieldChanged({required this.field, required this.value});
  final String field;
  final String value;
  @override
  List<Object?> get props => [field, value];
}

class VitalsFormSubmitted extends VitalsFormEvent {
  const VitalsFormSubmitted({this.recordId});
  final String? recordId;
  @override
  List<Object?> get props => [recordId];
}

class VitalsFormReset extends VitalsFormEvent {
  const VitalsFormReset();
}
