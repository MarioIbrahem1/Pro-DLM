import 'package:flutter/material.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/ui/screens/OTPscreen.dart';
import 'package:provider/provider.dart';
import 'package:road_helperr/providers/signup_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CarSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const CarSettingsScreen({
    super.key,
    required this.registrationData,
  });

  static const String routeName = "carSettings";

  @override
  _CarSettingsScreenState createState() => _CarSettingsScreenState();
}

class _CarSettingsScreenState extends State<CarSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNumbersOnly = false;

  // FocusNodes
  final FocusNode _firstLetterFocus = FocusNode();
  final FocusNode _secondLetterFocus = FocusNode();
  final FocusNode _thirdLetterFocus = FocusNode();
  final FocusNode _numbersFocus = FocusNode();

  // TextEditingControllers
  final TextEditingController _firstLetterController = TextEditingController();
  final TextEditingController _secondLetterController = TextEditingController();
  final TextEditingController _thirdLetterController = TextEditingController();
  final TextEditingController _numbersController = TextEditingController();
  final TextEditingController _carColorController = TextEditingController();
  final TextEditingController _carModelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // تحديث بيانات التسجيل في SignupProvider
    final signupProvider = Provider.of<SignupProvider>(context, listen: false);
    signupProvider.setUserData(widget.registrationData);
    // يمكنك هنا طباعة الداتا لو عايز
    // signupProvider.printData();
  }

  @override
  void dispose() {
    _firstLetterFocus.dispose();
    _secondLetterFocus.dispose();
    _thirdLetterFocus.dispose();
    _numbersFocus.dispose();
    _firstLetterController.dispose();
    _secondLetterController.dispose();
    _thirdLetterController.dispose();
    _numbersController.dispose();
    _carColorController.dispose();
    _carModelController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _register();
    }
  }

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final signupProvider =
          Provider.of<SignupProvider>(context, listen: false);
      if (_isNumbersOnly) {
        signupProvider.updateValue('letters', '');
        signupProvider.updateValue('plate_number', _numbersController.text);
      } else {
        final letters =
            "${_firstLetterController.text}${_secondLetterController.text}${_thirdLetterController.text}";
        signupProvider.updateValue('letters', letters);
        signupProvider.updateValue('plate_number', _numbersController.text);
      }
      signupProvider.updateValue('car_color', _carColorController.text.trim());
      signupProvider.updateValue('car_model', _carModelController.text.trim());

      final userData = signupProvider.getAllData();

      // Send OTP without verification for signup
      final otpResponse =
          await ApiService.sendOTPWithoutVerification(userData['email']);
      if (otpResponse['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Otp(
              email: userData['email'],
              registrationData: userData,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(otpResponse['error'] ?? 'Failed to send OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final backgroundColor =
        isLight ? Colors.white : const Color.fromRGBO(1, 18, 42, 1);
    final cardColor =
        isLight ? Colors.white : const Color.fromRGBO(10, 30, 60, 1);
    final accentColor = isLight ? const Color(0xFF023A87) : Colors.blueAccent;
    final textColor = isLight ? Colors.black : Colors.white;
    final lang = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(lang.carSettings,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: (_isLoading)
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Car Number Type Section
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: accentColor),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.numbers, color: accentColor),
                              const SizedBox(width: 10),
                              Text(
                                lang.carNumberType,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isNumbersOnly = true;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isNumbersOnly
                                          ? accentColor
                                          : cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: _isNumbersOnly
                                            ? accentColor
                                            : accentColor.withOpacity(0.7),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        lang.numbersOnly,
                                        style: TextStyle(
                                          color: _isNumbersOnly
                                              ? Colors.white
                                              : accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _isNumbersOnly = false;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isNumbersOnly
                                          ? accentColor
                                          : cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: !_isNumbersOnly
                                            ? accentColor
                                            : accentColor.withOpacity(0.7),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        lang.lettersAndNumbers,
                                        style: TextStyle(
                                          color: !_isNumbersOnly
                                              ? Colors.white
                                              : accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Car Number Input Section
                    if (_isNumbersOnly)
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: accentColor),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.numbers, color: accentColor),
                                const SizedBox(width: 10),
                                Text(
                                  lang.carNumber,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _numbersController,
                              focusNode: _numbersFocus,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                hintText: lang.enterPlateNumber,
                                hintStyle: TextStyle(
                                    color: accentColor.withOpacity(0.5)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                                filled: true,
                                fillColor: backgroundColor,
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 7,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return lang.pleaseEnterNumbers;
                                }
                                if (value.length > 7 || value.isEmpty) {
                                  return lang.mustBeAtLeast1NumberAndMax7Digits;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          // Letters Input
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: accentColor),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.text_fields, color: accentColor),
                                    const SizedBox(width: 10),
                                    Text(
                                      lang.letters,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // First Letter Box
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        controller: _firstLetterController,
                                        focusNode: _firstLetterFocus,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 20,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: accentColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: accentColor),
                                          ),
                                          filled: true,
                                          fillColor: backgroundColor,
                                        ),
                                        maxLength: 1,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        onChanged: (value) {
                                          if (value.length == 1) {
                                            _secondLetterFocus.requestFocus();
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return lang.required;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    // Second Letter Box
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        controller: _secondLetterController,
                                        focusNode: _secondLetterFocus,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 20,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: accentColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: accentColor),
                                          ),
                                          filled: true,
                                          fillColor: backgroundColor,
                                        ),
                                        maxLength: 1,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        onChanged: (value) {
                                          if (value.length == 1) {
                                            _thirdLetterFocus.requestFocus();
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return lang.required;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    // Third Letter Box
                                    SizedBox(
                                      width: 80,
                                      child: TextFormField(
                                        controller: _thirdLetterController,
                                        focusNode: _thirdLetterFocus,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 20,
                                        ),
                                        decoration: InputDecoration(
                                          counterText: "",
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: accentColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: accentColor),
                                          ),
                                          filled: true,
                                          fillColor: backgroundColor,
                                        ),
                                        maxLength: 1,
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        onChanged: (value) {
                                          if (value.length == 1) {
                                            _numbersFocus.requestFocus();
                                          }
                                        },
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return lang.required;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Numbers Input (with letters)
                          Container(
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: accentColor),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.numbers, color: accentColor),
                                    const SizedBox(width: 10),
                                    Text(
                                      lang.plateNumbers,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _numbersController,
                                  focusNode: _numbersFocus,
                                  style: TextStyle(color: textColor),
                                  decoration: InputDecoration(
                                    hintText: lang.enterPlateNumber,
                                    hintStyle: TextStyle(
                                        color: accentColor.withOpacity(0.5)),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: accentColor),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide:
                                          BorderSide(color: accentColor),
                                    ),
                                    filled: true,
                                    fillColor: backgroundColor,
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 7,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return lang.pleaseEnterNumbers;
                                    }
                                    if (value.length > 7 || value.isEmpty) {
                                      return lang
                                          .mustBeAtLeast1NumberAndMax7Digits;
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),

                    // Car Color Input
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: accentColor),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.color_lens, color: accentColor),
                              const SizedBox(width: 10),
                              Text(
                                lang.carColor,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _carColorController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: lang.enterCarColor,
                              hintStyle: TextStyle(
                                  color: accentColor.withOpacity(0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentColor),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return lang.pleaseEnterCarColor;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Car Model Input
                    Container(
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: accentColor),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.directions_car, color: accentColor),
                              const SizedBox(width: 10),
                              Text(
                                lang.carModel,
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _carModelController,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: lang.enterCarModel,
                              hintStyle: TextStyle(
                                  color: accentColor.withOpacity(0.5)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentColor),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: accentColor),
                              ),
                              filled: true,
                              fillColor: backgroundColor,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return lang.pleaseEnterCarModel;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Signup Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          lang.signUpButton,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/signin');
                          },
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )),
    );
  }
}
