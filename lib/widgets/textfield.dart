// import 'package:flutter/material.dart';
//
// class InputText extends StatelessWidget {
//   final String label;
//   final String hintText;
//   final TextEditingController controller;
//   final TextInputType? inputType;
//   final IconData? leadingIcon;
//   final IconData? trailingIcon;
//
//   const InputText(
//       {super.key,
//       required this.label,
//       required this.hintText,
//       required this.controller,
//       this.inputType,
//       this.leadingIcon,
//       this.trailingIcon});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5.0),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//             prefixIcon: leadingIcon != null ? Icon(leadingIcon) : null,
//             suffixIcon: trailingIcon != null ? Icon(trailingIcon) : null,
//             label: Text(label),
//             hintText: hintText,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(10),
//             ),
//             fillColor: Colors.white.withOpacity(0.9),
//             filled: true,
//             floatingLabelBehavior: FloatingLabelBehavior.never),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class InputText extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? inputType;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const InputText({
    Key? key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.inputType,
    this.leadingIcon,
    this.trailingIcon,
  }) : super(key: key);

  @override
  _InputTextState createState() => _InputTextState();
}

class _InputTextState extends State<InputText> {
  bool isValid = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: TextFormField(
        controller: widget.controller,
        decoration: InputDecoration(
          prefixIcon:
              widget.leadingIcon != null ? Icon(widget.leadingIcon) : null,
          suffixIcon:
              widget.trailingIcon != null ? Icon(widget.trailingIcon) : null,
          labelText: widget.label,
          hintText: widget.hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: isValid ? Colors.black : Colors.red, width: 2.0),
          ),
          fillColor: Colors.white.withOpacity(0.9),
          filled: true,
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        keyboardType: widget.inputType,
        onChanged: (value) {
          setState(() {
            isValid = true;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            setState(() {
              isValid = false;
            });
            return 'Please enter a valid value';
          }
          return null;
        },
      ),
    );
  }
}
