<<<<<<< HEAD
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventory/helpers/theme_helper.dart';
=======
// ignore_for_file: unused_field, unused_import, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:eventory/navigators/bottomnavigatorbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

<<<<<<< HEAD
class _ProfileEditState extends State<ProfileEdit> with SingleTickerProviderStateMixin {
=======
class _ProfileEditState extends State<ProfileEdit> {
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? _username;
  String? _contactNumber;
  DateTime? _dateOfBirth;
  String? _photoUrl;
<<<<<<< HEAD
  File? _profileImage;
=======
  File? _profileImage; // Profile image file
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f

  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

<<<<<<< HEAD
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _loadUserProfile();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
=======
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _userIdController.text = user.uid;
        _emailController.text = user.email ?? '';
      });

      DocumentSnapshot profileSnapshot = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user.uid)
          .get();

      if (profileSnapshot.exists) {
        setState(() {
          _username = profileSnapshot['userName'];
          _contactNumber = profileSnapshot['contactNumber'];
<<<<<<< HEAD
          _photoUrl = profileSnapshot.data() != null &&
              (profileSnapshot.data() as Map<String, dynamic>).containsKey('dpurl')
=======

          // Check if dpurl exists in the document before accessing it
          _photoUrl = profileSnapshot.data() != null &&
                  (profileSnapshot.data() as Map<String, dynamic>)
                      .containsKey('dpurl')
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              ? profileSnapshot['dpurl']
              : 'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';

          _usernameController.text = _username ?? '';
          _contactController.text = _contactNumber ?? '';
<<<<<<< HEAD
          _dateOfBirth = (profileSnapshot.data() as Map<String, dynamic>).containsKey('DOB') &&
              profileSnapshot['DOB'] != null
=======
          _dateOfBirth = (profileSnapshot.data() as Map<String, dynamic>)
                      .containsKey('DOB') &&
                  profileSnapshot['DOB'] != null
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              ? (profileSnapshot['DOB'] as Timestamp).toDate()
              : null;
          _dobController.text = _dateOfBirth != null
              ? '${_dateOfBirth?.toLocal()}'.split(' ')[0]
              : '';
        });
      } else {
<<<<<<< HEAD
        setState(() {
          _photoUrl = 'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';
=======
        // If no profile data exists, use the default profile picture
        setState(() {
          _photoUrl =
              'https://img.freepik.com/premium-vector/professional-male-avatar-profile-picture-employee-work_1322206-66590.jpg';
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        });
      }
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
<<<<<<< HEAD
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.orangePrimary,
              onPrimary: Colors.white,
              onSurface: AppColors.textColor(context)!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.orangePrimary,
              ),
            ),
          ),
          child: child!,
        );
      },
=======
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    );
    if (selectedDate != null) {
      setState(() {
        _dateOfBirth = selectedDate;
        _dobController.text = '${_dateOfBirth?.toLocal()}'.split(' ')[0];
      });
    }
  }

  Future<void> _pickImage() async {
<<<<<<< HEAD
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
=======
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _deleteProfileImage() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null && _photoUrl != null) {
      try {
<<<<<<< HEAD
        final publicId = _photoUrl!.split('/').last.split('.').first;
        await _deleteImageFromCloudinary(publicId);

=======
        // Delete the image from Cloudinary
        final publicId = _photoUrl!.split('/').last.split('.').first;
        await _deleteImageFromCloudinary(publicId);

        // Remove the dpurl from Firestore
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        await FirebaseFirestore.instance
            .collection('userDetails')
            .doc(userId)
            .update({'dpurl': FieldValue.delete()});

<<<<<<< HEAD
=======
        // Update the UI
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        setState(() {
          _photoUrl = null;
          _profileImage = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
<<<<<<< HEAD
          SnackBar(
            content: Text('Profile picture deleted successfully!'),
            backgroundColor: AppColors.orangePrimary,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete profile picture: $e'),
            backgroundColor: Colors.red,
          ),
=======
          SnackBar(content: Text('Profile picture deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete profile picture: $e')),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
        );
      }
    }
  }

  Future<void> _uploadProfileImageToCloudinary(File file) async {
    try {
<<<<<<< HEAD
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
=======
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/upload');
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'eventoryuploads'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse['secure_url'];
      } else {
        throw Exception('Failed to upload image to Cloudinary');
      }
    } catch (e) {
      throw Exception('Error uploading image to Cloudinary: $e');
    }
  }

  Future<void> _deleteImageFromCloudinary(String publicId) async {
    try {
<<<<<<< HEAD
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/destroy');
=======
      final uri =
          Uri.parse('https://api.cloudinary.com/v1_1/dfnzttf4v/image/destroy');
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
      final request = http.MultipartRequest('POST', uri)
        ..fields['public_id'] = publicId
        ..fields['upload_preset'] = 'eventoryuploads';

      final response = await request.send();
      if (response.statusCode != 200) {
        throw Exception('Failed to delete image from Cloudinary');
      }
    } catch (e) {
      throw Exception('Error deleting image from Cloudinary: $e');
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        try {
<<<<<<< HEAD
          if (_profileImage != null) {
            final imageUrl = await _uploadProfileImageToCloudinary(_profileImage!) as String;
=======
          // Upload profile image to Cloudinary if selected
          if (_profileImage != null) {
            final imageUrl =
                await _uploadProfileImageToCloudinary(_profileImage!) as String;
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            setState(() {
              _photoUrl = imageUrl;
            });

<<<<<<< HEAD
=======
            // Save the image URL to Firestore
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
            await FirebaseFirestore.instance
                .collection('userDetails')
                .doc(userId)
                .set(
              {
                'dpurl': imageUrl,
              },
              SetOptions(merge: true),
            );
          }

<<<<<<< HEAD
=======
          // Update other user details in Firestore
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          await FirebaseFirestore.instance
              .collection('userDetails')
              .doc(userId)
              .set(
            {
              'userId': userId,
              'email': _emailController.text,
              'userName': _username,
              'DOB': _dateOfBirth,
              'contactNumber': _contactNumber,
            },
            SetOptions(merge: true),
          );

<<<<<<< HEAD
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: AppColors.orangePrimary,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: $e'),
              backgroundColor: Colors.red,
            ),
=======
          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profile updated successfully!')),
          );
        } catch (e) {
          // Handle errors and show an error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update profile: $e')),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
          );
        }
      }
    }
  }

<<<<<<< HEAD
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _animationController.value,
                child: child,
              );
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.orangePrimary,
                  width: 2,
                ),
              ),
              child: ClipOval(
                child: _profileImage != null
                    ? Image.file(
                  _profileImage!,
                  fit: BoxFit.cover,
                )
                    : _photoUrl != null
                    ? Image.network(
                  _photoUrl!,
                  fit: BoxFit.cover,
                )
                    : Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.textColor(context),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.orangePrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          if (_photoUrl != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: _deleteProfileImage,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.orangePrimary,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false, Function(String)? onSaved}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        style: GoogleFonts.poppins(
          color: AppColors.textColor(context),
          fontSize: 16,
        ),
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            color: Theme.of(context).hintColor,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.orangePrimary,
          ),
          filled: true,
          fillColor: AppColors.cardColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
        onSaved: (value) => onSaved?.call(value ?? ''),
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: () => _selectDateOfBirth(context),
      child: AbsorbPointer(
        child: _buildTextField(
          _dobController,
          'Date of Birth',
          Icons.calendar_today,
          readOnly: true,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orangePrimary,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 5,
          shadowColor: AppColors.orangePrimary.withOpacity(0.3),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Center(
            child: Text(
              'SAVE CHANGES',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground(context),
      appBar: AppBar(
        systemOverlayStyle: Theme.of(context).brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textColor(context),
          ),
        ),
        backgroundColor: AppColors.cardColor(context),
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.orangePrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 28),
            onPressed: () {
              _animationController.reset();
              _loadUserProfile().then((_) {
                _animationController.forward();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildProfileImage(),
                SizedBox(height: 30),
                _buildSectionTitle('Account Information'),
                _buildTextField(
                  _userIdController,
                  'User ID',
                  Icons.person_outline,
                  readOnly: true,
                ),
                _buildTextField(
                  _emailController,
                  'Email',
                  Icons.email_outlined,
                  readOnly: true,
                ),
                SizedBox(height: 20),
                _buildSectionTitle('Personal Information'),
                _buildTextField(
                  _usernameController,
                  'Username',
                  Icons.badge_outlined,
                  onSaved: (value) => _username = value,
                ),
                _buildTextField(
                  _contactController,
                  'Contact Number',
                  Icons.phone_outlined,
                  onSaved: (value) => _contactNumber = value,
                ),
                _buildDateField(),
                _buildSaveButton(),
=======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff1E1E2C),
      appBar: AppBar(
        title: Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.orange),
        titleTextStyle: TextStyle(color: Colors.orange, fontSize: 20),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                // Profile Picture with Upload and Delete Icons
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : _photoUrl != null
                                ? NetworkImage(_photoUrl!) as ImageProvider
                                : AssetImage('assets/profile.png'),
                        backgroundColor: Colors.grey[800],
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.orange,
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      if (_photoUrl != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _deleteProfileImage,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.red,
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "Account Information",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildReadOnlyField("User ID", _userIdController),
                SizedBox(height: 10),
                _buildReadOnlyField("Email", _emailController),
                SizedBox(height: 20),
                Text(
                  "Personal Information",
                  style: TextStyle(
                      color: Colors.orange,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                _buildEditableField("Username", _usernameController,
                    (value) => _username = value),
                SizedBox(height: 10),
                _buildEditableField("Contact Number", _contactController,
                    (value) => _contactNumber = value),
                SizedBox(height: 10),
                _buildDateField("Date of Birth", _dobController),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      'Save Changes',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
              ],
            ),
          ),
        ),
      ),
<<<<<<< HEAD
    );
  }
}
=======
      bottomNavigationBar: BottomNavigatorBar(),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, Function(String) onSave) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: TextFormField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Enter $label' : null,
        onSaved: (value) => onSave(value ?? ''),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return GestureDetector(
      onTap: () => _selectDateOfBirth(context),
      child: AbsorbPointer(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(10),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
          ),
          child: TextFormField(
            controller: controller,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
            ),
            validator: (value) =>
                value == null || value.isEmpty ? 'Enter $label' : null,
          ),
        ),
      ),
    );
  }
}
>>>>>>> c4ac9415fafdb8509c994fdc3b6d2c090231199f
