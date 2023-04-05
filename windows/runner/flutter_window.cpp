#include "flutter_window.h"
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <optional>
#include "vendor/json/single_include/nlohmann/json.hpp"

using json = nlohmann::json;

#include "flutter/generated_plugin_registrant.h"

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());


  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "context_menu",
      &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "showContextMenu") {
          const std::string* str = std::get_if<std::string>(call.arguments());
          if(str != nullptr){
            json data =  json::parse(*str);
            std::cout << data["x"].get<float>() << " " << data["y"].get<float>() << std::endl;
          
            HMENU hPopupMenu = CreatePopupMenu();
            InsertMenu(hPopupMenu, 0, MF_BYPOSITION | MF_STRING, ID_CLOSE, (LPCWSTR)"Exit");
            InsertMenu(hPopupMenu, 0, MF_BYPOSITION | MF_STRING, ID_EXIT, (LPCWSTR)"Play");
            SetForegroundWindow(hWnd);
            TrackPopupMenu(hPopupMenu, TPM_BOTTOMALIGN | TPM_LEFTALIGN, (int)(data["x"].get<float>()), (int)(data["y"].get<float>()), 0, hWnd, NULL);

            return result->Success();
          }
          return result->Error("Error BAD CALL","Make sure your arguments are a json encoded string with x,y coordinates");
        } else {
          result->NotImplemented();
        }
      });


  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
