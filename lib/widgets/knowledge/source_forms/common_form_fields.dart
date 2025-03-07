import 'package:flutter/material.dart';

class CommonFormFields extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Color primaryColor;

  const CommonFormFields({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thông tin cơ bản',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Tên nguồn dữ liệu *',
            hintText: 'E.g., Tài liệu hướng dẫn sử dụng',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tên cho nguồn dữ liệu';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            labelText: 'Mô tả *',
            hintText: 'Mô tả ngắn về nội dung của nguồn dữ liệu',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập mô tả cho nguồn dữ liệu';
            }
            return null;
          },
        ),
      ],
    );
  }
}
