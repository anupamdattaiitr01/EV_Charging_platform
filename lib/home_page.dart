import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:multi_page_ev_charge/dash_board.dart';
import 'package:provider/provider.dart';
import 'wallet_provider.dart';

class home_page extends StatefulWidget {
  const home_page({super.key, required this.title});
  final String title;

  @override
  State<home_page> createState() => _home_pageState();
}

class _home_pageState extends State<home_page> {
  // String declaration to reduce the silent Error in the code
  // These are all the keys that are declared to ensure the mistype of the key string
  // This avoids the silent injestion of the error in the code

  static const String _brandKey = 'car_brand';
  static const String _modelKey = 'car_model';
  static const String _connectorKey = 'car_connector';

  // these are the values
  String? selectedBrand;
  String? selectedModel;
  String? selectedConnector;

  @override
  void initState() {
  super.initState();
  // This is loaded only once when the page is loaded
  _loadSavedVehicle();
  }

  Future<void> _loadSavedVehicle() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  setState(() {
    selectedBrand = prefs.getString(_brandKey);
    selectedModel = prefs.getString(_modelKey);
    selectedConnector = prefs.getString(_connectorKey);
  });
  }

  @override
  Widget build(BuildContext context) {
    print ("Built function is called for the home page");
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          Positioned(
            top: -150,
            left: -50,
            right: -50,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset(
                'assets/images/Ellipse1.png',
                fit: BoxFit.cover,
                height: 500,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          const Icon(
                              Icons.directions_car_outlined,
                              color: Color(0xFF2563EB),
                              size: 48
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Add Your Vehicle",
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            "Select Your Car Details To Find Compatible Chargers Near You",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white54
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // --------------------
                    // Consumer Method of the provider


                    // const SizedBox(height: 24),
                    // Container(
                    //   width: double.infinity,
                    //   padding: const EdgeInsets.all(16),
                    //   decoration: BoxDecoration(
                    //     color: const Color(0xFF161B22),
                    //     borderRadius: BorderRadius.circular(12),
                    //     border: Border.all(color: Colors.greenAccent, width: 1),
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       const Text("Provider Sandbox", style: TextStyle(color: Colors.white54)),
                    //       const SizedBox(height: 8),
                    //
                    //
                    //       Consumer<WalletProvider>(
                    //         builder: (context, wallet, child) {
                    //           print ('Cosumer reload!');
                    //           return Text(
                    //             "Wallet Balance: ₹${wallet.balance}",
                    //             style: const TextStyle(
                    //                 fontSize: 24,
                    //                 color: Colors.greenAccent,
                    //                 fontWeight: FontWeight.bold
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //       const SizedBox(height: 16),
                    //
                    //
                    //       ElevatedButton(
                    //         onPressed: () {
                    //           Provider.of<WalletProvider>(context, listen: false).addFunds(100);
                    //         },
                    //         style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    //         child: const Text("Add ₹100", style: TextStyle(color: Colors.white)),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    const SizedBox(height: 40),

                    const Text(
                        "Brand",
                        style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

                      decoration:
                      BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: const Color(0xFF161B22),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                          hint: const Text(
                              "Select Car Brand",
                              style: TextStyle(color: Colors.white38)
                          ),
                          value: selectedBrand,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          items: <String>['Tata', 'MG', 'Hyundai', 'Mahindra']
                              .map((String value)
                          {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),

                          onChanged: (newValue) {
                            setState(() {
                              selectedBrand = newValue;
                              selectedModel = null;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text(
                        "Model",
                        style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                    const SizedBox(height: 8),

                    Container
                      (
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          dropdownColor: const Color(0xFF161B22),
                          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
                          hint: const Text(
                              "Select Model",
                              style: TextStyle(color: Colors.white38)
                          ),
                          value: selectedModel,
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                          items: <String>['Nexon EV', 'ZS EV', 'Kona', 'XUV400']
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedModel = newValue;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                        "Connector Type",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 16
                        )
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      "Choose The Charging Port Supported By Your Car.",
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedConnector = "DC";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                border: Border.all(
                                  color: selectedConnector == "DC"
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.electrical_services_outlined, color: Color(0xFF2563EB)),
                                  SizedBox(height: 16),
                                  Text("CCS2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("DC Fast Charging", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedConnector = "AC";
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF161B22),
                                border: Border.all(
                                  color: selectedConnector == "AC"
                                      ? const Color(0xFF2563EB)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Icon(Icons.electrical_services_outlined, color: Color(0xFF2563EB)),
                                  SizedBox(height: 16),
                                  Text("CCS2", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("AC Charging", style: TextStyle(color: Colors.white54, fontSize: 12)),
                                ],
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        // Whole logic of setting the values in the shared preference
                        // If the value is already there we can easily update that using """ SET METHOD """
                        // There is not separate update method in the shared Preference
                        // Set does --- > UPDATE + SETTING New values

                        onPressed: () async{
                          if (selectedBrand != null && selectedModel != null && selectedConnector != null) {
                            // Establishing Connection with the shared preference channel

                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            await prefs.setString(_brandKey, selectedBrand!);
                            await prefs.setString(_modelKey, selectedModel!);
                            await prefs.setString(_connectorKey, selectedConnector!);

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DashboardPage(),
                                ),
                              );
                            }

                          }
                          else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please select all vehicle details"),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save & Continue",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}