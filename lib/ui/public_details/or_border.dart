import 'package:flutter/material.dart';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:road_helperr/utils/text_strings.dart';

class OrBorder extends StatelessWidget {
  const OrBorder({super.key});

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.getBorderField(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                height: 2,
                thickness: 2,
                indent: 90,
                endIndent: 13,
                color: borderColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                TextStrings.or,
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF407BFF)
                      : Colors.white,
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                height: 2,
                thickness: 2,
                indent: 13,
                endIndent: 90,
                color: borderColor,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                onPressed: () {},
                icon:
                    Tab(icon: Image.asset("assets/images/logos_facebook.png"))),
            const SizedBox(width: 15),
            IconButton(
                onPressed: () {},
                icon: Tab(
                    icon: Image.asset("assets/images/logos_google-gmail.png"))),
            const SizedBox(width: 15),
            IconButton(
                onPressed: () {},
                icon:
                    Tab(icon: Image.asset("assets/images/logos_twitter.png"))),
          ],
        ),
      ],
    );
  }
}
