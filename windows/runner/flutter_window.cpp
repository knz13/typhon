#include "flutter_window.h"

#include <windows.h>
#include <optional>



#include "flutter/generated_plugin_registrant.h"

std::wstring string_to_wstring(const std::string& text) {
    return std::wstring(text.begin(), text.end());
}


FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

void FlutterWindow::CreateMenuInternal(HMENU menu,
                                         std::vector<json>& arguments) {
    auto items = arguments;
    
    for (const auto& item_value : items) {
      auto item = item_value;
      
      auto title = item["title"].get<std::string>();
      UINT_PTR item_id = 0;
      UINT uFlags = MF_STRING;
      if (item.contains("callbackId")){
          int32_t id = atoi(item["callbackId"].get<std::string>().c_str());
          item_id = id;   
          
          AppendMenuW(menu, uFlags, item_id, string_to_wstring(title).data());
          continue;
      }
      else {

        if(!item.contains("subOptions")){
          uFlags |= MF_DISABLED;
          uFlags |= MF_GRAYED;
          AppendMenuW(menu, uFlags, item_id, string_to_wstring(title).data());
          continue;
        }
        std::string subOptions = item["subOptions"].get<std::string>();
        
        auto sub_items = json::parse(subOptions).get<std::vector<json>>();
        if (sub_items.size() > 0) {
          uFlags |= MF_POPUP;
          HMENU sub_menu = CreatePopupMenu();
          CreateMenuInternal(sub_menu, sub_items);
          item_id = reinterpret_cast<UINT_PTR>(sub_menu);
          
        }
        
        AppendMenuW(menu, uFlags, item_id, string_to_wstring(title).data());
        

      }
      
    }
}

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

  if(!channel){
    channel = std::unique_ptr<flutter::MethodChannel<>>(new flutter::MethodChannel(flutter_controller_->engine()->messenger(), "context_menu",
      &flutter::StandardMethodCodec::GetInstance()));
  }
 
  channel.get()->SetMethodCallHandler(
      [=](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "showContextMenu") {
          const std::string* str = std::get_if<std::string>(call.arguments());
          if(str != nullptr){
            json data =  json::parse(*str);
          
            HMENU hPopupMenu = CreatePopupMenu();
            auto val = data["options"].get<std::vector<json>>();
            
            CreateMenuInternal(hPopupMenu,val);
           
            POINT p;
            GetCursorPos(&p);

            TrackPopupMenu(hPopupMenu, TPM_BOTTOMALIGN | TPM_LEFTALIGN,p.x,p.y , 0, GetHandle(), NULL);

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
  switch(message){
    case WM_COMMAND:
      channel.get()->InvokeMethod("context_menu",std::make_unique<flutter::EncodableValue>(static_cast<int32_t>(wparam)));
      break;
  }
  
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
