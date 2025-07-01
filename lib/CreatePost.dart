import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'dart:typed_data';
import 'dart:io';

class CreatePostPage extends StatefulWidget {
  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  XFile? _pickedImage;
  Uint8List? _webImage;
  File? _mobileImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      } else {
        setState(() => _mobileImage = File(pickedFile.path));
      }
    }
  }

  Future<void> _uploadPost() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content is required')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final Username = FirebaseAuth.instance.currentUser!.displayName;
      String? imageUrl = _imageUrlController.text.trim().isNotEmpty
          ? _imageUrlController.text.trim()
          : null;

      if (_pickedImage != null && imageUrl == null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('post_images/${DateTime.now().millisecondsSinceEpoch}');
        if (kIsWeb && _webImage != null) {
          await ref.putData(_webImage!);
        } else if (_mobileImage != null) {
          await ref.putFile(_mobileImage!);
        }
        imageUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('posts').add({
        'text': content,
        'imageUrl': imageUrl ?? "",
        'username': Username,
        'likeCount': 0,
        'commentsCount': 0,
        'likes': {},
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context); // Close loading
      Navigator.pop(context); // Back

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post uploaded successfully')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _contentController,
                decoration:
                    const InputDecoration(labelText: 'What’s on your mind?'),
                maxLines: 5,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL (Optional)',
                  hintText: 'Enter an image URL or upload an image',
                ),
              ),
              const SizedBox(height: 16),
              if (_webImage != null)
                Image.memory(_webImage!, height: 200)
              else if (_mobileImage != null)
                Image.file(_mobileImage!, height: 200),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text('Pick Image'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _uploadPost,
                icon: const Icon(Icons.upload),
                label: const Text('Post'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
