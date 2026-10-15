import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../dashboard/home_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';


class UserDetailsPage extends StatefulWidget {
  // this map stores the existing data if present
  final Map<dynamic, dynamic>? existingData;
  final bool isEditing;


  const UserDetailsPage({super.key, this.existingData, this.isEditing = false});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _extraController = TextEditingController();
  bool _isLoading = false;
  File? _profileImage;
  File? _aadhaarPdf;
  String? _aadhaarFileName;
  String? _existingProfileUrl;
  String? _existingAadhaarUrl;

  @override
  void initState() {
    super.initState();
    // this helps to get rid of the reentering of the phone number again in the home page
    _phoneController.text = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";

    // if data is present then fill this uo
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? "";
      _phoneController.text = widget.existingData!['phone'] ?? _phoneController.text;
      _emailController.text = widget.existingData!['email'] ?? "";
      _dlController.text = widget.existingData!['dl_number'] ?? "";
      _addressController.text = widget.existingData!['address'] ?? "";
      _extraController.text = widget.existingData!['additional_info'] ?? "";

      _existingProfileUrl = widget.existingData!['profile_image_url'];
      _existingAadhaarUrl = widget.existingData!['aadhaar_pdf_url'];
      if (_existingAadhaarUrl != null) _aadhaarFileName = "Aadhaar_Verified.pdf";
    }
  }

  // 1. Pick Profile Picture from Gallery
  Future<void> _pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75, // Compresses image for faster upload
    );

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  // 2. Pick Aadhaar Card (Restricted to PDF only)
  Future<void> _pickAadhaarPdf() async {
    final PlatformFile? result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.path != null) {
      setState(() {
        _aadhaarPdf = File(result.path!);
        _aadhaarFileName = result.name;
      });
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

      String? profileImageUrl = _existingProfileUrl;
      if (_profileImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child("users/$uid/profile.jpg");
        await storageRef.putFile(_profileImage!);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      // --- NEW: Upload Aadhaar PDF if selected ---
      String? aadhaarPdfUrl = _existingAadhaarUrl;
      if (_aadhaarPdf != null) {
        final storageRef = FirebaseStorage.instance.ref().child("users/$uid/aadhaar.pdf");
        await storageRef.putFile(_aadhaarPdf!);
        aadhaarPdfUrl = await storageRef.getDownloadURL();
      }

      // writing the data in the fire base
      await ref.set({
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "email": _emailController.text.trim(),
        "dl_number": _dlController.text.trim(),
        "address": _addressController.text.trim(),
        "additional_info": _extraController.text.trim(),
        "profile_image_url": profileImageUrl ?? "",
        "aadhaar_pdf_url": aadhaarPdfUrl ?? "",
      });

      if (!mounted) return;

      if (widget.isEditing)
      {
        Navigator.pop(context);
      }
      else
      {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page(title: "Select your EV")),
        );
      }
    }
    catch (e)
    {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally
    {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Widget _buildTextField(TextEditingController controller, String hint, {bool isRequired = false, bool isPhone = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16.0),
  //     child: TextFormField(
  //       controller: controller,
  //       enabled: !isPhone, // Prevent editing the phone number since it is OTP verified
  //       style: TextStyle(color: isPhone ? Colors.white54 : Colors.white),
  //       decoration: InputDecoration(
  //         filled: true,
  //         fillColor: const Color(0xFF161B22),
  //         hintText: hint,
  //         hintStyle: const TextStyle(color: Colors.white38),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(16),
  //           borderSide: BorderSide.none,
  //         ),
  //       ),
  //       validator: (value) {
  //         if (isRequired && (value == null || value.trim().isEmpty)) {
  //           return 'This field is required';
  //         }
  //         return null;
  //       },
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final translator = Provider.of<DynamicTranslationProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar:
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.isEditing ? translator.translate("Edit Profile") : translator.translate("Complete Profile"), style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Stack(
        children: [
          Opacity(
            opacity: 0.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30.0),
              child: Image.asset(
                'assets/images/Ellipse1.png',
                width: 600,
                height: 600,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translator.translate("User Details"), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEditing ? translator.translate("Update your personal information below.") : translator.translate("Please provide your details to continue."),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF161B22),
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : (_existingProfileUrl != null && _existingProfileUrl!.isNotEmpty
                                ? NetworkImage(_existingProfileUrl!) as ImageProvider
                                : null),
                            child: (_profileImage == null && (_existingProfileUrl == null || _existingProfileUrl!.isEmpty))
                                ? const Icon(Icons.person, size: 50, color: Colors.white54)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2563EB),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  _buildTextField(_nameController, translator.translate("Full Name (Required)"), isRequired: true),
                  _buildTextField(_phoneController, translator.translate("Phone Number"), isPhone: true),
                  _buildTextField(_dlController, translator.translate("Driving License (DL) Number")),
                  _buildTextField(_emailController, translator.translate("Email Address (Optional)")),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: InkWell(
                      onTap: _pickAadhaarPdf,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF161B22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _aadhaarFileName != null ? const Color(0xFF2563EB) : Colors.white12,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.picture_as_pdf,
                              color: _aadhaarFileName != null ? const Color(0xFF00E676) : Colors.redAccent,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _aadhaarFileName ?? translator.translate("Upload Aadhaar Card (PDF)"),
                                style: TextStyle(
                                  color: _aadhaarFileName != null ? Colors.white : Colors.white38,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.upload_file, color: Colors.white54),
                          ],
                        ),
                      ),
                    ),
                  ),

                  _buildTextField(_addressController, translator.translate("Full Address")),
                  _buildTextField(_extraController, translator.translate("Additional Information (Optional)")),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(widget.isEditing ? translator.translate("Update Details") : translator.translate("Save & Continue"),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),]
      ),
    );
  }
}

Widget _buildTextField(TextEditingController controller, String hint, {bool isRequired = false, bool isPhone = false}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: TextFormField(
      controller: controller,
      enabled: !isPhone, // Prevent editing the phone number since it is OTP verified
      style: TextStyle(color: isPhone ? Colors.white54 : Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF161B22),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) {
        if (isRequired && (value == null || value.trim().isEmpty)) {
          return 'This field is required';
        }
        return null;
      },
    ),
  );
}
