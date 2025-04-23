import 'package:flutter/material.dart';
import 'package:aichatbot/models/knowledge_base_model.dart';

class UpdateKnowledgeForm extends StatelessWidget {
  final KnowledgeBase knowledgeBase;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final GlobalKey<FormState> formKey;
  final bool hasChanges;

  const UpdateKnowledgeForm({
    Key? key,
    required this.knowledgeBase,
    required this.nameController,
    required this.descriptionController,
    required this.formKey,
    required this.hasChanges,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Knowledge base info card
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin cơ bản',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Tên cơ sở kiến thức',
                      hintText: 'Nhập tên cơ sở kiến thức...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.title),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập tên';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Mô tả',
                      hintText: 'Nhập mô tả về cơ sở kiến thức này...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.description),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),

          // Status section
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông tin bổ sung',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    leading: Icon(
                      knowledgeBase.isEnabled
                          ? Icons.check_circle
                          : Icons.cancel,
                      color:
                          knowledgeBase.isEnabled ? Colors.green : Colors.red,
                    ),
                    title: const Text('Trạng thái'),
                    subtitle: Text(
                      knowledgeBase.isEnabled
                          ? 'Đang hoạt động'
                          : 'Bị vô hiệu hóa',
                    ),
                    dense: true,
                  ),
                  const Divider(),
                  ListTile(
                    leading:
                        const Icon(Icons.calendar_today, color: Colors.blue),
                    title: const Text('Ngày tạo'),
                    subtitle: Text(_formatDate(knowledgeBase.createdAt)),
                    dense: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Update button
          if (hasChanges)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
