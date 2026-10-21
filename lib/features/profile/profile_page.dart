import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../auth/user_details_page.dart';
import '../auth/login_page.dart';
import 'user_manual_page.dart';
import 'package:provider/provider.dart';
import '../../core/providers/locale_provider.dart';
import 'supported_ev_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _handleLogout() async {
    // 1. Sign out of Firebase Auth session
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    // 2. Clear navigation history and route back to login
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => login_page()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final translator = Provider.of<DynamicTranslationProvider>(context);
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);
    print ('Build function for the Profile page is called!');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background Ambient Glow
          Positioned(
            top: -120,
            left: -50,
            right: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/Ellipse1.png',
                fit: BoxFit.cover,
                height: 400,
              ),
            ),
          ),
      
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(translator.translate("Profile"), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                      Consumer<DynamicTranslationProvider>(
                        builder: (context, localeProvider, child) {
                          return DropdownButton<String>(
                            value: localeProvider.currentLanguage,
                            dropdownColor: const Color(0xFF161B22),
                            icon: const Icon(Icons.language, color: Colors.white70, size: 24),
                            underline: const SizedBox(),
                            items: const [
                              DropdownMenuItem(value: 'en', child: Text("English", style: TextStyle(color: Colors.white, fontSize: 14))),
                              DropdownMenuItem(value: 'hi', child: Text("हिंदी", style: TextStyle(color: Colors.white, fontSize: 14))),
                            ],
                            onChanged: (String? newLanguage) {
                              if (newLanguage != null) localeProvider.setLanguage(newLanguage);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
      
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        // widget to get fetch the data from the fire base
                        StreamBuilder(
                          stream: FirebaseDatabase.instance
                              .ref("users/${FirebaseAuth.instance.currentUser?.uid}")
                              .onValue,
                          builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator(color: brandBlue));
                            }

                            Map<dynamic, dynamic>? userData;
                            if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                              userData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                            }


                            // if anything goes wrong then this will take care of the error
                            // it will put the dummy data in the app page
                            String name = userData?['name'] ?? "User Name";
                            String phone = userData?['phone'] ?? (FirebaseAuth.instance.currentUser?.phoneNumber ?? "+91 XXXXXXXXXX");
                            String dl = userData?['dl_number'] ?? "";
                            String address = userData?['address'] ?? "";
                            String initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "U";

                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: cardBgColor.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 26,
                                        backgroundColor: brandBlue,
                                        child: Text(
                                          initial,
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text(phone, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => UserDetailsPage(
                                                existingData: userData,
                                                isEditing: true,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),

                                  if (dl.isNotEmpty || address.isNotEmpty) ...[
                                    const Divider(color: Colors.white10, height: 24),
                                    if (dl.isNotEmpty)
                                      Row(
                                        children: [
                                          const Icon(Icons.badge_outlined, color: Colors.white38, size: 16),
                                          const SizedBox(width: 8),
                                          Text("DL: $dl", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                        ],
                                      ),
                                    if (address.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.location_on_outlined, color: Colors.white38, size: 16),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(address, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        Text(translator.translate("My Vehicles"), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(translator.translate("Car Name"), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text(translator.translate("TATA Nexon EV"), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                  SizedBox(height: 12),
                                  Text(translator.translate("Connector"), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text(translator.translate("CCS2"), style: const TextStyle(color: Colors.white38, fontSize: 12)),
                                ],
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                                  SizedBox(width: 16),
                                  Icon(Icons.delete_outline, color: Colors.white70, size: 20),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
      
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E3A8A)), // Dark blue border
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(translator.translate("Add New Vehicle"), style: const TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(translator.translate("Payment Method"), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.credit_card, color: Colors.white70, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(translator.translate("Saved Cards / UPI"), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
// ...
                                    SizedBox(height: 2),
                                    Text(translator.translate("Manage Payment Options"), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward, color: Colors.white54, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        Container(
                          decoration: BoxDecoration(
                            color: cardBgColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _buildMenuTile(Icons.history, translator.translate("Charging History")),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(Icons.account_balance_wallet_outlined, translator.translate("Wallet")),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(Icons.notifications_none, translator.translate("Notifications")),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(Icons.help_outline, translator.translate("Help & Support")),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(
                                Icons.menu_book,
                                translator.translate("User Manual"),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const UserManualPage()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        ListTile(
                          leading: const Icon(Icons.electric_car, color: Colors.white70),
                          title: const Text('Supported EV Models', style: TextStyle(color: Colors.white)),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),

                          // ADD THE CODE HERE:
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SupportedEVPage()),
                            );
                          },
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  backgroundColor: const Color(0xFF161B22),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Text(
                                    "Log Out",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  content: const Text(
                                    "Are you sure you want to log out of your account?",
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text("Cancel", style: TextStyle(color: Colors.white54)),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _handleLogout();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text("Log Out", style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 20),
                            label: Text(
                              translator.translate("Log Out"),
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),

// Extra bottom padding so content clears the bottom navigation bar smoothly
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14),
        onTap: onTap,
      ),
    );
  }
}