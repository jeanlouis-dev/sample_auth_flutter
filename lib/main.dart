import 'dart:async';
import 'dart:math' show Random;
import 'package:flutter/material.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:sign_button/sign_button.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:random_string/random_string.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sample Auth Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Authentication Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController phoneController = TextEditingController();
  FocusNode focusNode = FocusNode();
  bool _isLoading = false;
  bool _isValid = false;
  late bool result;
 

  String? phoneNumber;

  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

    void _startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void _stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      _stopLoading();
      result = bool.parse(uri.queryParameters['result']!) ;
      print("Result from ADN: $result");
      phoneController.clear();
      showModalBottomSheet(
         isDismissible: false,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(10),
            ),
          ),
          backgroundColor: Colors.white,
          context: context,
          builder: ((context) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: double.infinity,
                ),
                Text(
                  result
                      ? "Successfully authenticated"
                      : "Authentication failed",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 30,
                ),
                Icon(
                  result ? Icons.verified_rounded : Icons.error_outline,
                  color: result ? Colors.green.shade800 : Colors.red.shade700,
                  size: 200,
                ),
                const SizedBox(
                  height: 25,
                ),
                ElevatedButton(
                  onPressed: () {
                     setState(() {
                      Navigator.pop(context);
                    });
                  }, 
                  child: const Text("Reset"))
              ],
            );
          })
      );
    });
  }

  void authentication() async {
    _startLoading();
    String code = randomNumeric(6);
    launchUrl(
      Uri.parse(
          'adn://authentication?tel=$phoneNumber&code=$code'),
      mode: LaunchMode.externalNonBrowserApplication,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 40,),
            const Text("Login", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
             const SizedBox(height: 40,),
          IntlPhoneField(
            enabled: !_isLoading,
            controller: phoneController,
            keyboardType: TextInputType.number,
            autovalidateMode: AutovalidateMode.disabled,
            focusNode: focusNode,
            initialCountryCode: 'CI',
            decoration: InputDecoration( 
              labelText: 'Phone number',
              labelStyle: const TextStyle(color: Colors.black87),
              focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black87),
                      borderRadius: BorderRadius.circular(10),
              ),
              focusedErrorBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color.fromARGB(255, 175, 13, 1)),
                      borderRadius: BorderRadius.circular(10),
              ),
              border:const OutlineInputBorder(
                borderSide: BorderSide(),
              ),
              
              counterText: '',
            ),
            onChanged: (phone) {
                 setState(() {
                 try {
                  _isValid = phone.isValidNumber();
                 } catch (e) {
                  _isValid = false;
                 }
                
                 phoneNumber = phone.completeNumber;
              });
            },
          ),
          const SizedBox(height: 35,),
           SignInButton(
            buttonType: ButtonType.custom, 
            width: double.infinity,
            buttonSize: ButtonSize.large,
            btnColor: Colors.green,
            btnTextColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            customImage: CustomImage("assets/images/logo_adn.png"),
            btnText: "Continue with ADN",
            onPressed: !_isValid ? null : () async {
              authentication();
            })
          ],
        ),
      ),
    );
  }
}