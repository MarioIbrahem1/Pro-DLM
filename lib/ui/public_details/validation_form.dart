import 'package:flutter/material.dart';
import 'package:road_helperr/ui/public_details/input_field.dart' as INp;
import 'package:road_helperr/ui/public_details/main_button.dart' as bum;
import 'package:road_helperr/ui/public_details/or_border.dart' as or_bbr;
import 'package:road_helperr/ui/screens/car_settings_screen.dart';
import 'package:road_helperr/ui/screens/OTPscreen.dart';
import 'package:road_helperr/utils/app_colors.dart' as colo;
import 'package:road_helperr/utils/text_strings.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:road_helperr/providers/signup_provider.dart';

class ValidationForm extends StatefulWidget {
  const ValidationForm({super.key});

  @override
  _ValidationFormState createState() => _ValidationFormState();
}

class _ValidationFormState extends State<ValidationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController firstNameController = TextEditingController();
  final FocusNode firstNameFocusNode = FocusNode();

  final TextEditingController lastNameController = TextEditingController();
  final FocusNode lastNameFocusNode = FocusNode();

  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  final TextEditingController passwordController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();

  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FocusNode confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    firstNameController.dispose();
    firstNameFocusNode.dispose();
    lastNameController.dispose();
    lastNameFocusNode.dispose();
    phoneController.dispose();
    phoneFocusNode.dispose();
    emailController.dispose();
    emailFocusNode.dispose();
    passwordController.dispose();
    passwordFocusNode.dispose();
    confirmPasswordController.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              INp.InputField(
                icon: Icons.person,
                label: "First Name",
                hintText: 'First name',
                validatorIsContinue: (text) {
                  if (text!.isEmpty || text.length < 3) {
                    return "At least 3 characters";
                  }
                  return null;
                },
                controller: firstNameController,
                focusNode: firstNameFocusNode,
              ),
              const SizedBox(height: 10),
              INp.InputField(
                icon: Icons.person,
                label: "Last Name",
                hintText: 'Last name',
                validatorIsContinue: (text) {
                  if (text!.isEmpty || text.length < 3) {
                    return "At least 3 characters";
                  }
                  return null;
                },
                controller: lastNameController,
                focusNode: lastNameFocusNode,
              ),
              const SizedBox(height: 10),
              INp.InputField(
                icon: Icons.phone,
                label: "Phone Number",
                hintText: 'Phone',
                keyboardType: TextInputType.number,
                controller: phoneController,
                focusNode: phoneFocusNode,
                validatorIsContinue: (phoneText) {
                  if (phoneText?.length != 11 ||
                      !RegExp(r'^[0-9]+').hasMatch(phoneText!)) {
                    return "Must be exactly 11 digits";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              INp.InputField(
                icon: Icons.email_outlined,
                label: "Email",
                hintText: 'Email',
                validatorIsContinue: (emailText) {
                  final regExp = RegExp(
                      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}");
                  if (!regExp.hasMatch(emailText!)) {
                    return "Invalid email format";
                  }
                  return null;
                },
                controller: emailController,
                focusNode: emailFocusNode,
              ),
              const SizedBox(height: 10),
              INp.InputField(
                icon: Icons.lock,
                hintText: "Enter your password",
                label: "Password",
                isPassword: true,
                controller: passwordController,
                focusNode: passwordFocusNode,
                validatorIsContinue: (passwordText) {
                  if (passwordText == null || passwordText.isEmpty) {
                    return "Please enter your password";
                  }
                  if (passwordText.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              INp.InputField(
                icon: Icons.lock,
                label: "Confirm Password",
                hintText: 'Confirm password',
                isPassword: true,
                validatorIsContinue: (confirmPasswordText) {
                  if (confirmPasswordText != passwordController.text) {
                    return "Passwords do not match";
                  }
                  return null;
                },
                controller: confirmPasswordController,
                focusNode: confirmPasswordFocusNode,
              ),
              const SizedBox(height: 20),
              bum.MainButton(
                textButton: TextStrings.textButton3,
                onPress: () async {
                  if (_formKey.currentState!.validate()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CarSettingsScreen(
                          registrationData: {
                            'firstName': firstNameController.text.trim(),
                            'lastName': lastNameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'email': emailController.text.trim(),
                            'password': passwordController.text.trim(),
                          },
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill all fields correctly'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const or_bbr.OrBorder(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TextStrings.textToSignUp,
                    style: TextStyle(
                      color: colo.AppColors.getBorderField(context),
                      fontSize: width * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          final registrationData = {
                            'firstName': firstNameController.text.trim(),
                            'lastName': lastNameController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'email': emailController.text.trim(),
                            'password': passwordController.text.trim(),
                          };

                          Provider.of<SignupProvider>(context, listen: false)
                              .setUserData(registrationData);

                          final otpResponse =
                              await ApiService.sendOTPWithoutVerification(
                                  registrationData['email']!);

                          if (otpResponse['success'] == true) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('OTP has been sent to your email'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 3),
                              ),
                            );

                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Otp(
                                  email: registrationData['email']!,
                                  registrationData: registrationData,
                                ),
                              ),
                            );
                          } else {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(otpResponse['error'] ??
                                    'Failed to send OTP'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields correctly'),
                            backgroundColor: Colors.red,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    child: Text(
                      TextStrings.logIn,
                      style: TextStyle(
                        color: colo.AppColors.getSignAndRegister(context),
                        fontSize: width * 0.035,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
