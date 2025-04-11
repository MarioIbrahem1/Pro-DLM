import 'package:flutter/material.dart';
import 'package:road_helperr/utils/app_colors.dart';
import 'package:road_helperr/utils/text_strings.dart';

class OrBorder extends StatelessWidget {
  const OrBorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(
              child: Divider(
                height: 2,
                thickness: 2,
                indent: 90,
                endIndent: 13,
                color: AppColors.borderField,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Text(
                TextStrings.or,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white),
              ),
            ),
            const Expanded(
              child: Divider(
                height: 2,
                thickness: 2,
                indent: 13,
                endIndent: 90,
                color: AppColors.borderField,
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
            const SizedBox(
              width: 15,
            ),
            IconButton(
                onPressed: () {},
                icon: Tab(
                    icon: Image.asset("assets/images/logos_google-gmail.png"))),
            const SizedBox(
              width: 15,
            ),
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
