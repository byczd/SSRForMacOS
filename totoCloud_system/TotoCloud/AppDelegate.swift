//
//  AppDelegate.swift
//  TotoCloud
//
//  Created by 黄龙 on 2023/4/11.
//

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
//    @IBOutlet var window: NSWindow!

    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var switchLabel: NSMenuItem! //代理状态menuItem
    @IBOutlet weak var toggleRunning: NSMenuItem!
    
    @IBOutlet weak var pacItem: NSMenuItem!
    @IBOutlet weak var globalItem: NSMenuItem!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    private var mainWC: MainWindowController?
    private var toastW: ToastWindowController!
//    private var settingsW: SettingsWIndowController!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        showStatusItem()
        loadProxyConfig()
        
        NotificationCenter.default.addObserver(forName: NOTIFY_UPDATE_RUNNING_MODE_MENU, object: nil, queue: OperationQueue.main) { (noti) in
//代理模式变更通知
            self.updateRunningModeMenu()
        }
        
        NotificationCenter.default.addObserver(forName: NOTIFY_REFRESH_SHADOWSOCKSPORT, object: nil, queue: OperationQueue.main) { (noti) in
            self.getShadowsocksPort(noti: noti)
        }
        
        NotificationCenter.default.addObserver(forName: NOTIFY_REFRESH_ROUTE_STATE, object: nil, queue: OperationQueue.main) { (noti) in
            self.refresh()
            if let state = noti.object {
                let iState = state as! Int
                if 0 == iState{
                    self.makeToast("Proxy: Off".localized)
                }else if 2 == iState{
                    self.makeToast("Proxy: On".localized)
                }
            }
        }
        
        // Insert code here to initialize your application
        mainWC = MainWindowController.init("totoCloud")
//        MainWindowController(windowNibName: "MainWindowController")
        mainWC?.window?.center()
        mainWC?.window?.orderFront(nil)
        mainWC?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    @IBAction func quit(_ sender: NSMenuItem) {
        NotificationCenter.default.removeObserver(self)
        
        if AppDelegate.getLauncherStatus() == false {
            RemovePrivoxy { (s) in
                NSApplication.shared.terminate(self)
            }
        } else {
            NSApplication.shared.terminate(self)
        }
    }
    
    @IBAction func powerSwitch(_ sender: NSMenuItem) {
//代理开启-关闭切换
        self.toggle { (s) in
            self.updateMainMenu()
        }
    }
    
    @IBAction func openMainDialog(_ sender: NSMenuItem) {
//显示主窗口
        if mainWC == nil{
            mainWC = MainWindowController.init("totoCloud")
            mainWC?.window?.center()
            mainWC?.window?.orderFront(nil)
        }
        mainWC?.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func pacMode(_ sender: NSMenuItem) {
        Mode.switchTo(.PAC)
    }
    
    @IBAction func globalMode(_ sender: NSMenuItem) {
        Mode.switchTo(.GLOBAL)
    }
    
    private func refresh() {
        DispatchQueue.main.async {
            self.updateMainMenu()
            self.updateRunningModeMenu()
        }
    }
    
//显示拖盘图标
    func showStatusItem(){
        let icon = NSImage(named: "close")
        statusItem.button?.image = icon
        statusItem.menu = statusMenu
    }

    func updateRunningModeMenu() {
        let defaults = UserDefaults.standard
        let mode = defaults.string(forKey: USERDEFAULTS_RUNNING_MODE)

        pacItem.state = NSControl.StateValue(rawValue: 0)
        globalItem.state = NSControl.StateValue(rawValue: 0)
        if mode == "auto" {
            pacItem.state = NSControl.StateValue(rawValue: 1)
        } else if mode == "global" {
            globalItem.state = NSControl.StateValue(rawValue: 1)
        }
    }
    
    func loadProxyConfig(){
        let defaults = UserDefaults.standard
        defaults.register(defaults: [
//该方法需要提前注册，要不然取得值都是nil。
//该方法是不保存本地的。app重启后数据就会删除。
//该数据的存储方式优先级很低。如果你在本地plist中已经有对应的key值了，会优先使用已有的key值，而不会使用你注册的值。
//如果你使用UserDefaults.standard方式注册，就要使用UserDefaults.standard方式取值。其他方式同理。
            USERDEFAULTS_RUNNING_MODE: "auto",
            USERDEFAULTS_LOCAL_SOCKS5_LISTEN_ADDRESS: "127.0.0.1",
            USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT: NSNumber(value: 10800 as UInt16),
            USERDEFAULTS_LOCAL_HTTP_LISTEN_ADDRESS: "127.0.0.1",
            USERDEFAULTS_LOCAL_HTTP_LISTEN_PORT: NSNumber(value: 10801 as UInt16),
            USERDEFAULTS_PAC_SERVER_LISTEN_ADDRESS: "127.0.0.1",
            USERDEFAULTS_PAC_SERVER_LISTEN_PORT:NSNumber(value: 8090 as UInt16),
            USERDEFAULTS_GFW_LIST_URL: "https://raw.githubusercontent.com/gfwlist/gfwlist/master/gfwlist.txt",
            USERDEFAULTS_ACL_WHITE_LIST_URL: "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/banAD.acl",
            USERDEFAULTS_ACL_AUTO_LIST_URL: "https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/gfwlist-banAD.acl",
            USERDEFAULTS_ACL_PROXY_BACK_CHN_URL:"https://raw.githubusercontent.com/ACL4SSR/ACL4SSR/master/backcn-banAD.acl",
            USERDEFAULTS_AUTO_CONFIGURE_NETWORK_SERVICES: NSNumber(value: true as Bool),
            USERDEFAULTS_LOCAL_HTTP_ON: true,
            USERDEFAULTS_LOCAL_HTTP_FOLLOW_GLOBAL: true,
            USERDEFAULTS_ACL_FILE_NAME: "chn.acl",
            USERDEFAULTS_AUTO_CHECK_UPDATE:false,
            USERDEFAULTS_ENABLE_SHOW_SPEED:false,
            USERDEFAULTS_FIXED_NETWORK_SPEED_VIEW_WIDTH:false
        ])
        
        InstallPrivoxy { (suc) in
            //生成httpProxy后台程序(实现了对web请求的代理,将请求数据socks5转发给trojanClient或ssrClient)
            ProxyConfHelper.install()
            //代理规则服务程序
            SyncPac()
            //配置自动代理规则gfwlist.js
        }
    }
    
    
    func updateMainMenu() {
        let defaults = UserDefaults.standard
        let isOn = defaults.bool(forKey: USERDEFAULTS_TROJAN_ON)
        if isOn {
            switchLabel.title = "Proxy: On".localized
            switchLabel.image = NSImage(named: NSImage.statusAvailableName)
            toggleRunning.title = "Turn Proxy Off".localized
            
            let icon = NSImage(named: "open")
            statusItem.button?.image = icon
            statusItem.menu = statusMenu
        } else {
            switchLabel.title = "Proxy: Off".localized
            switchLabel.image = NSImage(named: NSImage.statusUnavailableName)
            toggleRunning.title = "Turn Proxy On".localized
            
            let icon = NSImage(named: "close")
            statusItem.button?.image = icon
            statusItem.menu = statusMenu
        }
        statusItem.button?.image?.isTemplate = true
    }
    
    private func toggle(finish: @escaping(_ success: Bool)->()) {
        let defaults = UserDefaults.standard
        let isOn = defaults.bool(forKey: USERDEFAULTS_TROJAN_ON)
        if isOn {//on -> off
            defaults.set(false, forKey: USERDEFAULTS_TROJAN_ON)
            stop_TheProxy(AndNoti: true) {}
        } else {
            defaults.set(true, forKey: USERDEFAULTS_TROJAN_ON)
            NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: 1)
            run_TheProxy{
                DispatchQueue.main.async {
                    finish(true)
                }
            }
        }
        defaults.synchronize()
        finish(true)
        
    }
    
    func getShadowsocksPort(noti:Notification){
//通过userInfo传值
       let dict = noti.userInfo
        if dict != nil{
            let sPort = dict!["port"] as! String
            let shadowsocksport = Int(sPort)
//            let proxy = "SOCKS5 127.0.0.1:\(shadowsocksport); SOCKS 127.0.0.1:\(shadowsocksport); DIRECT;";
//            NSLog("\(proxy)")
            UserDefaults.standard.setValue("127.0.0.1", forKey: USERDEFAULTS_LOCAL_SOCKS5_LISTEN_ADDRESS)
            UserDefaults.standard.setValue(NSNumber(value: shadowsocksport!), forKey: USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT)
            UserDefaults.standard.synchronize()
//更新PAC配置到gfwlist.js
//从配置文件中读取此port，并写到PAC代理中，并修改gfwlist.js中的首句
//trojan默认为：var proxy = "SOCKS5 127.0.0.1:10800; SOCKS 127.0.0.1:10800; DIRECT;";
//而ssr则改为：var proxy = "SOCKS5 127.0.0.1:shadowsocksport; SOCKS 127.0.0.1:shadowsocksport; DIRECT;";
            SyncPac()
            let mode = UserDefaults.standard.string(forKey: USERDEFAULTS_RUNNING_MODE)
//开启httpProxy服务
            StartPrivoxy { (success) in
                if success {
//开启系统代理服务配置
//                    if mode == "auto" {
                        ProxyConfHelper.disableProxy("hi")
                        ProxyConfHelper.enablePACProxy("hi") //开启规则过滤
//                    } else if mode == "global" {
//                        ProxyConfHelper.disableProxy("hi")
//                        ProxyConfHelper.enableGlobalProxy()
//                    }
                    UserDefaults.standard.set(true, forKey: USERDEFAULTS_TROJAN_ON)
                    UserDefaults.standard.synchronize()
                    NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: 2)
                }
                else{
                    NSLog("---StartPrivoxy.failed")
                    stop_TheProxy(AndNoti: true){
                    }
                }
                
            }
            
        }
    }
    
    func makeToast(_ message: String) {
        if self.toastW != nil {
            self.toastW.close()
        }
        let c = ToastWindowController.init(windowNibName: "ToastWindowController")
        self.toastW = c
        c.message = message
        c.showWindow(self)
        c.fadeInHud()
    }
    
    static func getLauncherStatus() -> Bool {
        return LoginServiceKit.isExistLoginItems()
    }
    
    static func setLauncherStatus(open: Bool) {
        if open {
            LoginServiceKit.addLoginItems()
        } else {
            LoginServiceKit.removeLoginItems()
        }
    }

}

