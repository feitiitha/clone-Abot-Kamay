import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'global/top_bar.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  void _handleBackNavigation() {
    if (_messages.isNotEmpty) {
      setState(() {
        _messages.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _typewriterResponse(String fullText) {
    String currentDisplay = "";
    int index = 0;

    setState(() {
      _messages.add({
        "sender": "ai",
        "text": "",
        "time": DateTime.now()
      });
    });

    Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (index < fullText.length) {
        currentDisplay += fullText[index];
        if (mounted) {
          setState(() {
            _messages[_messages.length - 1]["text"] = currentDisplay;
          });
        }
        _scrollToBottom();
        index++;
      } else {
        timer.cancel();
        if (mounted) setState(() => _isTyping = false);
      }
    });
  }

  void _handleSend(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        "sender": "user",
        "text": text,
        "time": DateTime.now()
      });
      _isTyping = true;
    });

    _controller.clear();
    _scrollToBottom();

    String response = "";
    if (text.contains("Pag-abot")) {
      response = "Ang Pag-abot Program ay isang komprehensibong programa na naglalayong makatulong na mabigyan ng nararapat na serbisyo o intervention ang mga pamilya at indibidwal pati ang mga nasa bulnerableng sector gaya ng mga bata, senior citizen at PWD na nasa lansangan.";
    } else if (text.contains("impormasyon para makatulong")) {
      response = "Ipadala lang po sa amin ang eksaktong lokasyon kung saan nakikita ang mga pamilya, indibidwal, o kabataan na nakatira sa lansangan.";
    } else if (text.contains("pinakamalapit na DSWD center")) {
      response = "Maaari ninyong makita ang listahan ng mga DSWD Field Offices sa aming official website dswd.gov.ph.";
    } else if (text.contains("Sinu-sino ang pwedeng matulungan")) {
      response = "Ang prayoridad ng DSWD ay ang mga pamilyang kabilang sa 'poorest of the poor', senior citizens, at PWD.";
    } else {
      response = "Salamat sa iyong mensahe. Ako ay ang iyong DSWD Assistant. Paano pa kita matutulungan?";
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      _typewriterResponse(response);
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const GlobalAppBar(),
        body: Column(
          children: [
            _buildSubHeader(context),
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFE0E7FF), Color(0xFFF3F4F6), Colors.white],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: _messages.isEmpty ? _buildInitialView() : _buildChatListView(),
              ),
            ),
            _buildLargeInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          const SizedBox(height: 30),
          Text(
            "Hi! I'm your DSWD Chatbot Assistant",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
          ),
          const SizedBox(height: 15),
          Text(
            "You can ask me about social welfare programs, financial assistance, and emergency support services.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 40),
          _choiceBubble("Ano ang Pag-abot Program?"),
          _choiceBubble("Paano magbigay ng impormasyon para makatulong?"),
          _choiceBubble("Saan ang pinakamalapit na DSWD center?"),
          _choiceBubble("Sinu-sino ang pwedeng matulungan?"),
        ],
      ),
    );
  }

  Widget _buildChatListView() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text("Today", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final msg = _messages[index];
              bool isUser = msg["sender"] == "user";
              DateTime time = msg["time"];

              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isUser) const SizedBox(width: 40),
                        if (!isUser) ...[
                          const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.smart_toy_outlined, color: Color(0xFF5C8AF0), size: 20),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.75,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: isUser ? const Color(0xFF5C8AF0) : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Text(
                              msg["text"]!,
                              style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14),
                            ),
                          ),
                        ),
                        if (!isUser) const SizedBox(width: 40),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(bottom: 12, left: isUser ? 0 : 45, right: isUser ? 5 : 0),
                      child: Text(
                        _formatTime(time),
                        style: const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _choiceBubble(String text) {
    return GestureDetector(
      onTap: () => _handleSend(text),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
        ),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15)),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _handleBackNavigation,
            child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          ),
          const Text("Chatbot Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatbotSettingsPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLargeInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 8),
            child: Text("FAQ & Support", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          ),
          TextField(
            controller: _controller,
            maxLines: 3,
            minLines: 1,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              hintText: "Type your message...",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.attach_file, color: Color(0xFF5C8AF0)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.send, color: Color(0xFF5C8AF0)),
                onPressed: () => _handleSend(_controller.text),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(35),
                borderSide: const BorderSide(color: Colors.black12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(35),
                borderSide: const BorderSide(color: Colors.black12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- PROFILE SCREEN ---

class ChatbotSettingsPage extends StatelessWidget {
  const ChatbotSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GlobalAppBar(),
      body: Column(
        children: [
          // Malinis na Header - Back button lang at more icon
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 18, 15, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
                ),
                const Icon(Icons.more_horiz, color: Colors.black54),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Profile Picture
          Center(
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF5C8AF0),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 80, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCircularButton(Icons.info_outline, "About"),
              _buildCircularButton(Icons.search, "Search"),
              _buildCircularButton(Icons.notifications_none, "Mute"),
              _buildCircularButton(Icons.settings_outlined, "Settings"),
            ],
          ),
          const SizedBox(height: 40),

          // Bottom Blue Section - Naka-Expanded para sagad sa baba
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
              decoration: const BoxDecoration(
                color: Color(0xFFE0E7FF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Chat info", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    _buildShadowedTile(Icons.folder_open_outlined, "Media, links and files"),
                    
                    const SizedBox(height: 35),
                    const Text("FAQs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 15),
                    _buildShadowedTile(Icons.help_outline, "What is OPLAN Pag-abot?"),
                    _buildShadowedTile(Icons.help_outline, "What is this chat for?"),
                    _buildShadowedTile(Icons.help_outline, "Messaging rules and policies."),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: Colors.black12),
          ),
          child: Icon(icon, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildShadowedTile(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black45),
        onTap: () {},
      ),
    );
  }
}