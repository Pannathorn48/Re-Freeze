import 'package:flutter/material.dart';

class CustomFloatButton extends StatelessWidget {
  final VoidCallback onPressed;
  const CustomFloatButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Padding(
        padding: EdgeInsets.all(10.0),
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
