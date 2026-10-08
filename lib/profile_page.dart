import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'user_details_page.dart';
import 'login_page.dart';

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
    const cardBgColor = Color(0xFF161B22);
    const brandBlue = Color(0xFF2563EB);

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
                    children: const [
                      Text(
                        "Profile", //[cite: 4]
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.settings_outlined, color: Colors.white, size: 24), //[cite: 4]
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
      
                        const Text("My Vehicles", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                                children: const [
                                  Text("Car Name", style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text("Tata Nexon EV", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 12),
                                  Text("Connector", style: TextStyle(color: Colors.white38, fontSize: 12)),
                                  SizedBox(height: 4),
                                  Text("CCS2", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                            child: const Text(
                              "Add New Vehicle",
                              style: TextStyle(color: brandBlue, fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
      
                        const Text("Payment Method", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                                  children: const [
                                    Text("Saved Cards / UPI", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)), //[cite: 4]
                                    SizedBox(height: 2),
                                    Text("Manage Payment Options", style: TextStyle(color: Colors.white54, fontSize: 12)), //[cite: 4]
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
                              _buildMenuTile(Icons.history, "Charging History"),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(Icons.account_balance_wallet_outlined, "Wallet"),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(Icons.notifications_none, "Notifications"),
                              const Divider(color: Colors.white10, height: 1, indent: 16, endIndent: 16),
                              _buildMenuTile(Icons.help_outline, "Help & Support"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
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
                            label: const Text(
                              "Log Out",
                              style: TextStyle(
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

  Widget _buildMenuTile(IconData icon, String title) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Icon(icon, color: Colors.white, size: 22),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        onTap: () {
        },
      ),
    );
  }
}