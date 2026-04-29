import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsRequested extends SettingsEvent {
  const SettingsRequested();
}

class SettingsThemeModeChanged extends SettingsEvent {
  const SettingsThemeModeChanged(this.mode);
  final ThemeMode mode;
  @override
  List<Object?> get props => [mode];
}

class SettingsLanguageChanged extends SettingsEvent {
  const SettingsLanguageChanged(this.languageCode);
  final String languageCode;
  @override
  List<Object?> get props => [languageCode];
}

class SettingsAccountDeleteRequested extends SettingsEvent {
  const SettingsAccountDeleteRequested();
}
