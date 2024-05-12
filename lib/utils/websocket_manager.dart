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

  Stream<WebsocketMessageResponse> sendMessageWithResponse(
      WebsocketMessageCommand command, dynamic message,
      {PlatformFile? file}) {
    var controller = StreamController<WebsocketMessageResponse>();

    var httpPath = getHttpPathFromCommand(command);

    var taskId = Utils.generateRandomHexString(16);

    var subscription = listen(
      (message) {
        if (message.data['task_id'] != taskId) {
          return;
        }
        controller.add(WebsocketMessageResponse(
            status: message.status, data: message.data["message"]));
      },
      onError: (error) {
        controller.addError(error);
        controller.close();
      },
      onDone: () => controller.close(),
    );

    switch (command) {
      case WebsocketMessageCommand.findCircles ||
            WebsocketMessageCommand.readToImages:
        if (file == null) {
          throw Exception("File is required for this command");
        }

        var request = http.MultipartRequest('POST', Uri.parse(httpPath));

        request.fields['socket_id'] = socketId;
        request.fields['task_id'] = taskId;
        request.fields['data'] = jsonEncode(message);
        request.headers['Content-Type'] = 'multipart/form-data';
        request.files.add(http.MultipartFile.fromBytes('file', file.bytes!,
            filename: file.name));

        request.send().then((response) async {
          var responseData = await response.stream.bytesToString();

          if (response.statusCode != 200) {
            controller.addError(responseData);
            controller.close();
            return;
          }

          controller
              .add(WebsocketMessageResponse.fromJson(jsonDecode(responseData)));
        }).catchError((error) {
          controller.addError(error);
          controller.close();
        });

        break;
      case WebsocketMessageCommand.getCalibration:
        break;
      case WebsocketMessageCommand.identifyCircles:
        break;
    }

    // Ensure the subscription is cancelled when the stream is closed
    controller.onCancel = () => subscription.cancel();

    return controller.stream;
  }

  void close() {
    _channel!.sink.close();
  }
}
