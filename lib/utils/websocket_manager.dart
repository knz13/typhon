import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:typhon/utils/utils.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

enum WebsocketMessageResponseStatus {
  completedTask,
  error,
  progress,
  internalClientReport
}

enum WebsocketMessageCommand {
  readToImages,
  identifyCircles,
  getCalibration,
  findCircles
}

class WebsocketMessageResponse {
  final WebsocketMessageResponseStatus status;
  final dynamic data;

  WebsocketMessageResponse({required this.status, required this.data});

  factory WebsocketMessageResponse.fromJson(Map<String, dynamic> json) {
    return WebsocketMessageResponse(
        status: WebsocketMessageResponseStatus.values
                .where((element) => element.name == json['status'])
                .firstOrNull ??
            WebsocketMessageResponseStatus.error,
        data: json['data']);
  }
}

class WebSocketManager {
  WebSocketChannel? _channel;
  Stream? _stream;
  bool _isOpen = false;
  final String _url;
  String socketId = '';
  Function(int) onNumberInternalClientsChanged;

  WebSocketManager(String url, {required this.onNumberInternalClientsChanged})
      : _url = url;

  bool isOpen() {
    return _isOpen;
  }

  Future<bool> initialize() async {
    () async {
      bool isConnecting = false;
      while (true) {
        if (!isConnecting) {
          print("Connecting to $_url");
          try {
            _channel = WebSocketChannel.connect(Uri.parse(_url));
            _stream = _channel!.stream.asBroadcastStream();

            isConnecting = true;

            _stream!.listen((event) {
              print("Received: $event");
              try {
                var message = jsonDecode(event);
                if (message['status'] ==
                    WebsocketMessageResponseStatus.internalClientReport.name) {
                  onNumberInternalClientsChanged(
                      message['data']["num_clients"]);
                }
              } catch (e) {
                print(e);
              }
            }, onDone: () {
              print("Connection closed.");
              _isOpen = false;
              isConnecting = false;
            }, onError: (_) {
              print("Connection error.\n$_");
              _isOpen = false;
              isConnecting = false;
            });
            await _channel!.ready.then((value) {
              print("Connection opened.");
              _isOpen = true;
            });

            socketId = Utils.generateRandomHexString(16);

            _channel!.sink.add(jsonEncode({
              'command': 'send_id',
              'data': socketId,
            }));
          } catch (e) {
            print(e);
          }
        }
        await Future.delayed(Duration(seconds: 1));
      }
    }();

    while (true) {
      if (_isOpen) {
        break;
      }
      await Future.delayed(Duration(milliseconds: 100));
    }

    return true;
  }

  StreamSubscription listen(void Function(WebsocketMessageResponse) onMessage,
      {Function? onError, void Function()? onDone}) {
    return _stream!.listen(
      (message) {
        onMessage(WebsocketMessageResponse.fromJson(jsonDecode(message)));
      },
      onError: onError,
      onDone: onDone,
    );
  }

  String getHttpPathFromCommand(WebsocketMessageCommand command) {
    String defaultPath = "http://0.0.0.0:9090/";

    switch (command) {
      case WebsocketMessageCommand.findCircles:
        return "${defaultPath}find_circles";
      case WebsocketMessageCommand.getCalibration:
        return "${defaultPath}get_calibration";
      case WebsocketMessageCommand.identifyCircles:
        return "${defaultPath}identify_circles";
      case WebsocketMessageCommand.readToImages:
        return "${defaultPath}read_to_images";
    }
  }

  Future<void> sendMessage(dynamic message) async {
    _channel!.sink.add(message);

    // wait for message to be sent

    

  }

  void close() {
    _channel!.sink.close();
  }
}
