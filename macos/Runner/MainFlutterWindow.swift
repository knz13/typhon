import Cocoa
import FlutterMacOS
import AppKit

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

public class ContextMenuPlugin: NSObject, FlutterPlugin {
    
    static var instance: ContextMenuPlugin?
    var _callbackMap = [Int: (() -> Void)]()

    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "context_menu", binaryMessenger: registrar.messenger)
        let instance = ContextMenuPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public static func registerOnStart(with controller: FlutterViewController){
        let channel = FlutterMethodChannel(name: "context_menu",binaryMessenger: controller.engine.binaryMessenger)
            
        
        
        instance = ContextMenuPlugin()
        
        channel.setMethodCallHandler(instance?.handle)
        
    }
    
    public func buildMenuFromArguments(options: [[String: Any]],menu: NSMenu) {
        
        for option in options {
            let title = option["title"] as? String ?? ""
            let type: String = option["type"] as? String ?? "General"
            let enabled: Int = Int((option["enabled"] as? String ?? "1")) ?? 1
           
            let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
            let subOptionsJson = try? JSONSerialization.jsonObject(with: (option["subOptions"] as? String ?? "").data(using: .utf8) ?? Data(), options: [])
            
            if (enabled == 0) {
                menuItem.isEnabled = false
                menu.addItem(menuItem)
                continue
            }

            if (type == "Separator") {
                menu.addItem(.separator());
                continue;
            }

            if let subOptions = subOptionsJson as? [[String:Any]] {
                
                let subMenu = NSMenu()
                
                buildMenuFromArguments(options: subOptions, menu: subMenu)
                
                menuItem.submenu = subMenu
                
                
            } else if let callbackId = option["callbackId"] as? String {
                
                menuItem.target = self
                menuItem.action = #selector(handleMenuItem(_:))
                menuItem.representedObject = NSNumber(value: Int(callbackId) ?? -1)
            }
            menu.addItem(menuItem)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
            
            switch(call.method){
            case "showContextMenu":
                
                let jsonArgs = convertToDictionary(text: call.arguments as? String ?? "")
                
                if let arguments = jsonArgs {
                    let x = arguments["x"] as? Double ?? 0
                    let y = arguments["y"] as? Double ?? 0
                    let options = arguments["options"] as? [[String: Any]] ?? []
                    
                    let menu = NSMenu()
                    menu.title = "Context menu"
                    buildMenuFromArguments(options: options, menu: menu)
                    
                    
                    menu.popUp(positioning: nil, at: NSPoint(x: x, y: y), in: MainFlutterWindow.instance?.contentView)
                }
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @objc func handleMenuItem(_ sender: NSMenuItem) {
        
        if let callbackId = sender.representedObject as? NSNumber {
            
            let arguments: [String: Any] = ["callbackId": callbackId.intValue]
            let methodChannel = FlutterMethodChannel(name: "context_menu", binaryMessenger: MainFlutterWindow.flutterViewController!.engine.binaryMessenger)
            methodChannel.invokeMethod("context_menu", arguments: arguments)
        }
    }
}

public class NativeWindowInterfacePlugin: NSObject, FlutterPlugin {

    var createdView: NSView?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "nativeWindowInterfaceChannel", binaryMessenger: registrar.messenger)
        let instance = NativeWindowInterfacePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
    }
    
    public static func registerOnStart(with controller: FlutterViewController){
        let channel = FlutterMethodChannel(name: "nativeWindowInterfaceChannel",binaryMessenger: controller.engine.binaryMessenger)
            
        let instance = NativeWindowInterfacePlugin()
        
        channel.setMethodCallHandler(instance.handle)
        print("registered plugin!")
    }
   

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "createRenderableView" {
            let args = convertToDictionary(text: call.arguments as? String ?? "")
            let x = args?["x"] as? Double ?? 0.0
            let y = args?["y"] as? Double ?? 0.0
            
            let width = args?["width"] as? Double ?? 0
            let height = args?["height"] as? Double ?? 0
            
            if let view = createdView {
                print("called create for NSView before deleting current NSView")
                view.removeFromSuperview()
            }
            createdView = NSView()
            let frame = NSRect(x:x,y:y,width:width,height:height)
            createdView!.frame = frame
            createdView!.wantsLayer = true
            
            MainFlutterWindow.flutterViewController!.view.addSubview(createdView!, positioned: .above, relativeTo: nil)
            MainFlutterWindow.instance?.contentViewController!.view.setNeedsDisplay(createdView!.frame)
            
            result(UInt64(bitPattern:Int64(Int(bitPattern: Unmanaged.passRetained(createdView!).toOpaque()))))
            /* 
            let widgetId = args?["widgetId"] as? Int ?? -1
            
            let widgetView = getWidgetView(widgetId)
            if let actualWidgetView = widgetView{
                result(UInt64(bitPattern:Int64(Int(bitPattern: Unmanaged.passRetained(actualWidgetView).toOpaque()))))
            }
            else {
                print("Found no view with tag")
                print(widgetId)
                result(UInt64(0))
            } */
            
        } else if call.method == "setFrameRenderableView" {
            let args = convertToDictionary(text: call.arguments as? String ?? "")
            let x = args?["x"] as? Double ?? 0
            let y = args?["y"] as? Double ?? 0
            let width = args?["width"] as? Double ?? 0
            let height = args?["height"] as? Double ?? 0
            
            if let view = createdView {
                view.frame = NSRect(x:x,y:y,width:width,height:height)
            }
        } else if call.method == "removeRenderableView" {
            if let view = createdView {
                view.removeFromSuperview()
                createdView = nil
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

}

class MainFlutterWindow: NSWindow {
    static var instance: MainFlutterWindow?
    static var flutterViewController: FlutterViewController?
        
    
    override func awakeFromNib() {
        MainFlutterWindow.instance = self
        MainFlutterWindow.flutterViewController = FlutterViewController.init()
        MainFlutterWindow.flutterViewController!.view.wantsLayer = true
        let windowFrame = self.frame
        self.contentViewController = MainFlutterWindow.flutterViewController!
        self.setFrame(windowFrame, display: true)

        ContextMenuPlugin.registerOnStart(with: MainFlutterWindow.flutterViewController!)
        NativeWindowInterfacePlugin.registerOnStart(with: MainFlutterWindow.flutterViewController!)
        
        RegisterGeneratedPlugins(registry: MainFlutterWindow.flutterViewController!)
        
        super.awakeFromNib()
    }
    
   
}
