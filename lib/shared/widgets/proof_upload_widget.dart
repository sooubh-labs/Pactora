import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ProofUploadWidget extends StatelessWidget {
  final VoidBinding onUpload;
  
  const ProofUploadWidget({super.key, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onUpload,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          children: [
            Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 32),
            SizedBox(height: 8),
            Text('Tap to upload photo proof', 
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

typedef VoidBinding = void Function();
