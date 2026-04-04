import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
      body: SafeArea(
        child: Center(
          child: Text(
            '대기중',
            style: TextStyle(color: Color(0xFF888888)),
          ),
        ),
      ),
    );
  }
}
