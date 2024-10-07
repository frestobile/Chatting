import 'dart:io';

import 'package:ainaglam/models/coworker_model.dart';
import 'package:ainaglam/models/workspace_model.dart';
import 'package:ainaglam/screens/home/home_screen.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ainaglam/providers/chat_provider.dart';

class EditProfileDialog extends StatefulWidget {
  final Coworker profileData;
  final Workspace workspace;
  final ChatProvider? chatProvider;

  const EditProfileDialog(
      {super.key,
      required this.profileData,
      required this.workspace,
      this.chatProvider});
  @override
  _EditProfileDialogState createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  String _email = 'superstar0601.dev@gmail.com';
  String _username = 'superstar0601.dev';
  String _displayName = 'Super';
  String _avatar = '';
  String? _orgId;
  ChatProvider? _chatProvider;

  File? _selectedAvatar; // For mobile
  Uint8List? _selectedAvatarByte; // For web

  @override
  void initState() {
    super.initState();
    _email = widget.profileData.email;
    _username = widget.profileData.username;
    _displayName = widget.profileData.displayName;
    _avatar = widget.profileData.avatarUrl;
    _orgId = widget.workspace.id;
    _chatProvider = widget.chatProvider;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: const EdgeInsets.symmetric(vertical: 8.0),
      contentPadding: const EdgeInsets.all(10.0),
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),
      ),
      title: const Center(
        child: Text(
          'プロフィール編集',
          style: TextStyle(color: Colors.white),
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                  child: GestureDetector(
                onTap: _profileImagePick,
                child: Container(
                  width: 100,
                  height: 100,
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8), // Rounded rectangle
                    border: Border.all(
                      color: Colors.white, // Border color
                      width: 1, // Border width
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _avatar != ''
                        ? CircleAvatar(
                            radius: 18,
                            backgroundImage: _getAvatarImage() ??
                                NetworkImage(
                                    '${dotenv.env['API_BASE_URL']}/static/avatar/$_avatar'), // Replace with actual image
                          )
                        : CircleAvatar(
                            radius: 18,
                            backgroundImage: _getAvatarImage() ??
                                AssetImage(
                                    'avatars/${_displayName[0].toLowerCase()}.png'),
                          ),
                  ),
                ),
              )),
              const SizedBox(height: 20),
              // Email Field
              TextFormField(
                enabled: false,
                initialValue: _email,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              const SizedBox(height: 20),

              // Username Field
              TextFormField(
                initialValue: _username,
                decoration: InputDecoration(
                  labelText: 'User Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  _username = value ?? '';
                },
              ),
              const SizedBox(height: 20),

              // Display Name Field
              TextFormField(
                initialValue: _displayName,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                onSaved: (value) {
                  _displayName = value ?? '';
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Center(
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() == true) {
                _formKey.currentState?.save();
                Navigator.of(context).pop();
                print(
                    'Profile updated: Email: $_email, Username: $_username, Display Name: $_displayName');

                _submit(_username, _displayName, _orgId!);
              }
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.grey[900],
              side: const BorderSide(color: Colors.white), // Outline color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              foregroundColor: Colors.white, // Text color
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            child: const Text(
              '保存',
              style: TextStyle(fontSize: 14.0, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _profileImagePick() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image, allowMultiple: false,
      // allowedExtensions: ['jpg', 'png', 'bmp', 'ico', ''],
    );

    if (result != null) {
      if (kIsWeb) {
        Uint8List? fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          setState(() {
            _selectedAvatarByte = fileBytes; // Store file bytes for web
          });
          // await chatProvider.imageUploadByByte(_selectedFileBytes!, false);
        }
      } else {
        String? filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            _selectedAvatar = File(filePath);
          });
          // await chatProvider.imageUploadByFile(_selectedFile!, false);
        }
      }
    }
  }

  // Helper function to return the correct image based on platform (web or mobile)
  ImageProvider? _getAvatarImage() {
    if (kIsWeb) {
      // For Web: Return MemoryImage from Uint8List
      return _selectedAvatarByte != null
          ? MemoryImage(_selectedAvatarByte!)
          : null;
    } else {
      // For Mobile: Return FileImage from File
      return _selectedAvatar != null ? FileImage(_selectedAvatar!) : null;
    }
  }

  Future<void> _submit(
      String username, String displayName, String orgId) async {
    await _chatProvider!.updateProfile(
        username, displayName, orgId, _selectedAvatar, _selectedAvatarByte);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => HomeScreen(
          workspace: widget.workspace,
        ),
      ),
    );
  }
}
