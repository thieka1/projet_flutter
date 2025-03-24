import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../provider/profil_provider.dart';
import '../provider/project_provider.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProjectProvider>(context, listen: false).fetchProjects();
    });
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = pickedFile.name;

      try {
        Reference ref = FirebaseStorage.instance.ref().child('profile_images/$fileName');
        UploadTask uploadTask = ref.putFile(file);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await Provider.of<UserProfileProvider>(context, listen: false)
            .updateUserProfile(downloadUrl as File);
      } catch (e) {
        print("Erreur de téléchargement de l'image : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Mon Profil")),
      body: Consumer<UserProfileProvider>(
        builder: (context, userProfileProvider, child) {
          if (userProfileProvider.userProfile == null) {
            return Center(child: CircularProgressIndicator());
          }

          final userProfile = userProfileProvider.userProfile!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userProfile.profileImageUrl.isNotEmpty
                      ? NetworkImage(userProfile.profileImageUrl)
                      : AssetImage("assets/images/default_profile.png") as ImageProvider,
                ),
                SizedBox(height: 10),
                Text(userProfile.fullName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text(userProfile.email, style: TextStyle(fontSize: 16, color: Colors.grey)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickAndUploadImage,
                  child: Text("Changer de photo"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
