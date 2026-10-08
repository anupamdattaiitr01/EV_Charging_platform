import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'home_page.dart';

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
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _extraController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // this helps to get rid of the reentering of the phone number again in the home page
    _phoneController.text = FirebaseAuth.instance.currentUser?.phoneNumber ?? "";

    // if data is present then fill this uo
    if (widget.existingData != null) {
      _nameController.text = widget.existingData!['name'] ?? "";
      _phoneController.text = widget.existingData!['phone'] ?? _phoneController.text;
      _dlController.text = widget.existingData!['dl_number'] ?? "";
      _addressController.text = widget.existingData!['address'] ?? "";
      _extraController.text = widget.existingData!['additional_info'] ?? "";
    }
  }

  Future<void> _submitData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DatabaseReference ref = FirebaseDatabase.instance.ref("users/$uid");

      // writing the data in the fire base
      await ref.set({
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "dl_number": _dlController.text.trim(),
        "address": _addressController.text.trim(),
        "additional_info": _extraController.text.trim(),
      });

      if (!mounted) return;

      if (widget.isEditing) {
        Navigator.pop(context);
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const home_page(title: "Select your EV")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
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
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.isEditing ? "Edit Profile" : "Complete Profile", style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("User Details", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  widget.isEditing ? "Update your personal information below." : "Please provide your details to continue.",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 32),

                _buildTextField(_nameController, "Full Name (Required)", isRequired: true),
                _buildTextField(_phoneController, "Phone Number", isPhone: true),
                _buildTextField(_dlController, "Driving License (DL) Number"),
                _buildTextField(_addressController, "Full Address"),
                _buildTextField(_extraController, "Additional Information (Optional)"),

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
                        : Text(widget.isEditing ? "Update Details" : "Save & Continue",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
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
