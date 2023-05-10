//
//  LaunchAgentHelper.swift
//  totoCloud
//
//  Created by cxjdfb on 2020/5/5.
//  Copyright © 2020 cxjdfb. All rights reserved.
//

import Foundation
import CommonCrypto


extension Data {
    func sha1() -> String {
        let data = self
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1((data as NSData).bytes, CC_LONG(data.count), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joined(separator: "")
    }
}

func getFileSHA1Sum(_ filepath: String) -> String {
    let fileMgr = FileManager.default
    if fileMgr.fileExists(atPath: filepath) {
        if let data = try? Data(contentsOf: URL(fileURLWithPath: filepath)) {
            return data.sha1()
        }
    }
    return ""
}

func SyncTrojan(finish: @escaping(_ success: Bool)->()) {
    func Sync(_ suc: Bool){
        SyncPrivoxy {
            SyncPac()
            finish(suc)
        }
    }
    
    Sync(true)
}

func generatePrivoxyLauchAgentPlist() -> Bool {
    let privoxyPath = NSHomeDirectory() + APP_SUPPORT_DIR + "privoxy"
    let logFilePath = NSHomeDirectory() + "/Library/Logs/privoxy.log"
    let launchAgentDirPath = NSHomeDirectory() + LAUNCH_AGENT_DIR
    let plistFilepath = launchAgentDirPath + LAUNCH_AGENT_CONF_PRIVOXY_NAME

    // Ensure launch agent directory is existed.
    let fileMgr = FileManager.default
    if !fileMgr.fileExists(atPath: launchAgentDirPath) {
        try! fileMgr.createDirectory(atPath: launchAgentDirPath, withIntermediateDirectories: true, attributes: nil)
    }

    let oldSha1Sum = getFileSHA1Sum(plistFilepath)

    let arguments = [privoxyPath, "--no-daemon", "privoxy.config"]

    // For a complete listing of the keys, see the launchd.plist manual page.
    let dict: NSMutableDictionary = [
        "Label": "MacOS.Trojan.http",
        "WorkingDirectory": NSHomeDirectory() + APP_SUPPORT_DIR,
        "KeepAlive": true,
        "StandardOutPath": logFilePath,
        "StandardErrorPath": logFilePath,
        "ProgramArguments": arguments,
        "EnvironmentVariables": ["DYLD_LIBRARY_PATH": NSHomeDirectory() + APP_SUPPORT_DIR]
    ]
    dict.write(toFile: plistFilepath, atomically: true)
    let Sha1Sum = getFileSHA1Sum(plistFilepath)
    if oldSha1Sum != Sha1Sum {
        return true
    } else {
        return false
    }
}

func ReloadConfPrivoxy(finish: @escaping(_ success: Bool)->()) {
    let bundle = Bundle.main
    let installerPath = bundle.path(forResource: "reload_conf_privoxy.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Reload privoxy succeeded.")
        DispatchQueue.main.async {
            finish(true)
        }
    } else {
        NSLog("Reload privoxy failed.")
        DispatchQueue.main.async {
            finish(false)
        }
    }
}

func StartPrivoxy(finish: @escaping(_ success: Bool)->()) {
    if generatePrivoxyLauchAgentPlist() {
        let bundle = Bundle.main
        let installerPath = bundle.path(forResource: "start_privoxy.sh", ofType: nil)
        let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            NSLog("Start privoxy succeeded.")
            DispatchQueue.main.async {
                finish(true)
            }
        } else {
            NSLog("Start privoxy failed.")
            DispatchQueue.main.async {
                finish(false)
            }
        }
    } else {
        ReloadConfPrivoxy { (success) in
            DispatchQueue.main.async {
                finish(success)
            }
        }
    }
}

func StopPrivoxy(finish: @escaping(_ success: Bool)->()) {
    let bundle = Bundle.main
    let installerPath = bundle.path(forResource: "stop_privoxy.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Stop privoxy succeeded.")
        DispatchQueue.main.async {
            finish(true)
        }
    } else {
        NSLog("Stop privoxy failed.")
        DispatchQueue.main.async {
            finish(false)
        }
    }
}

//生成第三方httpProxy后台程序
func InstallPrivoxy(finish: @escaping(_ success: Bool)->()) {
    let fileMgr = FileManager.default
    let homeDir = NSHomeDirectory() //新建的工程里 .entitlements默认自带 App Sandbox=YES，和Access User Selected Files (Read Only)=YES两项
//App Sandbox=YES时,则homeDir="/Users/chenzhidong/Library/Containers/com.adong.mac.TotoCloud/Data/Library/Application Support/tqqCloud/"
//App Sandbox=NO，则homeDir="/Users/chenzhidong" （TMD，原来是这个）
//而且App Sandbox=YES时，NSAppleScript执行with administrator privileges提权时，会失败，不会弹出授权输入密码对话框(fuck搞半天原来是这个)
    let appSupportDir = homeDir+APP_SUPPORT_DIR
    if !fileMgr.fileExists(atPath: appSupportDir + "privoxy-\(PRIVOXY_VERSION)/privoxy") || !fileMgr.fileExists(atPath: appSupportDir + "libpcre.1.dylib") {
        let bundle = Bundle.main
        let installerPath = bundle.path(forResource: "install_privoxy.sh", ofType: nil)
        let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
        task.waitUntilExit()
        if task.terminationStatus == 0 {
            NSLog("Install privoxy succeeded.")
            DispatchQueue.main.async {
                finish(true)
            }
        } else {
            NSLog("Install privoxy failed.")
            DispatchQueue.main.async {
                finish(false)
            }
        }
    } else {
        finish(true)
    }
}

func RemovePrivoxy(finish: @escaping(_ success: Bool)->()) {
    let bundle = Bundle.main
    let installerPath = bundle.path(forResource: "remove_privoxy.sh", ofType: nil)
    let task = Process.launchedProcess(launchPath: installerPath!, arguments: [""])
    task.waitUntilExit()
    if task.terminationStatus == 0 {
        NSLog("Remove privoxy succeeded.")
        DispatchQueue.main.async {
            finish(true)
        }
    } else {
        NSLog("Remove privoxy failed.")
        DispatchQueue.main.async {
            finish(false)
        }
    }
}

func writePrivoxyConfFile() -> Bool {
    do {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main
        let examplePath = bundle.path(forResource: "privoxy.config.example", ofType: nil)
        var example = try String(contentsOfFile: examplePath!, encoding: .utf8)
        example = example.replacingOccurrences(of: "{http}", with: defaults.string(forKey: USERDEFAULTS_LOCAL_HTTP_LISTEN_ADDRESS)! + ":" + String(defaults.integer(forKey: USERDEFAULTS_LOCAL_HTTP_LISTEN_PORT)))
        example = example.replacingOccurrences(of: "{socks5}", with: defaults.string(forKey: USERDEFAULTS_LOCAL_SOCKS5_LISTEN_ADDRESS)! + ":" + String(defaults.integer(forKey: USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT)))
        let data = example.data(using: .utf8)

        let filepath = NSHomeDirectory() + APP_SUPPORT_DIR + "privoxy.config"

        let oldSum = getFileSHA1Sum(filepath)
        try data?.write(to: URL(fileURLWithPath: filepath), options: .atomic)//该文件创建后，会自动移除掉
        let newSum = getFileSHA1Sum(filepath)

        if oldSum == newSum {
            return false
        }

        return true
    } catch {
        NSLog("Write privoxy file failed.")
    }
    return false
}

func removePrivoxyConfFile() {
    do {
        let filepath = NSHomeDirectory() + APP_SUPPORT_DIR + "privoxy.config"
        try FileManager.default.removeItem(atPath: filepath)
    } catch {
        
    }
}

func SyncPrivoxy(finish: @escaping()->()) {
    var changed: Bool = false
    changed = changed || generatePrivoxyLauchAgentPlist()
    changed = changed || writePrivoxyConfFile()
    let on = UserDefaults.standard.bool(forKey: USERDEFAULTS_LOCAL_HTTP_ON) && UserDefaults.standard.bool(forKey: USERDEFAULTS_TROJAN_ON)
    if on {
        ReloadConfPrivoxy { (success) in
            finish()
        }
    } else {
        StopPrivoxy { (success) in
            removePrivoxyConfFile()
            finish()
        }
    }
  
}

func stop_TheProxy(AndNoti notiState:Bool,finish: @escaping()->()){
    stopSSRProxyLoop()
    stopTrojanProxyLoop()
    StopPrivoxy { (ss) in
        ProxyConfHelper.stopPACServer()
        ProxyConfHelper.disableProxy("hi")
        let defaults = UserDefaults.standard
        defaults.set(false, forKey: USERDEFAULTS_TROJAN_ON)
        defaults.synchronize()
        if notiState {
            NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: 0)
        }
        finish()
    }
}


//MARK: 纯代码启动代理ssrClient(不使用第3方后台程序,ProxyConfHelper除外)
func run_TheProxy(finish: @escaping()->()){
    let walltime = DispatchWallTime.now()+1.25
    DispatchQueue.global().asyncAfter(wallDeadline: walltime){
        if let lastDict = UserDefaults.standard.dictionary(forKey: "Last.Proxy.Node.Dict"){
            let type = lastDict["type"] as! String
            if type == "ssr" {
                UserDefaults.standard.set(lastDict, forKey: "OC_SSR_SELECTED_CONFIG")
                UserDefaults.standard.synchronize()//保存至ssr配置供ssr线程调用
                doRunSSRProxyLoop()
            }else { //if type == "trojan"
    //以lastDict为基础，生成trojan格式文件，然后json写入到trojan_config.json中，供trojan线程调用
                let trojanProfile = TrojanConfig()
                trojanProfile.loadDefaultConfig()
                trojanProfile.client?.run_type = "client"
                trojanProfile.client?.uuid = lastDict["Id"] as! String
                trojanProfile.client?.remote_addr = lastDict["ServerHost"] as! String
                trojanProfile.client?.remote_port = (lastDict["ServerPort"] as! NSNumber).intValue
                trojanProfile.client?.password = [lastDict["Password"] as! String]
                trojanProfile.client?.local_addr = "127.0.0.1"
                trojanProfile.client?.local_port = 10800
                trojanProfile.client?.log_level = 1
                trojanProfile.client?.group = lastDict["nodeGroup"] as! String
                trojanProfile.client?.ssl.verify = lastDict["SSLVerify"] as? Bool
                if trojanProfile.client?.ssl.verify == true {
                    let resfile = "cacert.pem"
                    let cacertPath = Bundle.main.path(forResource: resfile, ofType: nil)
                    trojanProfile.client?.ssl.cert = cacertPath //如果是纯代码启动trojan且verify为true,需设置证书文件
                }
                trojanProfile.saveConfig()
                doRunTrojanProxyLoop()
            }
        }
        
        finish()
    }
}

func stopSSRProxyLoop(){
    ShadowsocksRunner.stopSSRProxy()
}

func doRunSSRProxyLoop(){
    let ssrQueue = DispatchQueue(label: "launch.ssr.backrun")
    ssrQueue.async {
        if ShadowsocksRunner.runProxy(nil){
            sleep(1);
        } else {
            sleep(2);
        }
    }
}

//MARK: 代码启动或停止trojanClient
func stopTrojanProxyLoop(){
    ShadowsocksRunner.stopTrojan()
}

func doRunTrojanProxyLoop(){
    ShadowsocksRunner.runTrojan()

    SyncPac()
    let mode = UserDefaults.standard.string(forKey: USERDEFAULTS_RUNNING_MODE)
//开启httpProxy服务
    StartPrivoxy { (success) in
        if success {
//开启系统代理服务配置
//            if mode == "auto" {
                ProxyConfHelper.disableProxy("hi")
                ProxyConfHelper.enablePACProxy("hi") //开启规则过滤
//            } else if mode == "global" {
//                ProxyConfHelper.disableProxy("hi")
//                ProxyConfHelper.enableGlobalProxy()
//            }
            UserDefaults.standard.set(true, forKey: USERDEFAULTS_TROJAN_ON)
            UserDefaults.standard.synchronize()
            NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: 2)
        }
        else{
            NSLog("---StartPrivoxy.failed")
            stop_TheProxy(AndNoti: true) {}
        }
    }
}
