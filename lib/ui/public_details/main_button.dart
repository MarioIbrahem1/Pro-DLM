import 'package:flutter/material.dart';
import 'package:road_helperr/utils/app_colors.dart';

class MainButton extends StatelessWidget {
  final String textButton;
  final VoidCallback onPress;
  const MainButton(
      {super.key, required this.textButton, required this.onPress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 48,
      child: ElevatedButton(
          onPressed: onPress,
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.basicButton,
              foregroundColor: AppColors.labelTextField),
          child: Text(
            textButton,
          )),
    );
  }
}
