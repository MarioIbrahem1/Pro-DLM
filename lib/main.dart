import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:road_helperr/providers/signup_provider.dart';
import 'package:road_helperr/ui/screens/ai_chat.dart';
import 'package:road_helperr/ui/screens/ai_welcome_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/home_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/map_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/notification_screen.dart';
import 'package:road_helperr/ui/screens/bottomnavigationbar_screes/profile_screen.dart'
    as profile;
import 'package:road_helperr/ui/screens/edit_profile_screen.dart';
import 'package:road_helperr/ui/screens/email_screen.dart';
import 'package:road_helperr/ui/screens/on_boarding.dart';
import 'package:road_helperr/ui/screens/onboarding.dart';
import 'package:road_helperr/ui/screens/otp_expired_screen.dart';
import 'package:road_helperr/ui/screens/otp_screen.dart';
import 'package:road_helperr/ui/screens/signin_screen.dart';
import 'package:road_helperr/ui/screens/signupScreen.dart';
import 'package:road_helperr/ui/screens/emergency_contacts.dart';
import 'package:road_helperr/models/profile_data.dart';
import 'utils/location_service.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SignupProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocationService _locationService = LocationService();
  late Stream<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _positionStream = _locationService.positionStream;
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    await _locationService.checkLocationPermission();
    bool isLocationEnabled = await _locationService.isLocationServiceEnabled();
    if (!isLocationEnabled) {
      _showLocationDisabledMessage();
    }
  }

  void _showLocationDisabledMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: const Text('Please enable location services to continue.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ٌRoad Helper App',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF1F3551),
        cardTheme: CardTheme(
          color: const Color(0xFF01122A),
          surfaceTintColor: const Color(0xFF01122A),
          elevation: 18,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1F3551),
          primary: const Color(0xFF01122A),
          secondary: const Color(0xFF023A87),
          onPrimary: const Color(0xFFFFFFFF),
          onSecondary: const Color(0xFFFFFFFF),
        ),
        useMaterial3: true,
      ),
      routes: {
        SignupScreen.routeName: (context) => const SignupScreen(),
        SignInScreen.routeName: (context) => const SignInScreen(),
        AiWelcomeScreen.routeName: (context) => const AiWelcomeScreen(),
        AiChat.routeName: (context) => const AiChat(),
        HomeScreen.routeName: (context) => const HomeScreen(),
        MapScreen.routeName: (context) => const MapScreen(),
        NotificationScreen.routeName: (context) => const NotificationScreen(),
        profile.ProfileScreen.routeName: (context) =>
            const profile.ProfileScreen(),
        OtpScreen.routeName: (context) => const OtpScreen(),
        OnBoarding.routeName: (context) => const OnBoarding(),
        OnboardingScreen.routeName: (context) => const OnboardingScreen(),
        OtpExpiredScreen.routeName: (context) => const OtpExpiredScreen(),
        profile.PersonScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?;
          return profile.PersonScreen(
            name: args?['name'] ?? '',
            email: args?['email'] ?? '',
          );
        },
        EditProfileScreen.routeName: (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return EditProfileScreen(
            email: args['email'] as String,
            initialData: args['initialData'] as ProfileData?,
          );
        },
        EmailScreen.routeName: (context) => const EmailScreen(),
        EmergencyContactsScreen.routeName: (context) =>
            const EmergencyContactsScreen(),
      },
      initialRoute: OnboardingScreen.routeName,
    );
  }
}
