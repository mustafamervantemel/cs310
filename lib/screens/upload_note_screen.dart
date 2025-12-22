import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../providers/auth_provider.dart';
import '../services/firestore_service.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _courseController = TextEditingController();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  
  PlatformFile? _selectedFile;
  bool _isLoading = false;
  String _uploadStatus = '';
  double _uploadProgress = 0;

  @override
  void dispose() {
    _courseController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
        allowMultiple: false,
        withData: kIsWeb, // Important for web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<String?> _uploadFileToStorage(String userId) async {
    if (_selectedFile == null) return null;
    
    try {
      setState(() {
        _uploadStatus = 'Uploading file...';
        _uploadProgress = 0;
      });
      
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_selectedFile!.name}';
      final ref = FirebaseStorage.instance.ref().child('notes/$userId/$fileName');
      
      UploadTask uploadTask;
      
      if (kIsWeb) {
        // For web, use bytes
        uploadTask = ref.putData(
          _selectedFile!.bytes!,
          SettableMetadata(contentType: _getContentType(_selectedFile!.name)),
        );
      } else {
        // For mobile, use file path
        final file = File(_selectedFile!.path!);
        uploadTask = ref.putFile(
          file,
          SettableMetadata(contentType: _getContentType(_selectedFile!.name)),
        );
      }
      
      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        setState(() {
          _uploadProgress = progress;
          _uploadStatus = 'Uploading: ${(progress * 100).toStringAsFixed(0)}%';
        });
      });
      
      await uploadTask;
      
      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return 'application/pdf';
      case 'doc': return 'application/msword';
      case 'docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'png': return 'image/png';
      case 'jpg':
      case 'jpeg': return 'image/jpeg';
      default: return 'application/octet-stream';
    }
  }

  Future<void> _uploadNote() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a file to upload'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadStatus = 'Preparing...';
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final userId = authProvider.userId;

      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Upload file to Firebase Storage
      final fileUrl = await _uploadFileToStorage(userId);

      setState(() {
        _uploadStatus = 'Saving note...';
      });

      final userEmail = authProvider.userEmail ?? '';
      final userName = userEmail.split('@').first;

      final note = NoteModel(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        courseCode: _courseController.text.trim().toUpperCase(),
        price: double.tryParse(_priceController.text) ?? 0,
        createdBy: userId,
        createdByName: userName,
        createdAt: DateTime.now(),
        fileName: _selectedFile!.name,
        imageUrl: fileUrl, // Store the download URL
        stars: 0,
        totalSells: 0,
      );

      await context.read<FirestoreService>().createNote(note);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note uploaded successfully!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _uploadStatus = '';
          _uploadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                  ),
                  const Expanded(
                    child: Text('Upload Note', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Course Name
                        _buildLabel('COURSE NAME'),
                        TextFormField(
                          controller: _courseController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _inputDecoration('Type your course name... (e.g. CS204)'),
                          validator: (v) => v?.isEmpty == true ? 'Please enter course name' : null,
                        ),

                        const SizedBox(height: 20),

                        // Note Title
                        _buildLabel('NOTE TITLE'),
                        TextFormField(
                          controller: _titleController,
                          decoration: _inputDecoration('e.g. Week 3 Notes, Midterm Summary...'),
                          validator: (v) => v?.isEmpty == true ? 'Please enter note title' : null,
                        ),

                        const SizedBox(height: 20),

                        // Note Description
                        _buildLabel('NOTE DEFINITION'),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: _inputDecoration('Type your description...'),
                          validator: (v) => v?.isEmpty == true ? 'Please enter a description' : null,
                        ),

                        const SizedBox(height: 20),

                        // Price
                        _buildLabel('PRICE (₺)'),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: _inputDecoration('Enter price (e.g. 25)').copyWith(prefixText: '₺ '),
                          validator: (v) {
                            if (v?.isEmpty == true) return 'Please enter a price';
                            if (double.tryParse(v!) == null) return 'Please enter a valid number';
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // File Selection
                        _buildLabel('NOTE FILE'),
                        GestureDetector(
                          onTap: _isLoading ? null : _pickFile,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: _selectedFile != null ? AppColors.success : Colors.transparent, width: 2),
                            ),
                            child: Row(
                              children: [
                                Icon(_selectedFile != null ? Icons.check_circle : Icons.cloud_upload_outlined, color: _selectedFile != null ? AppColors.success : Colors.grey[400], size: 28),
                                const SizedBox(width: 12),
                                Expanded(child: Text(_selectedFile?.name ?? 'Select the file you want to upload', style: TextStyle(color: _selectedFile != null ? AppColors.textPrimary : Colors.grey[400]), overflow: TextOverflow.ellipsis)),
                                if (_selectedFile != null)
                                  IconButton(onPressed: () => setState(() => _selectedFile = null), icon: const Icon(Icons.close, color: Colors.grey), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                              ],
                            ),
                          ),
                        ),
                        
                        if (_selectedFile != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Size: ${(_selectedFile!.size / 1024).toStringAsFixed(1)} KB', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          ),

                        // Upload Progress
                        if (_isLoading) ...[
                          const SizedBox(height: 20),
                          LinearProgressIndicator(value: _uploadProgress, backgroundColor: Colors.grey[200], color: AppColors.success),
                          const SizedBox(height: 8),
                          Center(child: Text(_uploadStatus, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
                        ],

                        const SizedBox(height: 32),

                        // Upload Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _uploadNote,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                            icon: _isLoading ? const SizedBox.shrink() : const Icon(Icons.cloud_upload_outlined),
                            label: _isLoading
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('Upload Note', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey[400]),
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}
