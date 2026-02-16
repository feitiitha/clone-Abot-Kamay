import 'package:flutter/material.dart';
import '../settings.dart';
import '../articles.dart';
import '../chatbot.dart'; // Siguraduhing tama ang path patungo sa chatbot.dart mo

class GlobalAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onAboutTap;

  const GlobalAppBar({super.key, this.onAboutTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1.0),
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 75,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/dswd_mainpage.png',
                height: 55,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.business, color: Colors.blue, size: 45),
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      // DINUGTONG: Dito mangyayari ang paglipat ng page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatbotPage(),
                        ),
                      );
                    },
                    child: Image.asset(
                      'assets/chatbot.png',
                      height: 30,
                      width: 30,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  PopupMenuButton<String>(
                    offset: const Offset(0, 55),
                    icon: const Icon(Icons.menu, color: Colors.black, size: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    onSelected: (value) {
                      if (value == 'settings') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      } else if (value == 'about') {
                        onAboutTap?.call();
                      } else if (value == 'articles') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ArticlesPage(),
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'about', child: Text('About')),
                      const PopupMenuItem(
                        value: 'articles',
                        child: Text('Articles'),
                      ),
                      const PopupMenuItem(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75);
}