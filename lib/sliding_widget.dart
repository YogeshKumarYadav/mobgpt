import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:mobgpt/screens/Image_screen.dart';
import 'package:mobgpt/screens/audio_screen.dart';
import 'package:mobgpt/screens/chat_screen.dart';
import 'package:mobgpt/screens/edit_screen.dart';
import 'package:mobgpt/services/api_service.dart';
import 'package:mobgpt/services/assets_manager.dart';
import 'package:mobgpt/widgets/text_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'constants/constants.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SliderWidget extends StatefulWidget {
  const SliderWidget({super.key});

  @override
  State<SliderWidget> createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  String? api_key = "null";
  static var textEditingController = TextEditingController();
  static var focusnode = FocusNode();

  @override
  void initState() {
    get_api_key();
    super.initState();
  }

  int cur_index = 0;
  PageController pagecontroller = PageController(initialPage: 0);
  final navigation_items = [
    BottomNavigationBarItem(
        icon: const Icon(Icons.chat_outlined),
        label: "Chat",
        backgroundColor: scaffoldBackgroundColor),
    BottomNavigationBarItem(
        icon: const Icon(Icons.edit_attributes_outlined),
        label: "Edit",
        backgroundColor: scaffoldBackgroundColor),
    BottomNavigationBarItem(
        icon: const Icon(Icons.image_outlined),
        label: "Image",
        backgroundColor: scaffoldBackgroundColor),
    BottomNavigationBarItem(
        icon: const Icon(Icons.audiotrack_outlined),
        label: "Audio",
        backgroundColor: scaffoldBackgroundColor)
  ];

  @override
  Widget build(BuildContext context) {
    return api_key != "null"
        ? Scaffold(
            body: PageView(
              controller: pagecontroller,
              onPageChanged: (newindex) {
                setState(() {
                  cur_index = newindex;
                });
              },
              children: const [
                ChatScreen(),
                EditScreen(),
                ImageScreen(),
                AudioScreen()
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: cur_index,
                fixedColor: Colors.white,
                items: navigation_items,
                onTap: (newIndex) {
                  setState(() {
                    pagecontroller.animateToPage(newIndex,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn);
                  });
                }),
          )
        : Scaffold(
            backgroundColor: cardColor,
            body: Padding(
                padding: const EdgeInsets.fromLTRB(30, 100, 30, 0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.asset(AssetsManager.appImage,
                          height: 200, width: 200),
                      const SizedBox(height: 70.0),
                      Container(
                        decoration: BoxDecoration(
                          color: scaffoldBackgroundColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8.0)),
                        ),
                        padding: const EdgeInsets.all(16.0),
                        child: TextField(
                          focusNode: focusnode,
                          style: const TextStyle(color: Colors.white),
                          controller: textEditingController,
                          onSubmitted: (value) {
                            ApiService.checkAPI(api: textEditingController.text)
                                .then((value) => {
                                      if (value == true)
                                        {
                                          ApiService.updateAPI(
                                              new_API:
                                                  textEditingController.text),
                                          set_api_key(
                                              textEditingController.text),
                                          setState(() {
                                            api_key =
                                                textEditingController.text;
                                          }),
                                          const SliderWidget()
                                        }
                                      else
                                        {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(const SnackBar(
                                            content: TextWidget(
                                              label:
                                                  "This API key either Invalid or Expired!!!",
                                            ),
                                            backgroundColor: Colors.red,
                                          ))
                                        },
                                      textEditingController.clear(),
                                    });
                          },
                          decoration: const InputDecoration.collapsed(
                            hintText: "OpenAI API key",
                            hintStyle: TextStyle(color: Colors.white38)
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 14, 169, 130)),
                        onPressed: () {
                          ApiService.checkAPI(api: textEditingController.text)
                              .then((value) => {
                                    if (value == true)
                                      {
                                        ApiService.updateAPI(
                                            new_API:
                                                textEditingController.text),
                                        set_api_key(textEditingController.text),
                                        setState(() {
                                          api_key = textEditingController.text;
                                        }),
                                        const SliderWidget()
                                      }
                                    else
                                      {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: TextWidget(
                                            label:
                                                "This API key either Invalid or Expired!!!",
                                          ),
                                          backgroundColor: Colors.red,
                                        ))
                                      },
                                    textEditingController.clear(),
                                  });
                        },
                        child: const Text('Go GPT',
                            style:
                                TextStyle(color: Colors.white, fontSize: 15)),
                      ),
                      const SizedBox(height: 70),
                        RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                                text: 'Get your openai API key from  ',
                                style: TextStyle(color: Colors.white)),
                            TextSpan(
                              text: 'here',
                              style: const TextStyle(
                                color: Color.fromARGB(255, 14, 169, 130),
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = _launchURL,
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30)
                    ],
                  ),
                )));
  }

  void get_api_key() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? key = prefs.getString('api_key');
    ApiService.updateAPI(new_API: key.toString());
    setState(() {
      api_key = key.toString();
    });
  }

  void set_api_key(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_key', key);
  }

  _launchURL() async {
    Uri _url = Uri.parse('https://platform.openai.com/account/api-keys');
    try {
      await launchUrl(_url, mode: LaunchMode.externalApplication);
    } catch (e) {
      throw 'Could not launch!!! Check your Internet connection. $_url';
    }
  }
}
