import 'package:flutter/material.dart';
import 'package:road_helperr/ui/public_details/main_button.dart';
import 'package:road_helperr/ui/public_details/or_border.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/home_screen.dart';
import 'package:road_helperr/ui/screens/email_screen.dart';
import 'package:road_helperr/ui/screens/signupScreen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SignInScreen extends StatefulWidget {
  static const String routeName = "signinscreen";

  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool status = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailController.text = prefs.getString('email') ?? '';
      passwordController.text = prefs.getString('password') ?? '';
      status = prefs.getBool('rememberMe') ?? false;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (status) {
      await prefs.setString('email', emailController.text);
      await prefs.setString('password', passwordController.text);
      await prefs.setBool('rememberMe', status);
    } else {
      await prefs.remove('email');
      await prefs.remove('password');
      await prefs.remove('rememberMe');
    }
  }

  @override
  Widget build(BuildContext context) {

    var lang = AppLocalizations.of(context)!;

    var mediaQuery = MediaQuery.of(context).size;
    //var lang = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1F3551),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Image
            Container(
              width: mediaQuery.width,
              height: mediaQuery.height * 0.3,
              decoration: const BoxDecoration(
                color: Color(0xFF1F3551),
                image: DecorationImage(
                  image: AssetImage("assets/images/rafiki.png"),
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Main Content
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1F3551),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        lang.welcomeBack,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Email Input
                    InputField(
                      icon: Icons.email_outlined,
                      hintText: lang.enterYourEmail,
                      label: lang.email,
                      validatorIsContinue: (emailText) {
                        final regExp = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                        if (emailText == null || emailText.isEmpty) {
                          return lang.pleaseEnterYourEmail;
                        }
                        if (!regExp.hasMatch(emailText)) {
                          return lang.pleaseEnterAValidEmail;
                        }
                        return null;
                      },
                      controller: emailController,
                    ),

                    // Password Input
                    InputField(
                      icon: Icons.lock,
                      hintText: lang.enterYourPassword,
                      label: lang.password,
                      isPassword: true,
                      validatorIsContinue: (passwordText) {
                        if (passwordText == null || passwordText.isEmpty) {
                          return lang.pleaseEnterYourPassword;
                        }
                        if (passwordText.length < 6) {
                          return lang.passwordMustBeAtLeast6Characters;
                        }
                        return null;
                      },
                      controller: passwordController,
                    ),

                    // Remember Me & Forgot Password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: status,
                                onChanged: (value) {
                                  setState(() {
                                    status = value!;
                                  });
                                },
                                fillColor:
                                    WidgetStateProperty.all(Colors.white),
                                checkColor: const Color(0xFF1F3551),
                              ),
                               Text(
                               lang.rememberMe ,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(EmailScreen.routeName);
                            },
                            child:  Text(
                              lang.forgotPassword,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Login Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: MainButton(
                        textButton: lang.login,
                        onPress: () {
                          if (_formKey.currentState!.validate()) {
                            _saveUserData();
                            Navigator.of(context)
                                .pushNamed(HomeScreen.routeName);
                          }
                        },
                      ),
                    ),

                    const OrBorder(),

                    // Register Link
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                           Text(
                           lang.dontHaveAnAccount,
                            style: const TextStyle(color: Colors.white),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(SignupScreen.routeName);
                            },
                            child:  Text(
                              lang.register,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// تعديل InputField Widget ليشمل controller
class InputField extends StatefulWidget {
  final IconData icon;
  final String hintText;
  final String label;
  final bool isPassword;
  final String? Function(String?)? validatorIsContinue;
  final TextEditingController controller;

  const InputField({
    super.key,
    required this.icon,
    required this.hintText,
    required this.label,
    this.isPassword = false,
    this.validatorIsContinue,
    required this.controller,
  });

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextFormField(
        controller: widget.controller,
        obscureText: widget.isPassword ? _isObscure : false,
        validator: widget.validatorIsContinue,
        decoration: InputDecoration(
          prefixIcon: Icon(widget.icon, color: Colors.white),
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure;
                    });
                  },
                )
              : null,
          hintText: widget.hintText,
          labelText: widget.label,
          labelStyle: const TextStyle(color: Colors.white),
          hintStyle: const TextStyle(color: Colors.white54),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.white),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.red),
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
