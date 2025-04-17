import 'package:flutter/material.dart';
import 'package:road_helperr/ui/widgets/custom_message_dialog.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String? confirmButtonText,
  }) {
    CustomMessageDialog.show(
      context: context,
      title: title,
      message: message,
      isError: false,
      onConfirm: onConfirm,
      confirmButtonText: confirmButtonText ?? 'Continue',
    );
  }

  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onConfirm,
    String? confirmButtonText,
  }) {
    CustomMessageDialog.show(
      context: context,
      title: title,
      message: message,
      isError: true,
      onConfirm: onConfirm,
      confirmButtonText: confirmButtonText ?? 'Try Again',
    );
  }

  // Common success messages
  static void showPasswordResetSuccess(BuildContext context,
      {VoidCallback? onConfirm}) {
    showSuccess(
      context: context,
      title: 'Password Reset Successful',
      message:
          'Your password has been reset successfully. You can now login with your new password.',
      onConfirm: onConfirm,
      confirmButtonText: 'Continue to Login',
    );
  }

  static void showLoginSuccess(BuildContext context,
      {VoidCallback? onConfirm}) {
    showSuccess(
      context: context,
      title: 'Login Successful',
      message: 'You have successfully logged in to your account.',
      onConfirm: onConfirm,
    );
  }

  static void showRegistrationSuccess(BuildContext context,
      {VoidCallback? onConfirm}) {
    showSuccess(
      context: context,
      title: 'Registration Successful',
      message:
          'Your account has been created successfully. You can now login with your credentials.',
      onConfirm: onConfirm,
      confirmButtonText: 'Continue to Login',
    );
  }

  // Common error messages
  static void showPasswordMismatch(BuildContext context) {
    showError(
      context: context,
      title: 'Password Mismatch',
      message: 'The passwords you entered do not match. Please try again.',
    );
  }

  static void showInvalidCredentials(BuildContext context) {
    showError(
      context: context,
      title: 'Invalid Credentials',
      message:
          'The email or password you entered is incorrect. Please try again.',
    );
  }

  static void showNetworkError(BuildContext context) {
    showError(
      context: context,
      title: 'Network Error',
      message: 'Please check your internet connection and try again.',
    );
  }

  static void showServerError(BuildContext context) {
    showError(
      context: context,
      title: 'Server Error',
      message: 'Something went wrong with the server. Please try again later.',
    );
  }

  static void showValidationError(BuildContext context, String message) {
    showError(
      context: context,
      title: 'Validation Error',
      message: message,
    );
  }

  static void showGenericError(BuildContext context, String message) {
    showError(
      context: context,
      title: 'Error',
      message: message,
    );
  }
}
