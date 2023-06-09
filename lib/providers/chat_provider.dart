import 'package:flutter/material.dart';
import 'package:mobgpt/models/chat_model.dart';
import 'package:mobgpt/services/api_service.dart';

class ChatProvider with ChangeNotifier {
  List<ChatModel> chatlist = [];
  List<ChatModel> get getChatList {
    return chatlist;
  }

  void addUserChat({required String message}) {
    chatlist.add(ChatModel(role: "user", content: message));
    notifyListeners();
  }

  Future<void> sendMessage({required String message}) async {
    chatlist.addAll(await ApiService.sendMessage(message: message));
    notifyListeners();
  }
}
