import 'package:flutter/material.dart';

class ProductCard extends StatefulWidget {
  final Function() onPressed;
  final double width;
  final double height;
  ProductCard(
      {super.key,
      required this.onPressed,
      required this.width,
      required this.height});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white.withOpacity(0.9),
        child:
            Container(padding: EdgeInsets.all(10.0), child: const SizedBox()));
  }
}
