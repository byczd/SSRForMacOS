//
//  NodeProfile.swift
//  totoCloud
//
//  Created by 黄龙 on 2023/3/27.
//  Copyright © 2023 ParadiseDuo. All rights reserved.
//

import Cocoa

class SSRProfile: NSObject {
    var uuid: String
    var remark:String = ""
    
    var serverHost: String = ""
    var serverPort: uint16 = 8443
    var method:String = "aes-256-cfb"
    var password:String = ""
    
    var ssrProtocol:String = "origin"
    var ssrProtocolParam:String = ""
    var ssrObfs:String = "plain"
    var ssrObfsParam:String = ""
    var nodeGroup: String = "其.它.节.点"
    var nodeClass: Int? //节点等级(是否有普通节点、高级节点分类)
    
    var latency:String? //时延标记
    
    override init() {
        uuid = UUID().uuidString
    }
    
    init(uuid: String) {
        self.uuid = uuid
    }
    
    static func fromDictionary(_ data:[String:AnyObject]) -> SSRProfile {
        let cp = {
            (profile: SSRProfile) in
            profile.serverHost = data["ServerHost"] as! String
            profile.serverPort = (data["ServerPort"] as! NSNumber).uint16Value
            profile.method = (data["Method"] as! String).lowercased()
            profile.password = data["Password"] as! String
            
            if let remark = data["Remark"] {
                profile.remark = remark as! String
            }
            if let ssrObfs = data["ssrObfs"] {
                profile.ssrObfs = (ssrObfs as! String).lowercased()
            }
            if let ssrObfsParam = data["ssrObfsParam"] {
                profile.ssrObfsParam = ssrObfsParam as! String
            }
            if let ssrProtocol = data["ssrProtocol"] {
                profile.ssrProtocol = (ssrProtocol as! String).lowercased()
            }
            if let ssrProtocolParam = data["ssrProtocolParam"]{
                profile.ssrProtocolParam = ssrProtocolParam as! String
            }
            if let nodeGroup = data["nodeGroup"]{
                profile.nodeGroup = nodeGroup as! String
            }
            if let nodeClass = data["nodeClass"]{
                profile.nodeClass = (nodeClass as! NSNumber).intValue
            }
        }
        
        if let id = data["Id"] as? String {
            let profile = SSRProfile(uuid: id)
            cp(profile)
            return profile
        } else {
            let profile = SSRProfile()
            cp(profile)
            return profile
        }
    }
    
    func toDictionary() -> [String:AnyObject] {
        var d = [String:AnyObject]()
        d["Id"] = uuid as AnyObject?
        d["ServerHost"] = serverHost as AnyObject?
        d["ServerPort"] = NSNumber(value: serverPort as UInt16)
        d["Method"] = method as AnyObject?
        d["Password"] = password as AnyObject?
        d["Remark"] = remark as AnyObject?
        d["ssrProtocol"] = ssrProtocol as AnyObject?
        d["ssrProtocolParam"] = ssrProtocolParam as AnyObject?
        d["ssrObfs"] = ssrObfs as AnyObject?
        d["ssrObfsParam"] = ssrObfsParam as AnyObject?
        d["nodeGroup"] = nodeGroup as AnyObject?
        d["type"] = "ssr" as AnyObject?
        d["latency"] = latency as AnyObject?
        if nodeClass != nil {
            d["nodeClass"] = NSNumber(value: nodeClass! as Int)
        }
        return d
    }
    
    func isValid() -> Bool {
        func validateIpAddress(_ ipToValidate: String) -> Bool {
            
            var sin = sockaddr_in()
            var sin6 = sockaddr_in6()
            
            if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
                // IPv6 peer.
                return true
            }
            else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
                // IPv4 peer.
                return true
            }
            
            return false;
        }
        
        func validateDomainName(_ value: String) -> Bool {
            let validHostnameRegex = "^(([a-zA-Z0-9_]|[a-zA-Z0-9_][a-zA-Z0-9\\-_]*[a-zA-Z0-9_])\\.)*([A-Za-z0-9_]|[A-Za-z0-9_][A-Za-z0-9\\-_]*[A-Za-z0-9_])$"
            
            if (value.range(of: validHostnameRegex, options: .regularExpression) != nil) {
                return true
            } else {
                return false
            }
        }
        
        if !(validateIpAddress(serverHost) || validateDomainName(serverHost)){
            return false
        }
        
        if password.isEmpty {
            return false
        }
        
        if (ssrProtocol.isEmpty && !ssrObfs.isEmpty)||(!ssrProtocol.isEmpty && ssrObfs.isEmpty){
            return false
        }
        
        return true
    }
    
    func appendNewNode(){
        //读取全部的节点，然后将本节点续在后面，再保存整个节点组
        let defaults = UserDefaults.standard
        if let _profiles = defaults.array(forKey: NODE_PROFILE_KEY) {
            var profiles = _profiles
            profiles.append(self.toDictionary())
            defaults.setValue(profiles, forKey: NODE_PROFILE_KEY)
        }
        else{
            let profiles = [self.toDictionary()]
            defaults.setValue(profiles, forKey: NODE_PROFILE_KEY)
        }
        defaults.synchronize()
    }
    
}

class TrojanProfile: NSObject {
    var uuid: String
    var remark:String = ""
    
    var serverHost: String = ""
    var serverPort: uint16 = 8443
    var password:String = ""
    var sslVerify:Bool = false
    
    var nodeGroup: String = "其.它.节.点"
    
    var latency:String? //时延标记
    
    override init() {
        uuid = UUID().uuidString
    }
    
    init(uuid: String) {
        self.uuid = uuid
    }
    
    static func fromDictionary(_ data:[String:AnyObject]) -> TrojanProfile {
        let cp = {
            (profile: TrojanProfile) in
            profile.serverHost = data["ServerHost"] as! String
            profile.serverPort = (data["ServerPort"] as! NSNumber).uint16Value
            profile.password = data["Password"] as! String
            profile.sslVerify = data["SSLVerify"] as! Bool
            if let remark = data["Remark"] {
                profile.remark = remark as! String
            }
            if let nodeGroup = data["nodeGroup"]{
                profile.nodeGroup = nodeGroup as! String
            }
        }
        
        if let id = data["Id"] as? String {
            let profile = TrojanProfile(uuid: id)
            cp(profile)
            return profile
        } else {
            let profile = TrojanProfile()
            cp(profile)
            return profile
        }
    }
    
    func toDictionary() -> [String:AnyObject] {
        var d = [String:AnyObject]()
        d["Id"] = uuid as AnyObject?
        d["ServerHost"] = serverHost as AnyObject?
        d["ServerPort"] = NSNumber(value: serverPort as UInt16)
        d["SSLVerify"] = sslVerify as AnyObject?
        d["Password"] = password as AnyObject?
        d["Remark"] = remark as AnyObject?
        d["nodeGroup"] = nodeGroup as AnyObject?
        d["type"] = "trojan" as AnyObject?
        d["latency"] = latency as AnyObject?
        return d
    }
    
    func isValid() -> Bool {
        func validateIpAddress(_ ipToValidate: String) -> Bool {
            
            var sin = sockaddr_in()
            var sin6 = sockaddr_in6()
            
            if ipToValidate.withCString({ cstring in inet_pton(AF_INET6, cstring, &sin6.sin6_addr) }) == 1 {
                // IPv6 peer.
                return true
            }
            else if ipToValidate.withCString({ cstring in inet_pton(AF_INET, cstring, &sin.sin_addr) }) == 1 {
                // IPv4 peer.
                return true
            }
            
            return false;
        }
        
        func validateDomainName(_ value: String) -> Bool {
            let validHostnameRegex = "^(([a-zA-Z0-9_]|[a-zA-Z0-9_][a-zA-Z0-9\\-_]*[a-zA-Z0-9_])\\.)*([A-Za-z0-9_]|[A-Za-z0-9_][A-Za-z0-9\\-_]*[A-Za-z0-9_])$"
            
            if (value.range(of: validHostnameRegex, options: .regularExpression) != nil) {
                return true
            } else {
                return false
            }
        }
        
        if !(validateIpAddress(serverHost) || validateDomainName(serverHost)){
            return false
        }
        
        if password.isEmpty {
            return false
        }

        return true
    }
    
    func appendNewNode(){
        //读取全部的节点，然后将本节点续在后面，再保存整个节点组
        let defaults = UserDefaults.standard
        if let _profiles = defaults.array(forKey: NODE_PROFILE_KEY) {
            var profiles = _profiles
            profiles.append(self.toDictionary())
            defaults.setValue(profiles, forKey: NODE_PROFILE_KEY)
        }
        else{
            let profiles = [self.toDictionary()]
            defaults.setValue(profiles, forKey: NODE_PROFILE_KEY)
        }
        defaults.synchronize()
    }
    
    
}


//MARK: Trojan-Config-model
//（相当于#pragma mark}
struct Client: Codable {
//trojan:
    var run_type: String
    var local_addr: String
    var local_port: Int
    var password: [String]
    var remote_addr: String
    var remote_port: Int
    var log_level: Int?
    var ssl: SSL
    var tcp: TCP
    var uuid: String
    var group: String = "trojan"
    
//CodingKeys的用法：
//有时后台系统使用的命名规则有可能与前端不一致，比如后台字段返回下划线命名法，而一般我们使用驼峰命名法，
//所以在字段映射的时候就需要修改一下，例如后台返回local_addr而不是localAddr。
//有两种解决：
//1.实现CodingKey协议 进行枚举映射；(注意 1.需要遵守Codingkey  2.每个字段都要枚举)
//2.使用keyDecodingStrategy处理，此处暂不介绍。
    private enum CodingKeys: String, CodingKey {
        case run_type = "run_type" // = 后为后台返回的字段名
        case local_addr = "local_addr"
        case local_port = "local_port"
        case remote_addr = "remote_addr"
        case remote_port = "remote_port"
        case password = "password"
        case log_level = "log_level"
        case ssl = "ssl"
        case tcp = "tcp"
        case uuid = "uuid"
        case group = "group"
    }
    
//将model转化成json格式数据
    func json() -> [String: AnyObject] {
        let c = self
        
        let ssl: [String: AnyObject] = ["verify": NSNumber(value: c.ssl.verify ?? true) as AnyObject,
                                        "verify_hostname": NSNumber(value: c.ssl.verify_hostname ?? true) as AnyObject,
                                        "cert": c.ssl.cert as AnyObject,
                                        "cipher": c.ssl.cipher as AnyObject,
                                        "cipher_tls13": c.ssl.cipher_tls13 as AnyObject,
                                        "sni": c.ssl.sni as AnyObject,
                                        "alpn": c.ssl.alpn as AnyObject,
                                        "reuse_session": NSNumber(value: c.ssl.reuse_session ?? true) as AnyObject,
                                        "session_ticket": NSNumber(value: c.ssl.session_ticket ?? false) as AnyObject,
                                        "curves": c.ssl.curves as AnyObject,
                                        "plain_http_response": c.ssl.plain_http_response as AnyObject,
                                        "dhparam": c.ssl.dhparam as AnyObject,
                                        "prefer_server_cipher": NSNumber(value: c.ssl.prefer_server_cipher ?? true) as AnyObject
                                       ]
        
        let tcp: [String: AnyObject] = ["no_delay": NSNumber(value: c.tcp.no_delay ?? true) as AnyObject,
                                        "keep_alive": NSNumber(value: c.tcp.keep_alive ?? true) as AnyObject,
                                        "reuse_port": NSNumber(value: c.tcp.reuse_port ?? false) as AnyObject,
                                        "fast_open": NSNumber(value: c.tcp.fast_open ?? false) as AnyObject,
                                        "fast_open_qlen": NSNumber(value: c.tcp.fast_open_qlen ?? 20) as AnyObject
                                       ]
        var uuid = UUID().uuidString
        if c.uuid.count > 0 {
            uuid = c.uuid
        }
        let conf: [String: AnyObject] = ["run_type": c.run_type as AnyObject,
                                         "local_addr": c.local_addr as AnyObject,
                                         "local_port": NSNumber(value: c.local_port) as AnyObject,
                                         "remote_addr": c.remote_addr as AnyObject,
                                         "remote_port": NSNumber(value: c.remote_port) as AnyObject,
                                         "password": c.password as AnyObject,
                                         "log_level": NSNumber(value: c.log_level ?? 1) as AnyObject,
                                         "ssl": ssl as AnyObject,
                                         "tcp": tcp as AnyObject,
                                         "uuid": uuid as AnyObject,
                                         "group": c.group as AnyObject
                                        ]
        
        return conf
    }
//将json格式数据转化成字符串
    func jsonString() -> String {
        do {
            var data: Data
            if #available(OSX 10.13, *) {
                data =  try JSONSerialization.data(withJSONObject: self.json(), options: [.prettyPrinted, .sortedKeys]) //.prettyPrinted填充换行格式
            } else {
                data =  try JSONSerialization.data(withJSONObject: self.json(), options: [.prettyPrinted])
            }
            let convertedString = String(data: data, encoding: String.Encoding.utf8)
            return convertedString ?? ""
        } catch let myJSONError {
            print(myJSONError)
        }
        return ""
    }
}


struct SSL: Codable {
    var verify: Bool?
    var verify_hostname: Bool?
    var cert: String?
    var cipher: String?
    var cipher_tls13: String?
    var sni: String?
    var alpn: [String]?
    var reuse_session: Bool?
    var session_ticket: Bool?
    var curves: String?
    var plain_http_response: String?
    var dhparam: String?
    var prefer_server_cipher: Bool?
    
    private enum CodingKeys: String, CodingKey {
        case verify = "verify"
        case verify_hostname = "verify_hostname"
        case cert = "cert"
        case cipher = "cipher"
        case cipher_tls13 = "cipher_tls13"
        case sni = "sni"
        case alpn = "alpn"
        case reuse_session = "reuse_session"
        case session_ticket = "session_ticket"
        case curves = "curves"
        case plain_http_response = "plain_http_response"
        case dhparam = "dhparam"
        case prefer_server_cipher = "prefer_server_cipher"
    }
}


struct TCP: Codable {
    var no_delay: Bool?
    var keep_alive: Bool?
    var reuse_port: Bool?
    var fast_open: Bool?
    var fast_open_qlen: Int?

    private enum CodingKeys: String, CodingKey {
        case no_delay = "no_delay"
        case keep_alive = "keep_alive"
        case reuse_port = "reuse_port"
        case fast_open = "fast_open"
        case fast_open_qlen = "fast_open_qlen"
    }
}

//MARK: 当前所选的节点数据处理
class TrojanConfig {
    
    static let shared = TrojanConfig() //static let 创建单例
    
    var client: Client?
    var name = "Default"
    
    var latency = NSNumber(value: Double.infinity)
    
    var json: [String: AnyObject] {
        get {
            return self.client!.json()
        }
    }
    
    var jsonString: String {
        get {
            return self.client!.jsonString()
        }
    }
    
//保存当前所选节点的host:port到沙箱，同将节点数据写入CONFIG_PATH(trojan_client.json)中
    func saveConfig() {
//更新本地socks地址端口
            UserDefaults.standard.setValue(self.client!.local_addr, forKey: USERDEFAULTS_LOCAL_SOCKS5_LISTEN_ADDRESS)
            UserDefaults.standard.setValue(NSNumber(value: self.client!.local_port), forKey: USERDEFAULTS_LOCAL_SOCKS5_LISTEN_PORT)
            UserDefaults.standard.synchronize()
        
//更新后台trojan_client.json配置
        let manager = FileManager.default
        if manager.fileExists(atPath: CONFIG_PATH) {
            do {
                try self.jsonString.write(toFile: CONFIG_PATH, atomically: true, encoding: String.Encoding.utf8)
            } catch let e {
                print("saveConfig error", e)
            }
        } else {
            manager.createFile(atPath: CONFIG_PATH, contents: nil, attributes: nil)
            do {
                try self.jsonString.write(toFile: CONFIG_PATH, atomically: true, encoding: String.Encoding.utf8)
            } catch let e {
                print("saveConfig error", e)
            }
        }
        
    }
    
    func loadDefaultConfig() {
        let run_type: String = "client"
        let local_addr: String = "127.0.0.1"
        let local_port: Int = 10800
        let remote_addr: String = "usol97.ovod.me"
        let remote_port: Int = 443
        let password: [String] = ["WxUUph"]
        let log_level: Int = 1
        let verify: Bool = true
        let verify_hostname: Bool = true
        let cert: String = ""
        let cipher: String = "ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES128-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA:AES128-SHA:AES256-SHA:DES-CBC3-SHA"
        let cipher_tls13: String = "TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_256_GCM_SHA384"
        let sni: String = ""
        let alpn: [String] = ["h2","http/1.1"]
        let reuse_session: Bool = true
        let session_ticket: Bool = false
        let curves: String = ""
        let no_delay: Bool = true
        let keep_alive: Bool = true
        let reuse_port: Bool = false
        let fast_open: Bool = false
        let fast_open_qlen: Int = 20
        let dhparam: String = ""
        let plain_http_response: String = ""
        let prefer_server_cipher: Bool = true
        
        let tcp = TCP(no_delay: no_delay, keep_alive: keep_alive, reuse_port: reuse_port, fast_open: fast_open, fast_open_qlen: fast_open_qlen)
        let ssl = SSL(verify: verify, verify_hostname: verify_hostname, cert: cert, cipher: cipher, cipher_tls13: cipher_tls13, sni: sni, alpn: alpn, reuse_session: reuse_session, session_ticket: session_ticket, curves: curves, plain_http_response: plain_http_response, dhparam: dhparam, prefer_server_cipher: prefer_server_cipher)
        let c = Client(run_type: run_type, local_addr: local_addr, local_port: local_port, password: password, remote_addr: remote_addr, remote_port: remote_port, log_level: log_level, ssl: ssl, tcp: tcp, uuid: UUID().uuidString, group: "trojan")
        self.client = c
        self.name = "Default"
    }
    
    func arguments() -> [String] {
        return ["--log", LOG_PATH, "--config", CONFIG_PATH]
    }
    
}



func import_SS(_ uriString:String,finish:@escaping(_ errMsg:String)->())-> SSRProfile?{
//单个ssr节点导入
/*格式1、
ssr://213.183.59.206:9059:origin:aes-256-cfb:plain:OVh3WXlac0s4U056UUR0WQ
格式2、
ssr://NDIuMTU3LjE5NS4yMzQ6MTIxMjc6YXV0aF9hZXMxMjhfc2hhMTphZXMtMjU2LWNmYjpodHRwX3NpbXBsZTpOamg0WkdkMU9XVjVhV1kvP29iZnNwYXJhbT1OemN6WTJFeE16QTRPVGMzTG5ZeU0yWTNiazB3JnByb3RvcGFyYW09TVRNd09EazNOem95WWpSMFkxVSZyZW1hcmtzPTZhYVo1cml2SU9hWnJ1bUFtdWU2di1pM3J6QXlJQzBnTVRJeE1qY2c1WTJWNTZ1djVZLWomZ3JvdXA9Vkc5VWIwTnNiM1ZrJm5vZGVfaWQ9TlRBJnJ0dHM9TUEmbm9kZV9jbGFzcz1NZyZsaW5lX3BlcnNvbl9udW09TVRZNCZub2RlX3JlbWFyaz01cG11NllDYTVMeWE1WkdZNUxpVDVMcXImbm9kZV9oZWFydGJlYXQ9TVRZM09UWXpOVE0xTUEmbm9kZV9yZW1hcmtfY29sb3I9STBZeFF6UXdSZw
解析得到->
ssr://14.152.92.81:12127:auth_aes128_sha1:aes-256-cfb:http_simple:Njh4ZGd1OWV5aWY/?obfsparam=ZjlkYjU0MDc4OC52MjNmN25NMA&protoparam=NDA3ODg6aVpqczVP&remarks=6auY57qn57q_6LevIDE2IC0gMTIxMjcg5Y2V56uv5Y-j&group=5p6B5YWJQ2xvdWQ&node_id=Nzc&rtts=MA&node_class=NA&line_person_num=NTA&node_remark=6auY57qn5Lya5ZGY5LiT5Lqr&node_heartbeat=MTY0OTk4NTYxNA&node_remark_color=IzJFQ0M3MQ
*/
    let undecodedString = String(uriString[uriString.index(uriString.startIndex, offsetBy: "ssr://".count)...])
    guard let proxyString = undecodedString.base64DecodeUrlSafe(), let _ = proxyString.range(of: ":")?.lowerBound else {
        finish("!error.uri.format")
        return nil
    }
    var hostString: String = proxyString
    var queryString: String = ""
    if let queryMarkIndex = proxyString.range(of: "?", options: .backwards)?.lowerBound {
        hostString = String(proxyString[..<queryMarkIndex])
        //14.152.92.81:12127:auth_aes128_sha1:aes-256-cfb:http_simple:Njh4ZGd1OWV5aWY/
        queryString = String(proxyString[proxyString.index(after: queryMarkIndex)...])
        //obfsparam=ZjlkYjU0MDc4OC52MjNmN25NMA&protoparam=NDA3ODg6aVpqczVP...
    }
    if let hostSlashIndex = hostString.range(of: "/", options: .backwards)?.lowerBound {
        hostString = String(hostString[..<hostSlashIndex]) //14.152.92.81:12127:auth_aes128_sha1:aes-256-cfb:http_simple:Njh4ZGd1OWV5aWY
    }
    let hostComps = hostString.components(separatedBy: ":")
    guard hostComps.count == 6 else {
        finish("!error.ssr.hostSection")
        return nil
    }

    guard let p = Int(hostComps[1]) else {//12127
        finish("!error.ssr.port")
        return nil
    }
    let ssrProfile = SSRProfile()
    ssrProfile.serverHost = hostComps[0]
    ssrProfile.serverPort = uint16(p)
    ssrProfile.ssrProtocol = hostComps[2]
    ssrProfile.method = hostComps[3]
    ssrProfile.ssrObfs = hostComps[4]
    ssrProfile.password = hostComps[5].base64DecodeUrlSafe()!
//obfsparam=ZjlkYjU0MDc4OC52MjNmN25NMA&protoparam=NDA3ODg6aVpqczVP&remarks=6auY57qn57q_6LevIDE2IC0gMTIxMjcg5Y2V56uv5Y-j&group=..
    for queryComp in queryString.components(separatedBy: "&") {
        let comps = queryComp.components(separatedBy: "=")
        guard comps.count == 2 else {
            continue
        }
        switch comps[0] {
        case "protoparam":
            ssrProfile.ssrProtocolParam = comps[1].base64DecodeUrlSafe()!
        case "obfsparam":
            ssrProfile.ssrObfsParam = comps[1].base64DecodeUrlSafe()!
        case "remarks":
            ssrProfile.remark = comps[1].base64DecodeUrlSafe()!
        case "node_class":
            if let tmp = comps[1].base64DecodeUrlSafe() {
                if let iClass = Int(tmp){
                    ssrProfile.nodeClass = iClass
                }
            }
            //ss才有的3个参数
//            case "ot_enable":
//                ssrProfile.ssrotEnable = (Int(comps[1]) != 0)
//            case "ot_domain":
//                ssrProfile.ssrotDomain = base64DecodeUrlSafe(comps[1]) ?? ""
//            case "ot_path":
//                ssrProfile.ssrotPath = base64DecodeUrlSafe(comps[1]) ?? ""
        default:
            continue
        }
    }
    if ssrProfile.remark .isEmpty{
        ssrProfile.remark = ssrProfile.serverHost
    }
    return ssrProfile
}

func import_Trojan(_ uriString:String,_ finish:@escaping(_ errMsg:String)->()) -> TrojanProfile?{
//单个trojan节点导入
//  节点格式如：
//1、trojan://sZKZzxGDxGyP9fTNzsy@hk1-1.nigirocloud.com:443#香港-HK1-1-流量倍率:0.5
//2、trojan://7dafe71e-2be6-302f-bdfc-e6319a3299bc@tj-us02.yiyodns.xyz:443?security=tls&type=tcp&headerType=none#gaofumei.net_%E7%BE%8E%E5%9B%BD%E6%83%A0%E6%99%AEHP%205
//=>trojan://7dafe71e-2be6-302f-bdfc-e6319a3299bc@tj-us02.yiyodns.xyz:443?security=tls&type=tcp&headerType=none#gaofumei.net_美国惠普HP 5
//3、trojan://b5be5123720.wns.windows.com@46.3.80.226:8443?allowInsecure=1&tfo=1#加拿大 Edge
//?前，如果没有？则#前为基础字段#后为remark字段
    let undecodedString = String(uriString[uriString.index(uriString.startIndex, offsetBy: "trojan://".count)...])
    let array = undecodedString.components(separatedBy: "#") //#后为节点代理服务地区，如#新加坡 NTT,
    let uriString = array[0].removingPercentEncoding! //不管有没有#,separatedBy会返回至少有1个元素的数组

    let otherArr=uriString.components(separatedBy: "?"); //先判断是否有？隔开的参数
    let leftStr=otherArr[0];
    let firstArr = leftStr.components(separatedBy: "@")
    guard firstArr.count == 2 else {
        finish("!error.trojan.hostSection")
        return nil
    }
    let hostString: String = firstArr[1]
    let hostComps = hostString.components(separatedBy: ":")
    guard hostComps.count == 2 else {
        finish("!error.trojan.hostport")
        return nil
    }
    guard let p = Int(hostComps[1]) else {
        finish("!error.trojan.port")
        return nil
    }
    
    let trojanProfile = TrojanProfile()
    if array.count > 1 {
        trojanProfile.remark = array[1].removingPercentEncoding! //以节点地区为显示名称
    }
    trojanProfile.password = firstArr[0]
    trojanProfile.serverHost = hostComps[0]
    trojanProfile.serverPort = uint16(p)
    trojanProfile.sslVerify = false //ssl.verify,默认为false，如须为true，则需二次编辑;暂未看到为true的trojan-uri
    if trojanProfile.remark .isEmpty{
        trojanProfile.remark = trojanProfile.serverHost
    }
    return trojanProfile
}

func importNodeList(_ decodeStr: String,Url uri:String,GroupTitle title:String,IsModi modiFlag:Bool, finish: @escaping(_ success: Bool,_ errMsg:String)->()){
    //直接判断是不是\n分隔的数据，如不是则提示解析失败
//将string转成数组
    let strArr: [String]=decodeStr.components(separatedBy: "\n")
    guard strArr.count>0 else {
        finish(false,"Failed: err.format.list")
        return
    }
   
    var theNodes:[[String:AnyObject]] = []
    var has_nodeClass:Bool = false
    var groupStatus = ""
    for perStr in strArr {
        let rowStr = perStr.trimmingCharacters(in: .whitespaces)
        let tmplowStr = rowStr.lowercased()
        if tmplowStr.hasPrefix("ssr://") {
            if let ssrProfile = import_SS(rowStr, finish: { errMsg in
                if !errMsg.isEmpty{
                    NSLog("Cancel.to.syntax.[\(errMsg)]"+rowStr)
                }
            }) {
                if (ssrProfile.nodeClass != nil){
                    has_nodeClass = true
                }
                ssrProfile.nodeGroup = title
                theNodes.append(ssrProfile.toDictionary())
            }
        }
        else if tmplowStr.hasPrefix("trojan://"){
            if let trojanProfile = import_Trojan(rowStr, { errMsg in
                if !errMsg.isEmpty{
                    NSLog("Cancel.to.syntax.[\(errMsg)]"+rowStr)
                }
            }){
                trojanProfile.nodeGroup = title
                theNodes.append(trojanProfile.toDictionary())
            }
        }
        else{
// STATUS=流量：38.39GiB/161.61GiB｜到期时间：2023-04-21 17:20:34
            if rowStr.contains("STATUS=流量"){
//则作为本次节点组的流量及到期时间说明
                let comps = rowStr.components(separatedBy: "=")
                if comps.count > 1{
                    groupStatus = comps[1]
                }
            }
            NSLog("Cancel.to.syntax.[unknown]"+rowStr)
        }
    }
    
    if theNodes.count > 0{
        let defaults = UserDefaults.standard
//保存节点列表
        let key = String(format: "\(SUBSCRIBE_PROFILE_KEY).\(title)")
        defaults.set(theNodes, forKey: key)
        
//更新已导入成功的订阅地址表
        if !modiFlag{ //新添加节点组：更新订阅时不对节点组做处理
            if let subscribeList = defaults.array(forKey: SUBSCRIBE_Info_KEY) {
                var newList = subscribeList
                var isExist = false
                for perlist in newList {
//先判断是否已经存在同名的组，存在则不添加(登录时添加默认节点等情况下会有此可能)
                    let perDict = perlist as! [String:AnyObject]
                    if perDict["group"] as? String == title{
                        isExist = true
                        break
                    }
                }
                if !isExist{
                    newList.append(["uri":uri,"group":title,"groupStatus":groupStatus,"nodeClass": has_nodeClass ? "1" : "0"])
                    defaults.set(newList, forKey: SUBSCRIBE_Info_KEY)
                }
            }else{
                let newDict = ["uri":uri,"group":title,"groupStatus":groupStatus,"nodeClass": has_nodeClass ? "1" : "0"]
                defaults.set([newDict], forKey: SUBSCRIBE_Info_KEY)
            }
        }
        defaults.synchronize()
        
        finish(true,"")
    }else{
        finish(false,"Failed: null.validate.node")
    }
    
}
/*
 解析yaml格式文件里的代理节点
 */
func importYamlDict(_ proxyArr: [[String: AnyObject]],Url uri:String,GroupTitle title:String,IsModi modiFlag:Bool,finish: @escaping(_ success:Bool,_ errMsg:String)->()){
/*
-------------vmess格式
 alterId = 64;
 cipher = auto;
 name = "\Ud83c\Udde8\Ud83c\Udde6 \U52a0\U62ff\U5927 Edge";
 network = ws;
 port = 153;
 server = "ca1.qiangdong.xyz";
 type = vmess;
 udp = true;
 uuid = "65ec19f1-285c-37e8-8b9e-e93089a47403"; //为密码
 "ws-opts" =     {
     headers =         {
         Host = "d0c1572358.laowanxiang.com";
     };
     path = "/api/v3/download.getFile";
 };
*/

    
    var theNodes:[[String:AnyObject]] = []
    
    for perDict in proxyArr {
        guard let typeRaw = (perDict["type"] as? String)?.lowercased(), typeRaw == "ssr" || typeRaw == "trojan" || typeRaw == "vmess"  else{
            continue //invalidType 没有type字段的则放过
        }
        guard let server = perDict["server"] as? String else{
            continue
        }

        guard let portStr = (perDict["port"] as? String), let port = Int(portStr), port>0 else{ //port=0一般为描述信息节点
            continue
        }
        
        if typeRaw == "ssr" {
            guard let password = perDict["password"] as? String else{
                continue
            }
/*
------ssr格式
name: '香港 普通线路02 - 12127 单端口'
type: ssr
server: 42.157.195.234
port: 12127
cipher: aes-256-cfb
password: 68xdgu9eyif
protocol: auth_aes128_sha1
protocol-param: '1308977:2b4tcU'
obfs: http_simple
obfsparam: 773ca1308977.v23f7nM0
*/
            let ssrProfile = SSRProfile()
            ssrProfile.password = password
            ssrProfile.serverHost = server
            ssrProfile.serverPort = uint16(port)
            ssrProfile.method = perDict["cipher"] as! String
            ssrProfile.ssrProtocol = perDict["protocol"] as! String
            if let _ = perDict["protocol-param"]{
                ssrProfile.ssrProtocolParam = perDict["protocol-param"] as! String
            }
            ssrProfile.ssrObfs = perDict["obfs"] as! String
            if let _ = perDict["obfsparam"]{
                ssrProfile.ssrObfsParam = perDict["obfsparam"] as! String
            }
            ssrProfile.remark = perDict["name"] as! String
            ssrProfile.nodeGroup = title

            theNodes.append(ssrProfile.toDictionary())
        }
        else if typeRaw == "trojan" {
            guard let password = perDict["password"] as? String else{
                continue
            }
/*
------------trojan格式
server: ca1.qiangdong.xyz
port: 8443
name: "\U0001F1E8\U0001F1E6 加拿大 Edge"
type: trojan
password: d0c1572358.wns.windows.com
udp: true
alpn:
- h2
- http/1.1
skip-cert-verify: true
*/
            let trojanProfile = TrojanProfile()
            trojanProfile.serverHost = server
            trojanProfile.serverPort = uint16(port)
            trojanProfile.password =  password
            if let _ = perDict["skip-cert-verify"] {
                trojanProfile.sslVerify = !(perDict["skip-cert-verify"] as! Bool)
            }
            trojanProfile.remark = perDict["name"] as! String
            trojanProfile.nodeGroup = title
            
            theNodes.append(trojanProfile.toDictionary())
        }
        else if typeRaw == "vmess" {
            guard let _ = perDict["uuid"] as? String else{
                continue
            }
            continue //FIXME: upgrade
        }
    }

    if theNodes.count > 0{
        let groupTitle:String = title
        let defaults = UserDefaults.standard
//保存组名为groupTitle的该组所有节点
        let key = String(format: "\(SUBSCRIBE_PROFILE_KEY).\(groupTitle)")
        defaults.set(theNodes, forKey: key) //直接重写
//更新已导入成功的订阅地址表
        if !modiFlag{
            if let subscribeList = defaults.array(forKey: SUBSCRIBE_Info_KEY) {
                var newList = subscribeList
                var isExist = false
                for perlist in newList {
//先判断是否已经存在同名的组，存在则不添加(登录时添加默认节点等情况下会有此可能)
                    let perDict = perlist as! [String:AnyObject]
                    if perDict["group"] as? String == title{
                        isExist = true
                        break
                    }
                }
                if !isExist{
                    newList.append(["uri":uri,"group":title,"nodeClass": "0"])
                    defaults.set(newList, forKey: SUBSCRIBE_Info_KEY)
                }
            }else{
                let newDict = ["uri":uri,"group":title,"nodeClass": "0"]
                defaults.set([newDict], forKey: SUBSCRIBE_Info_KEY)
            }
        }
        defaults.synchronize()
        finish(true,"")
    }else{
        finish(false,"Failed: null.validate.node")
    }
}

//获取2个日期的间隔天数
func get2dateDiff(startDay:String,endDay:String)->Int{
    // 计算两个日期差，返回相差天数
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
    //开始日期
      let startDate = formatter.date(from: startDay)
      // 结束日期
      let endDate = formatter.date(from: endDay)
    
    let calendar = Calendar.current
      let diff:DateComponents = calendar.dateComponents([.day], from: startDate!, to: endDate!) //startDate>endDate时为负数
      return diff.day!
}

//获取今天至某个日期的间隔天数
func getTodayToADayDiff(aDay:String)->Int{
//aDay格式为yyyy-MM-dd
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = Date()
    let strToday = formatter.string(from: today)
    return get2dateDiff(startDay: strToday, endDay: aDay)
    
}

func openHomeUrl(_ urlString:String = "http://www.totocloud.com"){
    let url = URL(string: urlString)
    if NSWorkspace.shared.open(url!) {
        NSLog("default browser was successfully opened")
    }
}
