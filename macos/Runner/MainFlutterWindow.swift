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

class CustomView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Draw the custom view using AppKit APIs
        let path = NSBezierPath(roundedRect: dirtyRect, xRadius: 10, yRadius: 10)
        NSColor.blue.setFill()
        path.fill()
    }
}


class MainFlutterWindow: NSWindow {
    static var instance: MainFlutterWindow?
    static var flutterViewController: FlutterViewController?
        
    
    override func awakeFromNib() {
        MainFlutterWindow.instance = self
        MainFlutterWindow.flutterViewController = FlutterViewController.init()
        let windowFrame = self.frame
        self.contentViewController = MainFlutterWindow.flutterViewController!
        self.setFrame(windowFrame, display: true)

        ContextMenuPlugin.registerOnStart(with: MainFlutterWindow.flutterViewController!)
            
        RegisterGeneratedPlugins(registry: MainFlutterWindow.flutterViewController!)
        
        super.awakeFromNib()
    }
    
    func printViewController(view: NSViewController){
        print(view.description)
        view.children.forEach { controller in
            printViewController(view: controller)
        }
    }
    
    
    override func mouseDown(with event: NSEvent) {
        
        //printViewController(view: MainFlutterWindow.flutterViewController!.engine.)
        
        super.mouseDown(with: event)
    }
}
