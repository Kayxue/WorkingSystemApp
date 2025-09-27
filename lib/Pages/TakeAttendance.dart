import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rhttp/rhttp.dart';
import 'dart:convert';

import 'package:working_system_app/Others/Utils.dart';

class TakeAttendance extends StatefulWidget {
  final String gigId;
  final String gigTitle;
  final String attendanceTime;
  final String attendanceType;
  final String sessionKey;

  const TakeAttendance({
    super.key,
    required this.gigId,
    required this.gigTitle,
    required this.attendanceTime,
    required this.attendanceType,
    required this.sessionKey,
  });

  @override
  State<TakeAttendance> createState() => _TakeAttendanceState();
}

class _TakeAttendanceState extends State<TakeAttendance> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  String errorMessage = "";
  bool isSendBefore = false;
  bool isLoading = false;
  bool takeAttendanceSucceed = false;

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _handleInputChange(String text) {
    if (text.length == 4 && !isLoading) {
      FocusScope.of(context).unfocus();
      takeAttendance(text);
      _controller.clear();  
    }
    setState(() {});
  }

  Future<void> takeAttendance(String code) async {
    setState(() {
      isLoading = true;
      isSendBefore = true;
    });
    final response = await Utils.client.post(
      "/attendance/check",
      headers: HttpHeaders.rawMap({
        "platform": "mobile",
        "cookie": widget.sessionKey,
      }),
      body: HttpBody.json({"gigId": widget.gigId, "attendanceCode": code, "checkType": widget.attendanceType}),
    );
    if (!mounted) return;

    if (response.statusCode == 400) {
      final body = jsonDecode(response.body);
      await showStatusDialog(
        title: "Failed",
        description: body["message"],
      );
      setState(() {
        isLoading = false;
        takeAttendanceSucceed = false;
        errorMessage = body["message"];
      });
    }else if (response.statusCode != 200) {
      await showStatusDialog(
        title: "Error",
        description: "Failed to take attendance. Please try again.",
      );
      setState(() {
        isLoading = false;
        takeAttendanceSucceed = false;
        errorMessage = "";
      });
    } else {
      await showStatusDialog(
        title: "Success",
        description: "Attendance taken successfully.",
      );
      setState(() {
        isLoading = false;
        takeAttendanceSucceed = true;
      });
    }
    return;
  }

  Future<void> showStatusDialog({
    required String title,
    required String description,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(description),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPinBoxes(String text) {
    List<Widget> boxes = [];
    for (int i = 0; i < 4; i++) {
      bool hasInput = i < text.length;
      boxes.add(
        Container(
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: hasInput ? Colors.blueAccent : Colors.grey.shade400,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            hasInput ? text[i] : '',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: boxes,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentText = _controller.text;

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.gigTitle} - ${widget.attendanceType == "CheckIn" ? "上班打卡" : "下班打卡"}"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Text(
                '請輸入四位數字代碼',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                '打卡時間: ${widget.attendanceTime} (前後30分鐘內有效)',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: 0,
                height: 0,
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLength: 4, 
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: _handleInputChange,
                  decoration: const InputDecoration(counterText: ""), 
                ),
              ),
              GestureDetector(
                onTap: () {
                  _focusNode.requestFocus();
                },
                child: _buildPinBoxes(currentText),
              ),
              const SizedBox(height: 50),
              if (isLoading)
                const Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text('正在發送請求...', style: TextStyle(color: Colors.blueGrey)),
                  ],
                ),
              if (isSendBefore && !isLoading)
                Text(
                  takeAttendanceSucceed ? '打卡成功！' : (errorMessage.isNotEmpty ? '打卡失敗: $errorMessage' : '打卡失敗，請再試一次。'),
                  style: TextStyle(
                    color: takeAttendanceSucceed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}