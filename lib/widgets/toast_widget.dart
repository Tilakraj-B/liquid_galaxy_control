import 'package:flutter/material.dart';

Widget ToastWidget(String msg, Icon? icon) {
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20.0),
      border: Border.all(color: Colors.black),
      color: Colors.white,
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon ?? const SizedBox(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 9,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    msg,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ),
  );
  return toast;
}
