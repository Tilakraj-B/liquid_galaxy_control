import 'package:flutter/material.dart';

class LargeButton extends StatelessWidget {
  final String? label;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Function() onPressed;
  const LargeButton(
      {super.key,
      this.label,
      this.leadingIcon,
      this.trailingIcon,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final textSize = width > height ? height * 0.05 : width * 0.05;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: MaterialButton(
          color: Colors.blueAccent,
          onPressed: onPressed,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  leadingIcon,
                  size: textSize,
                  color: Colors.white,
                ),
                SizedBox(
                  width: leadingIcon == null ? 0 : 10,
                ),
                Text(
                  label ?? "",
                  style: TextStyle(color: Colors.white, fontSize: textSize),
                ),
                SizedBox(
                  width: trailingIcon == null ? 0 : 10,
                ),
                Icon(
                  trailingIcon,
                  color: Colors.white,
                  size: textSize,
                )
              ],
            ),
          )),
    );
  }
}
