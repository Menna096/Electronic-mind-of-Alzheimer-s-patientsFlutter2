import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vv/Family/LoginPageAll.dart';
import 'package:vv/faceid.dart';
import 'package:vv/home/comp/onboarding_content.dart';

class Onboarding extends StatefulWidget {
  final void Function()? showSignInScreen;
  const Onboarding({super.key, required this.showSignInScreen});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 25.0), // Add padding here
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Elder Helper'.tr(),
                        style: GoogleFonts.poppins(
                          fontSize: 33,
                          fontWeight: FontWeight.w600,
                          color: const Color(
                              0xff3B5998), // Change text color to white
                        ),
                      ),
                    ],
                  ),
                ),
                //pages
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: contents.length,
                    onPageChanged: (int index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (_, i) {
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Center(
                                child: Image.asset(
                                  contents[i].image,
                                  colorBlendMode: BlendMode.darken,
                                ),
                              ),
                            ),
                            const SizedBox(height: 0.5),
                            //title
                            Text(
                              contents[i].title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 27,
                                height: 1.2,
                                color:
                                    Colors.white, // Change text color to white
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(
                              height: 1,
                            ),
                            //description
                            Text(
                              contents[i].description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 2,
                                color:
                                    Colors.white, // Change text color to white
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                //dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          currentIndex = index;
                        });
                        pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.bounceIn,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        height: 10.0,
                        width: (index == currentIndex) ? 20 : 10,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: (index == currentIndex)
                              ? (const Color(0xff3B5998))
                              : (Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment
                      .spaceBetween, // Align buttons to the left and right
                  children: [
                    SizedBox(
                      height: 50,
                      width: 140,
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const CameraScreen(),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          elevation: WidgetStateProperty.all(2),
                          shape: WidgetStateProperty.all(
                            const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                          backgroundColor:
                              WidgetStateProperty.all(const Color(0xffFFFFFF)),
                        ),
                        child: Text(
                          'Skip'.tr(),
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: const Color(
                                0xff3B5998), // Change text color to white
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20), // Add space between the buttons
                    Visibility(
                      visible: (currentIndex !=
                          contents.length -
                              1), // Check if it's not the last page
                      child: SizedBox(
                        height: 50,
                        width: 140,
                        child: FilledButton(
                          onPressed: () {
                            if (currentIndex == contents.length - 1) {
                              // If it's the last page
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const CameraScreen(),
                                ),
                              );
                            } else {
                              // If it's not the last page
                              pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.decelerate,
                              );
                            }
                          },
                          style: ButtonStyle(
                            elevation: WidgetStateProperty.all(2),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(20),
                                ),
                              ),
                            ),
                            backgroundColor: WidgetStateProperty.all(
                                const Color(0xff3B5998)),
                          ),
                          child: Text(
                            'Next'.tr(),
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white, // Change text color to white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
