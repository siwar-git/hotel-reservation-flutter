import 'package:flutter/material.dart';
import 'package:hajz_sejours/features/auth/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import '../../home/view/home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _welcomeData = [
    {'animation': 'assets/animation1.json', 'text': "Trouvez la chambre parfaite en quelques clics !"},
    {'animation': 'assets/animation2.json', 'text': "Besoin d’aide ? Notre assistant intelligent vous répond 24h/24 !"},
    {'animation': 'assets/animation5.json', 'text': "Des interfaces modernes et \n animées pour une navigation intuitive."},
    {'animation': 'assets/animation3.json', 'text': "Accumulez des points et obtenez des réductions exclusives !"},
    {'animation': 'assets/animation4.json', 'text': "Réglez vos paiements en toute sécurité avec notre \n solution fiable !"},
  ];

  void _nextPage() async {
    if (_currentPage < _welcomeData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenWelcome', true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen(),
      ));
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 19, 31, 233), Color(0xD9878D8D)],
          ),
        ),
        child:Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _welcomeData.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedOpacity(
                      opacity: _currentPage == index ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 800),
                      child: Transform.scale(
                        scale: _currentPage == index ? 1.0 : 0.9,
                        child: Text(
                          _welcomeData[index]['text']!,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'CinzelDecorative',
                            letterSpacing: 1.8,
                            shadows: [

                              Shadow(
                                blurRadius: 20.0,
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(-2, -2),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 65),
                    Lottie.asset(
                      _welcomeData[index]['animation']!,
                      width: 300,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
                  ],
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _welcomeData.length,
                  (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                height: 10,
                width: _currentPage == index ? 20 : 10,
                decoration: BoxDecoration(
                  color: _currentPage == index ? Colors.amber : Colors.white,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('hasSeenWelcome', true);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Passer',
                    style: TextStyle(color: Colors.amber, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    _currentPage == _welcomeData.length - 1 ? 'Commencer' : 'Suivant',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    )
    );
  }
}
