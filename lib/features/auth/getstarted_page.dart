import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'login_page.dart';
import '../../core/providers/locale_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingCubit extends Cubit<int>
{
  // We start with an initial state of 0 (the first page)
  OnboardingCubit() : super(0);

  // Instead of setState, the UI will call this method
  void updatePage(int index) {
    print('Bloc builder is being called!');
    emit(index); // 'emit' pushes the new state to the UI safely
  }
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

// Widget Class that is created and deleted again and again
// Light weight Blue print
class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});
  // this is the immutable class,
  // this is the widget that is build again and again when we change the state or loads the program

  @override
  Widget build(BuildContext context) {
    // We provide the Cubit to this specific screen
    return BlocProvider(
      create: (context) => OnboardingCubit(),
      child: const _GetStartedView(),
    );
  }
  // this CreateState() method is called only once when the first birth occurs
  // When something in the state changes it is not called again as the state object is already there in the memory
}


// State Object that persist through the memory
class _GetStartedView extends StatelessWidget {
  const _GetStartedView({super.key});
  // this is the indesteructable claas that can store the details that are persistent

  @override
  Widget build(BuildContext context) {
    print('OnBoarding page is being built');
    // Controller object that acts a bridge between the pageView and the computer hardware
    // act as a remote control
    // Dart Code <==> Computer Hardware
    final PageController _pageController = PageController();

    final translator = Provider.of<DynamicTranslationProvider>(context);
    // the New inbuilt custom data class list
    // it ensures type safety
    // introduces null safety
    // Prevents accidental mistype of the variable names
    final List<OnboardingContent> onboardingData = [
      OnboardingContent(
        image: 'assets/images/Car.png',
        title: translator.translate('Power Your Electric Drive'),
        subtitle: translator.translate('Fast, Reliable Charging Built For 4-Wheeler EV Vehicles'),
      ),
      OnboardingContent(
        image: 'assets/images/Evstation.png',
        title: translator.translate('Find DC Fast Chargers\nNear You'),
        subtitle: translator.translate('Locate Available CCS2 Chargers With Real-Time Status And Parking Availability'),
      ),
      OnboardingContent(
        image: 'assets/images/Chargingcar.png',
        title: translator.translate('Charge. Track. Pay Securely.'),
        subtitle: translator.translate('Monitor Live KWh, Control Sessions, And Pay Instantly With Wallet Or UPI'),
      ),

    ];

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
            // this widget helps to keep the content out of the notch and
            // keeps the content intact and presentable
            child: Column(
              children: [


                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Language Switcher Toggle
                      Consumer<DynamicTranslationProvider>(
                        builder: (context, localeProvider, child) {
                          final isHindi = localeProvider.currentLanguage == 'hi';
                          return TextButton.icon(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            ),
                            icon: const Icon(Icons.language, color: Colors.white70, size: 18),
                            label: Text(
                              isHindi ? 'हिन्दी' : 'English',
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {
                              localeProvider.setLanguage(isHindi ? 'en' : 'hi');
                            },
                          );
                        },
                      ),

                      // Skip Button
                      BlocBuilder<OnboardingCubit, int>(
                          builder: (context, currentIndex) {
                            if (currentIndex < 2) {
                              return TextButton(
                                onPressed: () {
                                  _pageController.animateToPage(
                                    2,
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: const Text(
                                  "Skip",
                                  style: TextStyle(color: Colors.white70, fontSize: 16),
                                ),
                              );
                            }
                            return const SizedBox(width: 60);
                          }
                      ),
                    ],
                  ),
                ),


                Expanded(

                  // This is the main part to render the details that are needed
                  // It can fetch the details and render it on the page
                  child: PageView.builder(
                    physics: BouncingScrollPhysics(),
                    controller: _pageController,
                    itemCount: onboardingData.length,

                    // changing the current state of the index
                    onPageChanged: (int index) {
                      // Tell the Cubit to update the state!
                      context.read<OnboardingCubit>().updatePage(index);
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
                                onboardingData[index].image,
                                height: 250,
                              ),
                            ),
                            SizedBox(height: 40),

                            Text(
                              onboardingData[index].title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),

                            Text(
                              onboardingData[index].subtitle,
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
                  child: BlocBuilder<OnboardingCubit, int>(
                      builder: (context, currentIndex) {
                        return Column(
                          children: [
                            if (currentIndex == 2) ...[
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
                                      translator.translate("Go to the Login Page"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 36),
                            ]
                            else ...[
                              const SizedBox(height: 86),
                            ],
                            // Use the Cubit's state here instead of curr_ind
                            row(currentIndex),
                          ],
                        );
                      }
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
