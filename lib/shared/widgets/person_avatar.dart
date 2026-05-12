import 'package:flutter/material.dart';
import 'dart:io';

class PersonAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final String? avatarPath;

  const PersonAvatar({
    super.key,
    required this.name,
    this.radius = 24,
    this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    if (avatarPath != null && avatarPath!.isNotEmpty) {
      final file = File(avatarPath!);
      if (file.existsSync()) {
        return CircleAvatar(
          radius: radius,
          backgroundImage: FileImage(file),
        );
      }
    }

    final initials = name.isNotEmpty 
        ? name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase()
        : '?';
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: _getColor(name),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getColor(String name) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[name.length % colors.length];
  }
}
