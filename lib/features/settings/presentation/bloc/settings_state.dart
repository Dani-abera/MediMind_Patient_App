import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.languageCode = 'en',
    this.isLoading = false,
    this.errorMessage,
    this.accountDeleted = false,
  });

  final ThemeMode themeMode;
  final String languageCode;
  final bool isLoading;
  final String? errorMessage;
  final bool accountDeleted;

  SettingsState copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? isLoading,
    String? errorMessage,
    bool? accountDeleted,
  }) =>
      SettingsState(
        themeMode: themeMode ?? this.themeMode,
        languageCode: languageCode ?? this.languageCode,
        isLoading: isLoading ?? this.isLoading,
        errorMessage: errorMessage,
        accountDeleted: accountDeleted ?? this.accountDeleted,
      );

  @override
  List<Object?> get props =>
      [themeMode, languageCode, isLoading, errorMessage, accountDeleted];
}
