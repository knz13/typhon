import Cocoa
import FlutterMacOS


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
    
    

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
            switch(call.method){
            case "showContextMenu":
                
                if let arguments = call.arguments as? [String: Any] {
                    let x = arguments["x"] as? Double ?? 0
                    let y = arguments["y"] as? Double ?? 0
                    let options = arguments["options"] as? [[String: Any]] ?? []
                    let menu = NSMenu()
                    menu.title = "Context menu"
                    for option in options {
                        let title = option["title"] as? String ?? ""
                        let menuItem = NSMenuItem(title: title, action: nil, keyEquivalent: "")
                        if let subOptions = option["subOptions"] as? [[String: Any]], subOptions.count > 0 {
                            let subMenu = NSMenu()
                            for subOption in subOptions {
                                let subOptionTitle = subOption["title"] as? String ?? ""
                                let subMenuItem = NSMenuItem(title: subOptionTitle, action: nil, keyEquivalent: "")
                                if let subCallbackId = subOption["callbackId"] as? Int {
                                    subMenuItem.target = self
                                    subMenuItem.action = #selector(handleMenuItem(_:))
                                    subMenuItem.representedObject = NSNumber(value: subCallbackId)
                                }
                                subMenu.addItem(subMenuItem)
                            }
                            menuItem.submenu = subMenu
                        } else if let callbackId = option["callbackId"] as? Int {
                            menuItem.target = self
                            menuItem.action = #selector(handleMenuItem(_:))
                            menuItem.representedObject = NSNumber(value: callbackId)
                        }
                        menu.addItem(menuItem)
                    }
                    
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
            methodChannel.invokeMethod("contextMenuItemSelected", arguments: arguments)
        }
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
}
