import 'package:flutter/material.dart';
import 'package:multi_page_ev_charge/login_page.dart';

class getstarted_page extends StatefulWidget {
  // this is the immutable class,
  // this is the widget that is build again and again when we change the state or loads the program

  @override
  State<getstarted_page> createState() => _getstarted_pageState();
}

class _getstarted_pageState extends State<getstarted_page> {
  // this is the indesteructable claas that can store the details that are persistent

  int curr_ind = 0;

  // Controller object that acts a bridge between the pageView and the computer hardware
  // act as a remote control
  // Dart Code <==> Computer Hardware
  final PageController _pageController = PageController();

  //
  // final List<Map<String, String>> onboardingData = [
  //   {
  //     'image': 'assets/images/Car.png',
  //     'title': 'Power Your Electric Drive',
  //     'subtitle': 'Fast, Reliable Charging Built For 4-Wheeler EV Vehicles',
  //   },
  //   {
  //     'image': 'assets/images/Evstation.png',
  //     'title': 'Find DC Fast Chargers\nNear You',
  //     'subtitle': 'Locate Available CCS2 Chargers With Real-Time Status And Parking Availability',
  //   },
  //   {
  //     'image': 'assets/images/Chargingcar.png',
  //     'title': 'Charge. Track. Pay\nSecurely.',
  //     'subtitle': 'Monitor Live KWh, Control Sessions, And Pay Instantly With Wallet Or UPI',
  //   },
  // ];

  // the New inbuult custom data class list
  // it ensures type safety
  // introduces null safety

  final List<OnboardingContent> onboardingData = [
    const OnboardingContent(
      image: 'assets/images/Car.png',
      title: 'Power Your Electric Drive',
      subtitle: 'Fast, Reliable Charging Built For 4-Wheeler EV Vehicles',
    ),
    const OnboardingContent(
      image: 'assets/images/Evstation.png',
      title: 'Find DC Fast Chargers\nNear You',
      subtitle: 'Locate Available CCS2 Chargers With Real-Time Status And Parking Availability',
    ),
    const OnboardingContent(
      image: 'assets/images/Chargingcar.png',
      title: 'Charge. Track. Pay\nSecurely.',
      subtitle: 'Monitor Live KWh, Control Sessions, And Pay Instantly With Wallet Or UPI',
    ),
  ];

  @override
  void dispose() {

    // Controller object is heavy and silently takes up the memory
    // So we need to clear that space once the page is wipped out
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background color
          Center(
            child: Opacity(
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
          ),

          Center(
            // WindMill image --> right over the image
            child: Opacity(
              opacity: 0.5,
              child: Transform.translate(
                offset: const Offset(0, -100),
                  child: Image.asset('assets/images/Windmill.png'))
            ),
          ),

          SafeArea(
            // Safe Area that contains all the details and the button
            child: Column(
              children: [
                if (curr_ind < 2)
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                      child: TextButton(
                        onPressed: () {
                          _pageController.animateToPage(
                            2,
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                  ),


                Expanded(

                  // This is the main part to render the details that are needed
                  // It can fetch the details and render it on the page
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _pageController,
                    itemCount: onboardingData.length,
                    onPageChanged: (int index) {
                      setState(() {
                        curr_ind = index;
                        print('Current Page number is $curr_ind');
                      });
                      // curr_ind = index;
                    },
                    itemBuilder: (context, index) {
                      // print ('Current index of the page is $index');
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30.0),
                        child: Column(

                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: 40),
                            Transform.translate(
                              offset: const Offset(0, 70),
                              child: Image.asset(
                                onboardingData[index].image!,
                                height: 250,
                              ),
                            ),
                            SizedBox(height: 40),
                            Text(
                              onboardingData[index].title!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              onboardingData[index].subtitle!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        // row (curr_ind);
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: Column(
                    children: [

                      if (curr_ind == 2) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => login_page(),
                                  ),
                                );
                              },
                              child: Text(
                                "Go to the Login Page",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(height: 20),
                      ]
                      else ...[

                        SizedBox(height: 86),
                      ],
                      row(curr_ind),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// Custom Widget that helps to indicate the page on which we are currently in

Widget row(int curr_page) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (curr_page == 0)
        Icon(Icons.circle, size: 10, color: const Color(0xFF2563EB))
      else
        Icon(Icons.circle, size: 10, color: Colors.white30),
      SizedBox(width: 8),
      if (curr_page == 1)
        Icon(Icons.circle, size: 10, color: const Color(0xFF2563EB))
      else
        Icon(Icons.circle, size: 10, color: Colors.white30),
      SizedBox(width: 8),
      if (curr_page == 2)
        Icon(Icons.circle, size: 10, color: const Color(0xFF2563EB))
      else
        Icon(Icons.circle, size: 10, color: Colors.white30),
    ],
  );
}

// Custom data Class for clean code
class OnboardingContent {
  final String image;
  final String title;
  final String subtitle;

  // The constructor requires all three fields so you can never forget one
  // this ensures the NULL safety
  const OnboardingContent({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}