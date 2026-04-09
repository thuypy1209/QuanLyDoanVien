import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Services/ChatService.dart';
import 'package:quanlidoanvien/Utils.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [];
  bool _isConnected = false;
  String _myName = "";

  @override
  void initState() {
    super.initState();
    _loadMyName();
    _setupChat();
  }

  void _setupChat() {
    _chatService.onMessageReceived = (data) {
      if (mounted) {
        setState(() {
          _messages.add({
            'user': data['user'],
            'avatar': data['avatar'],
            'message': data['message'],
            'time': data['time'],
            'isMe': data['user'] == _myName
          });
        });
        _scrollToBottom();
      }
    };

    _chatService.onConnectionChanged = (isConnected) {
      if (mounted) setState(() => _isConnected = isConnected);
    };

    _chatService.initSignalR().catchError((e) => print("Lỗi kết nối Chat: $e"));
  }
  Future<void> _loadMyName() async {
    // Gọi hàm getName() mà ní đã thêm ở file Utils
    String name = await Utils.getName();
    setState(() {
      _myName = name;
    });
  }
  void _handleSend() async {
    if (_controller.text.trim().isNotEmpty && _isConnected) {
      await _chatService.sendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Tư vấn trực tuyến", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF3D5AFE),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          if (!_isConnected)
            const LinearProgressIndicator(
                backgroundColor: Colors.orange,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white)
            ),

          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text("Chưa có tin nhắn nào...", style: TextStyle(color: Colors.grey)))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildChatBubble(_messages[index]),
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[100],
              backgroundImage: (msg['avatar'] != null && msg['avatar'].isNotEmpty)
                  ? NetworkImage("${Utils.baseUrl}${msg['avatar']}")
                  : null,
              child: msg['avatar'] == null ? const Icon(Icons.person, size: 20) : null,
            ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe)
                  Padding(
                    padding: const EdgeInsets.only(left: 5, bottom: 2),
                    child: Text(msg['user'] ?? "", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF3D5AFE) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(15),
                      topRight: const Radius.circular(15),
                      bottomLeft: Radius.circular(isMe ? 15 : 0),
                      bottomRight: Radius.circular(isMe ? 0 : 15),
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                    ],
                  ),
                  child: Text(
                    msg['message'] ?? "",
                    style: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (isMe)
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue[100],
              backgroundImage: (msg['avatar'] != null && msg['avatar'].isNotEmpty)
                  ? NetworkImage("${Utils.baseUrl}${msg['avatar']}")
                  : null,
              child: msg['avatar'] == null ? const Icon(Icons.person, size: 20) : null,
            ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: "Nhập tin nhắn...",
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF3D5AFE),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}