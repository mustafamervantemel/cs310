// FILE: lib/screens/upload_note_screen.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/note_model.dart';
import '../services/note_repository.dart';
import '../utils/app_colors.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  File? _pickedImageFile;

  @override
  void dispose() {
    _courseController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
      });
    }
  }

  void _submit() {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      _showErrorDialog('Please fix the errors and try again.');
      return;
    }

    if (_pickedImageFile == null) {
      _showErrorDialog('Please choose a preview image for your note.');
      return;
    }

    final price = double.parse(_priceController.text.trim());

    final newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '${_courseController.text.trim()} – Uploaded Notes',
      courseCode: _courseController.text.trim(),
      instructor: 'Unknown',
      price: price,
      description: _descriptionController.text.trim(),
      taName: 'You',
      taRole: 'Student',
      imagePath: _pickedImageFile!.path,
    );

    NoteRepository.instance.add(newNote);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Uploaded!'),
        content: const Text(
          'Your note has been uploaded successfully and is now visible in the market.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // dialog
              Navigator.of(context).pop(); // screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Form Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileButtonText = _pickedImageFile == null
        ? 'Choose file (image)'
        : 'Selected: ${_pickedImageFile!.path.split('/').last}';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        title: const Text('Upload Note'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Course Name'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _courseController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'CS204 – Advanced Programming',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Course name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Note Definition'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Short description of your notes...',
                ),
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Please enter at least 10 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Price (₺)'),
              const SizedBox(height: 4),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'e.g., 25',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Price is required';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('File'),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.attach_file),
                label: Text(fileButtonText),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Upload Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
