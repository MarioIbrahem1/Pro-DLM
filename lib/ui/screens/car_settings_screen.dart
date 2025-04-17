import 'package:flutter/material.dart';
import 'package:road_helperr/services/api_service.dart';
import 'package:road_helperr/ui/screens/OTPscreen.dart';
import 'package:provider/provider.dart';
import 'package:road_helperr/providers/signup_provider.dart';

class CarSettingsScreen extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const CarSettingsScreen({
    super.key,
    required this.registrationData,
  });

  @override
  _CarSettingsScreenState createState() => _CarSettingsScreenState();
}

class _CarSettingsScreenState extends State<CarSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final bool _isNumbersOnly = false;
  String _carNumber = '';
  String _carColor = '';
  String _carModel = '';
  final String _carYear = '';
  bool _isLoading = false;

  // تعريف FocusNodes
  final FocusNode _firstLetterFocus = FocusNode();
  final FocusNode _secondLetterFocus = FocusNode();
  final FocusNode _thirdLetterFocus = FocusNode();
  final FocusNode _numbersFocus = FocusNode();

  // تعريف TextEditingControllers
  final TextEditingController _firstLetterController = TextEditingController();
  final TextEditingController _secondLetterController = TextEditingController();
  final TextEditingController _thirdLetterController = TextEditingController();
  final TextEditingController _lettersController = TextEditingController();
  final TextEditingController _numbersController = TextEditingController();

  // تعريف الألوان الثابتة
  final Color backgroundColor = const Color.fromRGBO(1, 18, 42, 1);
  final Color cardColor = const Color.fromRGBO(10, 30, 60, 1);
  final Color accentColor = Colors.blue;
  final Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // تحديث بيانات التسجيل في SignupProvider
    final signupProvider = Provider.of<SignupProvider>(context, listen: false);
    signupProvider.setUserData(widget.registrationData);

    // طباعة البيانات للتأكد من حفظها
    print('Initial Registration Data:');
    signupProvider.printData();
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
    _lettersController.dispose();
    _numbersController.dispose();
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
      // تحديث بيانات السيارة في SignupProvider
      final signupProvider =
          Provider.of<SignupProvider>(context, listen: false);

      print('Before updating car data:');
      signupProvider.printData();

      // تجميع الحروف والأرقام بشكل صحيح
      final letters =
          "${_firstLetterController.text}${_secondLetterController.text}${_thirdLetterController.text}";
      final numbers = _numbersController.text;

      signupProvider.updateValue('letters', letters);
      signupProvider.updateValue('plate_number', numbers);
      signupProvider.updateValue('car_color', _carColor);
      signupProvider.updateValue('car_model', _carModel);

      print('After updating car data:');
      signupProvider.printData();

      // الحصول على كل البيانات المحدثة
      final userData = signupProvider.getAllData();

      print('Final data being sent to server:');
      userData.forEach((key, value) {
        print('$key: $value');
      });

      // Send OTP without verification for signup
      final otpResponse =
          await ApiService.sendOTPWithoutVerification(userData['email']);

      if (otpResponse['success'] == true) {
        // Navigate to OTP screen with all registration data
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
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
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
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Car Settings',
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Letters Input
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
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
                            'Letters',
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                                filled: true,
                                fillColor: backgroundColor,
                              ),
                              maxLength: 1,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) {
                                if (value.length == 1) {
                                  _secondLetterFocus.requestFocus();
                                }
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
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                                filled: true,
                                fillColor: backgroundColor,
                              ),
                              maxLength: 1,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) {
                                if (value.length == 1) {
                                  _thirdLetterFocus.requestFocus();
                                }
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
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: accentColor.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: accentColor),
                                ),
                                filled: true,
                                fillColor: backgroundColor,
                              ),
                              maxLength: 1,
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (value) {
                                if (value.length == 1) {
                                  _numbersFocus.requestFocus();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Numbers Input
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
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
                            'Plate Numbers',
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
                        focusNode: _numbersFocus,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter Plate Number',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: accentColor.withOpacity(0.3)),
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
                            return 'Please enter numbers';
                          }
                          if (value.isEmpty || value.length > 7) {
                            return 'Must be between 1 and 7 digits';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _numbersController.text = value!;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Car Color Input
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: accentColor.withOpacity(0.3)),
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
                            'Car Color',
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
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter car color',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: accentColor.withOpacity(0.3)),
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
                            return 'Please enter car color';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _carColor = value!;
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
                    border: Border.all(color: accentColor.withOpacity(0.3)),
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
                            'Car Model',
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
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          hintText: 'Enter car model',
                          hintStyle:
                              TextStyle(color: Colors.grey.withOpacity(0.5)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                BorderSide(color: accentColor.withOpacity(0.3)),
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
                            return 'Please enter car model';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _carModel = value!;
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
                      'Sign up',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
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
        ),
      ),
    );
  }
}
