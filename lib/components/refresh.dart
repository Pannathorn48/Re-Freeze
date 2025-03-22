import 'package:flutter/material.dart';

class RefreshWidget extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  const RefreshWidget(
      {super.key, required this.child, required this.onRefresh});

  @override
  State<RefreshWidget> createState() => _RefreshWidgetState();
}

class _RefreshWidgetState extends State<RefreshWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: widget.onRefresh,
        color: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.white,
        displacement: 60,
        strokeWidth: 3,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: widget.child,
        ),
      ),
    );
  }
}
