import 'package:flutter/material.dart';

import 'custom_text.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Function onpressed;
  final double height;

  const CustomButton(this.text, this.onpressed, {this.fontWeight, this.height});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: height == null ? 50 : height,
      onPressed: onpressed,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
      color: Theme.of(context).primaryColor,
      child: CustomText(
        text,
        fontweight: fontWeight,
      ),
    );
  }
}
