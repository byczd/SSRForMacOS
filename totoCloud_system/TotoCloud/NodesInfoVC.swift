//
//  NodesInfoVC.swift
//  totoCloud
//
//  Created by 黄龙 on 2023/3/20.
//  Copyright © 2023 ParadiseDuo. All rights reserved.
//

import Cocoa

let NODE_PROFILE_KEY = "Node.Profile.Data" //单个节点添加后数据列表[profile.dictionary]
let SUBSCRIBE_Info_KEY = "Subscribe.Info.Data" //订阅地址列表[{"uri":"","group":"","nodeClass","0","groupStatus":"剩余流量,过期时间"}]
let SUBSCRIBE_PROFILE_KEY = "Subscribe.Profile" //订阅节点添加后的数据列表"Subscribe.Profile.GroupName">[profile.dictionary]
let LAST_PROXY_NODE_IFNO = "Last.Proxy.Node.Dict"

class NodesInfoVC: NSViewController {
    open var windowController: NSWindowController?
    
    lazy var ttbarAccoutback: NSImageView = {
        let accountBack = NSImageView(image: NSImage(named: "titlebar_userback@2x.png")!)
        return accountBack
    }()
    
    lazy var ttbarAccoutButton: NSButton = {
        let accountBtn = NSButton(title: "---@---.com", image: NSImage(named: "titlebar_user@2x.png")!, target: self, action: nil)
        accountBtn.frame =  CGRect(x: 5, y: 3, width: 136, height: 20)
        accountBtn.isBordered = false
        accountBtn.imagePosition = .imageLeft
        accountBtn.font = NSFont.systemFont(ofSize: 11)
        return accountBtn
    }()
    lazy var ttbarMergeButton: NSButton = {
        let mergeBtn = NSButton(title: "---.--", image: NSImage(named: "titlebar_merge@2x.png")!, target: self, action: nil)
        mergeBtn.isBordered = false
        mergeBtn.imagePosition = .imageLeft
        mergeBtn.font = NSFont.systemFont(ofSize: 11)
        mergeBtn.contentTintColor = NSColor("#A3B2BA")
        return mergeBtn
    }()
    lazy var ttbarExpireButton: NSButton = {
        let expireBtn = NSButton(title: "---天", image: NSImage(named: "titlebar_expiretime@2x.png")!, target: self, action: nil)
        expireBtn.isBordered = false
        expireBtn.imagePosition = .imageLeft
        expireBtn.font = NSFont.systemFont(ofSize: 11)
        expireBtn.contentTintColor = NSColor("#A3B2BA")
        return expireBtn
    }()
    lazy var ttbarLoginButton: NSButton = {
        let accountBtn = NSButton(title: "登录", target: self, action: #selector(onTapButton(sender:)))
        accountBtn.tag = 168
        accountBtn.isBordered = false
        accountBtn.contentTintColor = NSColor.white
        accountBtn.font = NSFont.systemFont(ofSize: 14)
        accountBtn.wantsLayer = true
        accountBtn.layer?.backgroundColor = NSColor("#78A9ED").cgColor
        accountBtn.layer?.cornerRadius = 12
        return accountBtn
    }()
    lazy var ttbarTips: NSButton = {
        let accountTips = NSButton(image: NSImage(named: "titlebar_login_tips@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        accountTips.tag = 169
//        accountTips.wantsLayer = true //初始化时有这句，后面对其做anchorPoint居然无效？fuck！但在动画时又需要设置wantsLayer = true,TMD操蛋！
        accountTips.isBordered = false
        return accountTips
    }()
    
    lazy var mainWorkView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    lazy var nodeRemarkLabel: NSButton = {
        let routeLabel = NSButton(title:"" , image: NSImage(named: "mainwork_route@2x.png")!, target: self, action: nil)
        routeLabel.tag = 1001
        routeLabel.isBordered = false
        routeLabel.imagePosition = .imageLeft
        routeLabel.alignment = .left
        routeLabel.font = NSFont.systemFont(ofSize: 11)
        routeLabel.contentTintColor = NSColor(deviceRed: 80/255.0, green: 137/255.0, blue: 218/255.0, alpha: 1)
        return routeLabel
    }()
    lazy var startProxyButton: NSButton = {
        let startBtn = NSButton(image: NSImage(named: "mainwork_start@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        startBtn.tag = 1000
        startBtn.isBordered = false
        return startBtn
    }()
    lazy var connectButton: ConnectButton = {
        let button = ConnectButton(frame: CGRect(x: 0, y: 0, width: 260, height: 88), andState: 1)
        return button
    }()
    
    lazy var otherWorkView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    lazy var otherHeaderView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()

    lazy var toolbar_btn_back: CanTapImageView = {
        let view = CanTapImageView(image: NSImage(named: "otherwork_toolbar_btn_back@2x.png")!)
        return view
    }()
    lazy var toolbar_btn_home: NSButton = {
        let button = NSButton(title: "网络加速", image: NSImage(named: "maintabbar_1_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.tag = 2000
        button.isBordered = false
        button.imagePosition = .imageAbove
        button.font = NSFont.systemFont(ofSize: 12)
        button.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        return button
    }()
    lazy var toolbar_btn_route: NSButton = {
        let button = NSButton(title: "线路选择", image: NSImage(named: "maintabbar_2_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.tag = 2001
        button.isBordered = false
        button.imagePosition = .imageAbove
        button.font = NSFont.systemFont(ofSize: 12)
        button.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        return button
    }()
    lazy var toolbar_btn_import: NSButton = {
        let button = NSButton(title: "导入配置", image: NSImage(named: "maintabbar_3_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.tag = 2002
        button.isBordered = false
        button.imagePosition = .imageAbove
        button.font = NSFont.systemFont(ofSize: 12)
        button.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        return button
    }()
    lazy var toolbar_btn_add: NSButton = {
        let button = NSButton(title: "添加节点", image: NSImage(named: "maintabbar_4_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.tag = 2003
        button.isBordered = false
        button.imagePosition = .imageAbove
        button.font = NSFont.systemFont(ofSize: 12)
        button.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        return button
    }()
    lazy var toolbar_btn_user: NSButton = {
        let button = NSButton(title: "会员中心", image: NSImage(named: "maintabbar_5_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.tag = 2004
        button.isBordered = false
        button.imagePosition = .imageAbove
        button.font = NSFont.systemFont(ofSize: 12)
        button.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        return button
    }()
    
    let topbarHeight = 128.0
    lazy var pageView_route: RoutePageView = {
        let view = RoutePageView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - topbarHeight),parentVC: self)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    lazy var pageView_import: ImportNodePage = {
        let view = ImportNodePage.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - topbarHeight),parentVC: self)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    lazy var pageView_add: AddNodePage = {
        let view = AddNodePage.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - topbarHeight),parentVC: self)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    lazy var pageView_user: UserAccountPage = {
        let view = UserAccountPage.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - topbarHeight),parentVC: self)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor("#F6F6F6").cgColor
        return view
    }()
    
    var pagerouteLoaded = false
    var pageimportLoaded = false
    var pageaddLoaded = false
    var pageuserLoaded = false
    
    var lastNodeInfo:[String:AnyObject] = [:]
    
    
    var toastWC: ToastWindowController!
    
    var isLoadedView :Bool = false
    
    func showToast(_ message: String) {
        if self.toastWC != nil {
            self.toastWC.close()
        }
        let c = ToastWindowController.init(windowNibName: "ToastWindowController")
        self.toastWC = c
        c.message = message
        c.showWindow(self)
        c.fadeInHud()
    }
    
    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 920, height: 580))
        //only-one: view的大小才是真正的初始后的window大小
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        
        //        view.isFlipped = true //macOS下左下角为(0,0), isFlipped=true,转换成左上角为(0,0)
        self.initUI()
        
        NotificationCenter.default.addObserver(forName: NOTIFY_UPDATE_RUNNING_MODE_MENU, object: nil, queue: OperationQueue.main) { (noti) in
            self.noti_mode_change()
        }
        NotificationCenter.default.addObserver(forName: NOTIFY_REFRESH_ROUTE_STATE, object: nil, queue: OperationQueue.main) { (noti) in
            if let state = noti.object {
                self.noti_proxyState_change(state as! Int)
            }
        }
    }
    
    override func viewDidAppear() {
        if !isLoadedView{
            self.applyConfigWhenLuanch { success in
            }
        }
        isLoadedView = true
    }
    
    override func mouseDown(with event: NSEvent) {
        //取消field焦点
        NSApp.keyWindow?.makeFirstResponder(nil)
    }
    
    func applyConfigWhenLuanch(finish: @escaping(_ success: Bool)->()) {
        let defaults = UserDefaults.standard
        let isOn = defaults.bool(forKey: USERDEFAULTS_TROJAN_ON)
        if isOn{
            stop_TheProxy(AndNoti: false){
                if let _ = UserDefaults.standard.dictionary(forKey: "Last.Proxy.Node.Dict"){
                    let walltime = DispatchWallTime.now()+1.25
                    DispatchQueue.main.asyncAfter(wallDeadline: walltime){
                        NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: 1)
                        run_TheProxy{
                            DispatchQueue.main.async {
                                finish(true)
                            }
                        }
                    }
                }else{
                    NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: 0)
                }
            }
            
            
        }else{
            stop_TheProxy(AndNoti: true){
                DispatchQueue.main.async {
                    finish(true)
                }
            }
        }
    }
    
    func initUI(){
        initMainView()
        initOtherView()
        initTitleBar() //最上层
    }

    func initTitleBar(){
        let width = view.frame.width
        let height = view.frame.height
//左侧logo
        let logoImageView = NSImageView(image: NSImage(named: "titlebar_logo@2x.png")!)
        view.addSubview(logoImageView)
        logoImageView.frame = CGRect(x: 7, y: height-5-18, width: 138, height: 18)
//右侧系统按钮
        let closeBtn = NSButton(image: NSImage(named: "titlebar_close@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        closeBtn.tag = 1
        closeBtn.frame =  CGRect(x: width - 17 - 13, y: height - 10 - 13, width: 13, height: 13)
        closeBtn.isBordered = false //无边框时按钮为图片大小，有边框时按钮最好设置为图片的2x
        view.addSubview(closeBtn)

        let minBtn = NSButton(image: NSImage(named: "titlebar_min@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        minBtn.tag = 2
        minBtn.frame =  CGRect(x: closeBtn.frame.minX - 30, y: height - 10 - 13, width: 13, height: 13)
        minBtn.isBordered = false
        view.addSubview(minBtn)
        
        let kefuBtn = NSButton(image: NSImage(named: "titlebar_visitor@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        kefuBtn.tag = 3
        kefuBtn.frame =  CGRect(x: minBtn.frame.minX - 17 - 20, y: height - 8 - 20, width: 20, height: 20)
        kefuBtn.isBordered = false
        view.addSubview(kefuBtn)
//用户信息
        view.addSubview(self.ttbarAccoutback)
        self.ttbarAccoutback.frame = CGRect(x: kefuBtn.frame.minX-33-146, y: height-7-26, width: 146, height: 26)
        self.ttbarAccoutback.isHidden = true
        self.ttbarAccoutback.addSubview(self.ttbarAccoutButton)
        self.ttbarAccoutButton.frame =  CGRect(x: 5, y: 3, width: 136, height: 20)
        self.ttbarAccoutButton.title = "----"
        self.ttbarAccoutButton.contentTintColor = NSColor(deviceRed: 202/255.0, green: 206/255.0, blue: 209/255.0, alpha: 1)
        
        view.addSubview(self.ttbarMergeButton)
        self.ttbarMergeButton.frame =  CGRect(x: self.ttbarAccoutback.frame.minX - 17 - 75, y: height - 10 - 13, width: 75, height: 13)
        self.ttbarMergeButton.isHidden = true
        view.addSubview(self.ttbarExpireButton)
        self.ttbarExpireButton.frame =  CGRect(x: self.ttbarMergeButton.frame.minX - 17 - 65, y: height - 10 - 13, width: 65, height: 13)
        self.ttbarExpireButton.isHidden = true
        
        view.addSubview(self.ttbarLoginButton)
        self.ttbarLoginButton.frame = CGRect(x: kefuBtn.frame.minX-33-58, y: height-7-24, width: 58, height: 24)
        self.ttbarLoginButton.isHidden = false
        view.addSubview(self.ttbarTips)
        self.ttbarTips.frame = CGRect(x: self.ttbarLoginButton.frame.minX - 119, y: height - 41, width: 119, height: 41)
        self.ttbarTips.isHidden = false
        
        freshUserInfo()
    }
    
    func getExpireDayCount(WithExpireTime expiretime:String)->Int{
//expiretime格式：2026-01-24 16:15:17
        let expireDay = expiretime.prefix(10)
        return getTodayToADayDiff(aDay: String(expireDay))
    }
    
    func freshUserInfo(){
//每次启动App，或登录后，刷新首页用户信息
        let userInfo = UserDefaults.standard.object(forKey: "key.toto.user.info")
        let isLogin = (userInfo != nil)
        if (isLogin){
            let userDict = userInfo as! [String:AnyObject]
            let user_email = userDict["user_email"] as! String
            self.ttbarAccoutButton.title = user_email
            
            let class_expire = userDict["class_expire"] as! String
            let day_count = self.getExpireDayCount(WithExpireTime: class_expire)
            self.ttbarExpireButton.title = String("\(day_count)天")
            let class_amount = userDict["class_amount"] as! String
            self.ttbarMergeButton.title = class_amount
            
            self.resetTipsButton()
        }else{
            showTipsAnimation()
        }
        self.ttbarAccoutback.isHidden = !isLogin
        self.ttbarMergeButton.isHidden = !isLogin
        self.ttbarExpireButton.isHidden = !isLogin
        self.ttbarLoginButton.isHidden = isLogin
    }
    
    func showTipsAnimation(){
        self.ttbarTips.isHidden = false
        self.ttbarTips.wantsLayer = true
        self.ttbarTips.layer?.removeAllAnimations()
        self.ttbarTips.frame = CGRect(x: self.ttbarLoginButton.frame.minX, y: view.bounds.height - 22, width: 119, height: 41)
        self.ttbarTips.layer?.anchorPoint = CGPoint(x: 1, y: 0.5)
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = -10/360.0 * Double.pi
        rotateAnimation.toValue = 10/360.0 * Double.pi
        rotateAnimation.duration = 0.75
        rotateAnimation.fillMode = .forwards
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.repeatCount = .infinity
        rotateAnimation.autoreverses = true
        self.ttbarTips.layer?.add(rotateAnimation, forKey: "tips.roate")
    }
    
    func resetTipsButton(){
//登录后，回调恢复
        self.ttbarTips.layer?.removeAllAnimations()
        self.ttbarTips.frame = CGRect(x: self.ttbarLoginButton.frame.minX - 119, y: view.bounds.height - 41, width: 119, height: 41)
        self.ttbarLoginButton.isHidden = true
        self.ttbarTips.isHidden = true
    }
    
    // MARK: 初始化页面
    func initMainView(){
        let width = view.frame.width
        let height = view.frame.height
        
        view.addSubview(self.mainWorkView)
        self.mainWorkView.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        let imgBack = CanTapImageView(image: NSImage(named: "mainwork_back@2x.png")!)
        mainWorkView.addSubview(imgBack)
        imgBack.frame = CGRect(x: width-379, y: height-18-386, width: 379, height: 386)
        
        let sloganImage = NSImageView(image: NSImage(named: "mainwork_tips@2x.png")!)
        mainWorkView.addSubview(sloganImage)
        sloganImage.frame = CGRect(x: 95, y: height - 139 - 62, width: 301, height: 62)
        
        mainWorkView.addSubview(self.startProxyButton)
        self.startProxyButton.frame =  CGRect(x: 89, y: height - 231 - 71, width: 202, height: 71)
        
        mainWorkView.addSubview(self.connectButton)
        self.connectButton.frame = CGRect(x: 89, y: height - 231 - 81, width: 260, height: 88)
        self.connectButton.isHidden = true
        
        var nodeTitle = "尚未选择代理节点"
        if let lastNodeDict = UserDefaults.standard.dictionary(forKey: LAST_PROXY_NODE_IFNO){
            lastNodeInfo = lastNodeDict as [String:AnyObject]
            nodeTitle = lastNodeInfo["Remark"] as! String
        }
        mainWorkView.addSubview(self.nodeRemarkLabel)
        self.nodeRemarkLabel.frame =  CGRect(x: 105, y: height - 330 - 13, width: 250, height: 13)
        self.nodeRemarkLabel.title = String(" \(nodeTitle)")
        
        
        let automodeBtn = NSButton(radioButtonWithTitle: "智能模式", target: self, action: #selector(onTapButton(sender:)))
        automodeBtn.tag = 1002
        automodeBtn.frame =  CGRect(x: 370, y: height - 330 - 16, width: 70, height: 16)
        automodeBtn.isBordered = false
        automodeBtn.imagePosition = .imageLeft
        automodeBtn.font = NSFont.systemFont(ofSize: 11)
        automodeBtn.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        automodeBtn.state = .on
        mainWorkView.addSubview(automodeBtn)
        
        let globalmodeBtn = NSButton(radioButtonWithTitle: "全局模式", target: self, action: #selector(onTapButton(sender:)))
        globalmodeBtn.tag = 1003
        globalmodeBtn.frame =  CGRect(x: 481, y: height - 330 - 16, width: 70, height: 16)
        globalmodeBtn.isBordered = false
        globalmodeBtn.imagePosition = .imageLeft
        globalmodeBtn.font = NSFont.systemFont(ofSize: 11)
        globalmodeBtn.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        globalmodeBtn.state = .off
        mainWorkView.addSubview(globalmodeBtn)
        
        
        let tabbarBack = CanTapImageView(image: NSImage(named: "mainwork_tabbar_back@2x.png")!)
        mainWorkView.addSubview(tabbarBack)
        tabbarBack.frame = CGRect(x: 0, y: 0, width: width, height: 170)
        
        
        let tabBtn_1 = NSButton(title: "网络加速", image: NSImage(named: "maintabbar_1_h@2x.png")!, target: self, action: nil)
        tabBtn_1.tag = 1100
        tabBtn_1.frame =  CGRect(x: 65, y: 55, width: 55, height: 80)
        tabBtn_1.isBordered = false
        tabBtn_1.imagePosition = .imageAbove
        tabBtn_1.font = NSFont.boldSystemFont(ofSize: 11)
        tabBtn_1.contentTintColor = NSColor(deviceRed: 48/255.0, green: 48/255.0, blue: 48/255.0, alpha: 1)
        tabbarBack.addSubview(tabBtn_1)
        
        let tabBtn_2 = NSButton(title: "线路选择", image: NSImage(named: "maintabbar_2_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        tabBtn_2.tag = 1101
        tabBtn_2.frame =  CGRect(x: 252, y: 56, width: 55, height: 59)
        tabBtn_2.isBordered = false
        tabBtn_2.imagePosition = .imageAbove
        tabBtn_2.font = NSFont.systemFont(ofSize: 11)
        tabBtn_2.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        tabbarBack.addSubview(tabBtn_2)
        
        let tabBtn_3 = NSButton(title: "导入配置", image: NSImage(named: "maintabbar_3_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        tabBtn_3.tag = 1102
        tabBtn_3.frame =  CGRect(x: 436, y: 56, width: 55, height: 59)
        tabBtn_3.isBordered = false
        tabBtn_3.imagePosition = .imageAbove
        tabBtn_3.font = NSFont.systemFont(ofSize: 11)
        tabBtn_3.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        tabbarBack.addSubview(tabBtn_3)
        
        let tabBtn_4 = NSButton(title: "添加节点", image: NSImage(named: "maintabbar_4_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        tabBtn_4.tag = 1103
        tabBtn_4.frame =  CGRect(x: 620, y: 56, width: 55, height: 59)
        tabBtn_4.isBordered = false
        tabBtn_4.imagePosition = .imageAbove
        tabBtn_4.font = NSFont.systemFont(ofSize: 11)
        tabBtn_4.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        tabbarBack.addSubview(tabBtn_4)
        
        let tabBtn_5 = NSButton(title: "会员中心", image: NSImage(named: "maintabbar_5_n@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        tabBtn_5.tag = 1104
        tabBtn_5.frame =  CGRect(x: 804, y: 56, width: 55, height: 59)
        tabBtn_5.isBordered = false
        tabBtn_5.imagePosition = .imageAbove
        tabBtn_5.font = NSFont.systemFont(ofSize: 11)
        tabBtn_5.contentTintColor = NSColor(deviceRed: 102/255.0, green: 102/255.0, blue: 102/255.0, alpha: 1)
        tabbarBack.addSubview(tabBtn_5)
        
    }

    func initOtherView(){
        //headerView
        view.addSubview(self.otherWorkView)
        self.otherWorkView.frame = view.frame
        self.otherWorkView.isHidden = true
        
        let width = view.frame.width
        let height = view.frame.height
        let buttonWidth = width / 5.0
        let btnbackHeight = topbarHeight
        let buttonHeight = 60.0
        let buttonTop = 14.0
        let topImgback = CanTapImageView(image: NSImage(named: "otherwork_toolbar_back@2x.png")!)
        self.otherWorkView.addSubview(topImgback)
        topImgback.frame = CGRect(x: 0, y: height - btnbackHeight, width: width, height: btnbackHeight)
        
        topImgback.addSubview(self.toolbar_btn_back)
        self.toolbar_btn_back.frame = CGRect(x: width - buttonWidth, y: 0, width: buttonWidth, height: btnbackHeight)
//---itmes:
        topImgback.addSubview(self.toolbar_btn_home)
        self.toolbar_btn_home.frame = CGRect(x: 0, y: buttonTop, width: buttonWidth, height: 60)
        
        topImgback.addSubview(self.toolbar_btn_route)
        self.toolbar_btn_route.frame = CGRect(x: buttonWidth, y: buttonTop, width: buttonWidth, height: buttonHeight)
        
        topImgback.addSubview(self.toolbar_btn_import)
        self.toolbar_btn_import.frame = CGRect(x: buttonWidth*2, y: buttonTop, width: buttonWidth, height: buttonHeight)
        
        topImgback.addSubview(self.toolbar_btn_add)
        self.toolbar_btn_add.frame = CGRect(x: buttonWidth*3, y: buttonTop, width: buttonWidth, height: buttonHeight)
        
        topImgback.addSubview(self.toolbar_btn_user)
        self.toolbar_btn_user.frame = CGRect(x: width - buttonWidth, y: buttonTop, width: buttonWidth, height: buttonHeight)
        self.toolbar_btn_user.font = NSFont.boldSystemFont(ofSize: 11)
    }
    
    func initRoutePage(){
        pagerouteLoaded = true
        self.otherWorkView.addSubview(self.pageView_route)
        self.pageView_route.showRoutepage { nodeTitle, nodeState in
//nodeState = 0停止，1连接中，2连接成功,99注销
            if !nodeTitle.isEmpty{
                self.nodeRemarkLabel.title = String(" \(nodeTitle)")
            }
            if nodeState >= 0 && nodeState <= 2{
                NotificationCenter.default.post(name: NOTIFY_REFRESH_ROUTE_STATE, object: nodeState)
            }
        }
    }
    
    func initImportPage(){
        pageimportLoaded = true
        self.otherWorkView.addSubview(self.pageView_import)
    }
    
    func initAddPage(){
        pageaddLoaded = true
        self.otherWorkView.addSubview(self.pageView_add)
    }
    
    func initUserPage(){
        pageuserLoaded = true
        self.otherWorkView.addSubview(self.pageView_user)
    }
    
    // MARK: 切换页面
    func showMainWorkView(){
        self.otherWorkView.isHidden = true
        self.mainWorkView.isHidden = false
    }
    
    func showOtherView(iPage:Int){
        self.mainWorkView.isHidden = true
        self.otherWorkView.isHidden = false
        changePage(iPage: iPage)
    }
    
    func changePage(iPage:Int,_ freshRoute:Bool = false){
        if iPage > 0{
            selectPageToolitem(item: iPage)
            if pagerouteLoaded{
                pageView_route.isHidden = true
            }
            if pageimportLoaded{
                pageView_import.isHidden = true
            }
            if pageaddLoaded{
                pageView_add.isHidden = true
            }
            if pageuserLoaded{
                pageView_user.isHidden = true
            }
        }
        
        switch iPage {
        case 0:
            showMainWorkView()
            self.freshUserInfo()
        case 1:
            self.toolbar_btn_route.font = NSFont.boldSystemFont(ofSize: 12)
            if !pagerouteLoaded{
                initRoutePage()
            }else if freshRoute{
               self.pageView_route.loadAllNodeGroup()
            }
            pageView_route.isHidden = false
        case 2:
            self.toolbar_btn_import.font = NSFont.boldSystemFont(ofSize: 12)
            if !pageimportLoaded{
                initImportPage()
            }
            pageView_import.isHidden = false
        case 3:
            self.toolbar_btn_add.font = NSFont.boldSystemFont(ofSize: 12)
            if !pageaddLoaded{
                initAddPage()
            }
            pageView_add.isHidden = false
            
        case 4:
            self.toolbar_btn_user.font = NSFont.boldSystemFont(ofSize: 12)
            if !pageuserLoaded{
                initUserPage()
            }else{
                pageView_user.freshAccoutInfo()
            }
            pageView_user.isHidden = false
            
        default:
            break
        }
    }
    
    func selectPageToolitem(item:Int) {
        let width = view.frame.width
        let buttonWidth = width / 5.0
        let buttonHeight = topbarHeight
        self.toolbar_btn_back.frame = CGRect(x: buttonWidth * CGFloat(item), y: 0, width: buttonWidth, height: buttonHeight)
        
        self.toolbar_btn_route.font = NSFont.systemFont(ofSize: 11)
        self.toolbar_btn_import.font = NSFont.systemFont(ofSize: 11)
        self.toolbar_btn_add.font = NSFont.systemFont(ofSize: 11)
        self.toolbar_btn_user.font = NSFont.systemFont(ofSize: 11)
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
        
        switch sender.tag {
        case 1:
            self.windowController?.close()
            
        case 2:
            self.windowController?.window?.miniaturize(self)
            
        case 3:
            //打开客服
            openHomeUrl("http://chat.liuduyou.com/?n=928117")
        case 168,169:
            showLoginUI()
        case 1000:
            self.noti_proxyState_change(1)
            run_TheProxy {
            }
            
        case 1002:
            Mode.switchTo(.PAC)
        case 1003:
            Mode.switchTo(.GLOBAL)
        case 1101,1102,1103,1104:
            showOtherView(iPage: sender.tag - 1100)
            
        case 2000,2001,2002,2003,2004,2005:
            changePage(iPage: sender.tag - 2000)
            
        default:
            break
        }
        
    }
    
    func showLoginUI(){
        let alertBack = CancelTapView(frame: view.bounds) //直接用NSView，半透明点击会自动
        view.addSubview(alertBack)
        alertBack.wantsLayer = true
        alertBack.layer?.backgroundColor = NSColor(hexString: "#cecece",alpha: 0.75).cgColor
        
        let loginAlert = LoginAlertView.init(frame: CGRect(x: view.bounds.width/2 - 390/2, y: view.bounds.height/2 - 420/2, width: 390, height: 420), parentVC: self)
        alertBack.addSubview(loginAlert)
        loginAlert.showLoginAlert { value in
            if value == "Cancel" || value == "Route"{
                loginAlert.removeFromSuperview()
                alertBack.removeFromSuperview()
            }
            
            if value == "Account"{
                self.freshUserInfo()
                if self.pageuserLoaded{
                    self.pageView_user.freshAccoutInfo()
                }
                self.showToast("登录成功！")
            }else if value == "Route"{
                if self.pagerouteLoaded{
                    self.pageView_route.loadAllNodeGroup()
                }
            }
        }
    }
    
//MARK: noti.pro
    func noti_mode_change() {
        let defaults = UserDefaults.standard
        let mode = defaults.string(forKey: USERDEFAULTS_RUNNING_MODE)
        
        var tag = 1003
        if mode == "auto" {
            tag = 1002
        }
        if let button = mainWorkView.viewWithTag(tag) as? NSButton{
            button.state = .on
        }
    }
    
    func noti_proxyState_change(_ iState:Int){
//iState = 0停止，1连接中，2连接成功
        switch iState {
        case 1:
            self.startProxyButton.isHidden = true
            self.connectButton.changeConnectState(1)
        case 2:
            self.startProxyButton.isHidden = true
            self.connectButton.changeConnectState(2)
            if self.pagerouteLoaded{
                self.pageView_route.resetConnectButtonState()
            }
        default:
            self.startProxyButton.isHidden = false
            self.connectButton.changeConnectState(0)
            if self.pagerouteLoaded{
                self.pageView_route.resetConnectButtonState()
            }
        }
       
    }
    
}



class ConnectButton: NSView{
    lazy var startButton: NSButton = {
        let button = NSButton(image: NSImage(named: "mainwork_startingback@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.isBordered = false
        button.wantsLayer = true
        return button
    }()
    lazy var earthImge: NSButton = {
        let imgView = NSButton(image: NSImage(named: "mainwork_starting@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        imgView.isBordered = false
        imgView.tag = 3
        return imgView
    }()
    lazy var titleLabel: NSTextField = {
        let field = NSTextField(labelWithString: "正在加速")
        field.isBordered = false
        field.isEditable = false
        field.font = NSFont.boldSystemFont(ofSize: 30)
        field.textColor = NSColor("#303030")
        return field
    }()
    lazy var subLabel: NSTextField = {
        let field = NSTextField(labelWithString: "连接中,请稍候...")
        field.isBordered = false
        field.isEditable = false
        field.font = NSFont.systemFont(ofSize: 14)
        field.textColor = NSColor("#666666")
        return field
    }()
    convenience init(frame frameRect: NSRect,andState iState:Int) {
        self.init(frame: frameRect)
        self.initUI(withState: iState)
    }
    
    func initUI(withState iState: Int){
        self.addSubview(self.startButton)
        self.startButton.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
        
        self.addSubview(self.earthImge)
        self.earthImge.frame = CGRect(x: 10, y: 10, width: 68, height: 68)
        
        self.addSubview(self.titleLabel)
        self.titleLabel.frame = CGRect(x: 88+25, y: 43, width: 150, height: 34)
        
        self.addSubview(self.subLabel)
        self.subLabel.frame = CGRect(x: 88+25, y: 11, width: 150, height: 16)
        
        
    }
    
    func changeConnectState(_ iState:Int){
        if 1 == iState{
//连接中
            self.isHidden = false
            self.startButton.tag = 1
            self.titleLabel.stringValue = "正在加速"
            self.subLabel.stringValue = "连接中,请稍候..."
            self.earthImge.image =  NSImage(named: "mainwork_starting@2x.png")!
            self.earthImge.frame = CGRect(x: 10, y: 10, width: 68, height: 68)
//显示动画
            self.startButton.layer?.removeAllAnimations()
            self.startButton.frame = CGRect(x: 0+44, y: 0+44, width: 88, height: 88) //动画时需先设置frame再设置anchorPoint
            self.startButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = -2*Double.pi
            rotateAnimation.duration = 0.75
            rotateAnimation.fillMode = .forwards
            rotateAnimation.isRemovedOnCompletion = false
            rotateAnimation.repeatCount = .infinity
            self.startButton.layer?.add(rotateAnimation, forKey: "start.conntecting")
        }else if 2 == iState{
//已连接
            self.isHidden = false
            self.startButton.tag = 2
            self.titleLabel.stringValue = "已连接"
            self.subLabel.stringValue = "点击断开"
            self.earthImge.image = NSImage(named: "mainwork_stop@2x.png")!
            self.earthImge.frame = CGRect(x: 0, y: 0, width: 88, height: 88)
//动画
            self.startButton.layer?.removeAllAnimations()
            self.startButton.frame = CGRect(x: 0+44, y: 0+44, width: 88, height: 88) //动画时需先设置frame再设置anchorPoint
            self.startButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = -2*Double.pi
            rotateAnimation.duration = 3.6
            rotateAnimation.fillMode = .forwards
            rotateAnimation.isRemovedOnCompletion = false
            rotateAnimation.repeatCount = .infinity
            self.startButton.layer?.add(rotateAnimation, forKey: "start.conntected")
        }else{
            self.startButton.layer?.removeAllAnimations()
            self.isHidden = true
        }
    }
    
    @objc func onTapButton(sender:NSButton){
//断开连接
        if sender.tag >= 2{
//关闭代理
            stop_TheProxy(AndNoti: true) {
                
            }
            
        }
    }
}


class YQPageView: NSView{
    lazy var toolView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor("#F6F6F6").cgColor
        return view
    }()
    
    lazy var toolbarTitleLabel: NSTextField = {
        let textfield = NSTextField(labelWithString: "")
        textfield.font = NSFont.systemFont(ofSize: 14)
        textfield.textColor = NSColor(hexString: "#3F3934")
        textfield.isBordered = false
        textfield.isEditable = false
        return textfield
    }()
    
    var superVC:NodesInfoVC?
    
    convenience init(frame frameRect: NSRect,parentVC:NodesInfoVC) {
        self.init(frame: frameRect)
        self.superVC = parentVC
        initUI()
    }
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    func initUI(){
        let width = self.bounds.width
        let height = self.bounds.height
        self.addSubview(self.toolView)
        self.toolView.frame = CGRect(x: 0, y: height - 64, width: width, height: 64)
        
        let nodeLayer = CALayer()
        toolView.layer?.addSublayer(nodeLayer)
        nodeLayer.frame = CGRect(x: 21, y: 11, width: 2, height: 15)
        nodeLayer.backgroundColor = NSColor("#558EE8").cgColor
        
        toolView.addSubview(self.toolbarTitleLabel)
        self.toolbarTitleLabel.frame = CGRect(x: 34, y: 11, width: 300, height: 16)
    }
}
//MARK: 线路选择页面
class RoutePageView: YQPageView, NSTableViewDelegate,NSTableViewDataSource {
    lazy var startButton: NSButton = {
        let button = NSButton(title: "立即加速", image: NSImage(named: "page_1_start_btn@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.isBordered = false
        button.imagePosition = .imageOverlaps
        button.font = NSFont.systemFont(ofSize: 16)
        button.contentTintColor = NSColor.white
        button.wantsLayer = true
        button.tag = 3000
        return button
    }()
    
    lazy var freshButton: NSButton = {
        let freshBtn = NSButton(image: NSImage(named: "page_1_fresh@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        freshBtn.isBordered = false
        freshBtn.tag = 2999
        return freshBtn
    }()
    
    lazy var leftWorkView: NSView = {
        let view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        return view
    }()
    
    lazy var tableTitle_1: NSTextField = {
        let field = NSTextField(labelWithString: "节点")
        field.font = NSFont.systemFont(ofSize: 14)
        field.textColor = NSColor("#3F3934")
        field.isBordered = false
        field.isEditable = false
        return field
    }()
    
    typealias NodeStateChangeBlock = (String,Int)->Void //回传选中的节点名称及节点连接状态
    var nodeStateChangeBlock: NodeStateChangeBlock?
    
    var tableview: NSTableView!
    var allGroupButtons: [NSButton] = []
    var currentGroupNodes: [[String:AnyObject]] = []
    var nowSelectedNode:[String:AnyObject] = [:]
    var iLastSelectedRow: Int = -1
    var iLastSelectedButton: NSButton? //节点组按钮
    var isFreshing:Bool = false //正在刷新中不能再次点击

    open var proxyGroupNodePings: [String:String] = [:]
//eg:[{"name":"美国-高级路线 T1033","online":"100人","speed":"500ms"}]

    private var nodeTcping: NodeTcping?
    
    func showRoutepage(routeInfo:@escaping NodeStateChangeBlock) {
         self.nodeStateChangeBlock = routeInfo
    }
    
    override func initUI(){
        super.initUI()
        
        var nodeTitle = "尚未选择代理节点"
        if let lastNodeDict = UserDefaults.standard.dictionary(forKey: LAST_PROXY_NODE_IFNO){
            nowSelectedNode = lastNodeDict as [String:AnyObject]
            nodeTitle = nowSelectedNode["Remark"] as! String
        }
        self.toolbarTitleLabel.stringValue = nodeTitle
        
        
        let width = self.frame.width
        let height = self.frame.height
        
        let freshBtn = NSButton(title: "刷新", target: self, action: #selector(onTapButton(sender:)))
        freshBtn.font = NSFont.systemFont(ofSize: 14)
        freshBtn.contentTintColor = NSColor("#3F3934")
        freshBtn.isBordered = false
        freshBtn.tag = 2998
        toolView.addSubview(freshBtn)
        freshBtn.frame = CGRect(x: 647, y: 11, width: 38, height: 17)
        
        toolView.addSubview(self.freshButton)
        self.freshButton.frame = CGRect(x: 687, y: 11, width: 17, height: 17)
        
        toolView.addSubview(self.startButton)
        self.startButton.frame = CGRect(x: 755, y: 8, width: 138, height: 39)
        
        let workHeight = height-64
        let workView = NSView(frame: CGRect(x: 0, y: 0, width: width, height: workHeight))
        self.addSubview(workView)
        
        workView.addSubview(self.leftWorkView)
        self.leftWorkView.frame = CGRect(x: 0, y: 0, width: 178, height: workHeight)
        
        let splitLayer_v = CALayer()
        workView.wantsLayer = true
        workView.layer?.addSublayer(splitLayer_v)
        splitLayer_v.frame = CGRect(x: 178, y: 0, width: 1, height: workHeight)
        splitLayer_v.backgroundColor = NSColor("#E8E8E8").cgColor
        
        let rightWidth = width - 179
        let rightView = NSView(frame: CGRect(x: 179, y: 0, width: rightWidth, height: workHeight))
        workView.addSubview(rightView)
        
        let splitLayer_h = CALayer()
        rightView.wantsLayer = true
        rightView.layer?.addSublayer(splitLayer_h)
        splitLayer_h.frame = CGRect(x: 27, y: workHeight-53, width: rightWidth - 54, height: 1)
        splitLayer_h.backgroundColor = NSColor("#E8E8E8").cgColor
    
        rightView.addSubview(self.tableTitle_1)
        self.tableTitle_1.frame = CGRect(x: 53, y: 350, width: 300, height: 15)
        
        let tableTitle_2 = NSTextField(labelWithString: "操作")
        tableTitle_2.font = NSFont.systemFont(ofSize: 14)
        tableTitle_2.textColor = NSColor(hexString: "#3F3934")
        tableTitle_2.isEditable = false
        tableTitle_2.frame = CGRect(x: 459, y: 350, width: 60, height: 15)
        rightView.addSubview(tableTitle_2)
        
        let tableTitle_3 = NSTextField(labelWithString: "延时状态")
        tableTitle_3.font = NSFont.systemFont(ofSize: 14)
        tableTitle_3.textColor = NSColor(hexString: "#3F3934")
        tableTitle_3.isEditable = false
        tableTitle_3.frame = CGRect(x: 623, y: 350, width: 60, height: 15)
        rightView.addSubview(tableTitle_3)
        
        let scrollbackView = NSView(frame: CGRect(x: 0, y: 0, width: rightWidth, height: workHeight - 54))
        rightView.addSubview(scrollbackView)
        
        let scrollview = CanTapScrollview(frame: scrollbackView.bounds)
        scrollbackView.addSubview(scrollview)
        scrollview.hasVerticalScroller = true
        
        self.tableview = NSTableView(frame: scrollbackView.bounds)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        self.tableview.backgroundColor = NSColor.white
        self.tableview.gridStyleMask = .dashedHorizontalGridLineMask
        self.tableview.gridColor = NSColor("#EFEFEF")
        self.tableview.allowsColumnReordering = false
        self.tableview.intercellSpacing = NSMakeSize(0, 0) //默认2个列之间间隔大概有26，可以通过intercellSpacing来重置间隔
//        self.tableview.columnAutoresizingStyle = .firstColumnOnlyAutoresizingStyle
//        self.tableview.usesAlternatingRowBackgroundColors = true //斑马线
        self.tableview.headerView = nil //不显示标题头
        
        let firstCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier.init("firstCol"))
        firstCol.width = scrollview.bounds.width - 300 //2列之间的间隔约为26
//        firstCol.headerToolTip = "鼠标悬停提示"
        let cell_1 = NSTableHeaderCell()
        cell_1.alignment = .center
        cell_1.stringValue = "节点"
        cell_1.isBordered = false
        firstCol.headerCell = cell_1
        self.tableview.addTableColumn(firstCol)
        let secondCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier.init("secondCol"))
        secondCol.width = 150
        let cell_2 = NSTableHeaderCell()
        cell_2.alignment = .center
        cell_2.stringValue = "操作"
        cell_2.isBordered = false
        secondCol.headerCell = cell_2
        self.tableview.addTableColumn(secondCol)
        let thirdCol = NSTableColumn(identifier: NSUserInterfaceItemIdentifier.init("thirdCol"))
        thirdCol.width =  150
        let cell_3 = NSTableHeaderCell()
        cell_3.alignment = .center
        cell_3.stringValue = "延时状态"
        cell_3.isBordered = false
        thirdCol.headerCell = cell_3
        self.tableview.addTableColumn(thirdCol)
        scrollview.documentView = self.tableview

        loadAllNodeGroup()
    }
    
    func loadAllNodeGroup(){
        //先读取所有订阅节点组
        self.currentGroupNodes.removeAll()
        var groupTitles:[String] = []
        if let groupList = UserDefaults.standard.array(forKey: SUBSCRIBE_Info_KEY){
            for list in groupList {
                let dict = list as! [String:AnyObject]
                let groupTitle = dict["group"] as! String
                let has_nodeClass = dict["nodeClass"] as! String
                if has_nodeClass == "1"{
                    groupTitles.append(String(format: "\(groupTitle)\n普通线路"))
                    groupTitles.append(String(format: "\(groupTitle)\n高级线路"))
                }else{
                    groupTitles.append(groupTitle)
                }
            }
        }
        //最后读取默认节点组
        if let _ = UserDefaults.standard.array(forKey: NODE_PROFILE_KEY) {
            groupTitles.append("其.它.节.点")
        }
        createLeftButtons(groupTitles)
        if self.allGroupButtons.count > 0 {
            if (iLastSelectedButton != nil){//还原上一个组状态
                iLastSelectedButton?.layer?.backgroundColor = NSColor.white.cgColor
                iLastSelectedButton?.contentTintColor = NSColor("#666666")
            }
            iLastSelectedButton = self.allGroupButtons[0]
            iLastSelectedButton?.layer?.backgroundColor = NSColor("#E6F0FE").cgColor
            iLastSelectedButton?.contentTintColor = NSColor("#3B79E0")
        }
        showCurrentGroupNodes()
    }
    
    func createLeftButtons(_ groupList:[String]){
//根据节点组，创建对应组按钮
        self.allGroupButtons.removeAll()
        for subview in self.leftWorkView.subviews {
            subview.removeFromSuperview()
        }
        
        if 0 == groupList.count{
            return
        }
        
        let back_Width = self.leftWorkView.bounds.width
        let back_height = self.leftWorkView.bounds.height
        let btn_width = back_Width - 30
        let iJG = groupList.count <= 6 ? 60.0 : 46.0
        var btn_top = back_height - iJG
        for i in 0 ..< groupList.count {
            let button = NSButton(title: groupList[i] , target: self, action: #selector(onTapButton(sender:)))
            button.tag = 3001 + i
            self.leftWorkView.addSubview(button)
            button.frame = CGRect(x: 15.0, y: btn_top, width: btn_width, height: 40)
            button.font = NSFont.systemFont(ofSize: 14)
            button.contentTintColor = NSColor("#666666")
            button.isBordered = false
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.white.cgColor
            button.layer?.borderWidth = 1
            button.layer?.borderColor = NSColor("#E8E8E8").cgColor
            button.layer?.cornerRadius = 5
            btn_top -= iJG
            self.allGroupButtons.append(button)
        }
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
//        NSLog("\(sender.title).\(sender.state)")
        if 222 == sender.tag{
//编辑
            if let tips = sender.toolTip {
                let comps = tips.components(separatedBy: ":")
                if comps.count > 1{
                    if let iRow = Int(comps[1]){
                        NSLog("编辑：\(sender.title)[\(String(describing: iRow))]")
                        let nodeKey = getCurrentNodeGroupKey()
                        if  nodeKey != nil && !nodeKey!.isEmpty{
//    在添加节点里进行编辑：
                            self.superVC?.pageView_add.modiNodeInfo(nodeKey: nodeKey!, nodeIndex: iRow)
                            self.superVC?.changePage(iPage: 3)
                        }
                        
                    }
                }
            }
        }
        else if 223 == sender.tag{
//删除
            if let tips = sender.toolTip {
                let comps = tips.components(separatedBy: ":")
                if comps.count > 1{
                    if let iRow = Int(comps[1]){ //非数字序号不处理
                        NSLog("删除：\(sender.title)[\(String(describing: iRow))]")
//将该节点，从当前组中删除
                        let nodeKey = getCurrentNodeGroupKey()
                        if  nodeKey != nil && !nodeKey!.isEmpty{
                            if let nodes = UserDefaults.standard.array(forKey: nodeKey!) {
                                if nodes.count > iRow{
                                    var tmpNodes = nodes
                                    tmpNodes.remove(at: iRow)
                                    UserDefaults.standard.set(tmpNodes, forKey: nodeKey!)
                                    UserDefaults.standard.synchronize()
//然后更新tableView
                                    self.showCurrentGroupNodes()
                                }
                            }
                        }
                    }

                   
                }
            }
        }
        else if 2998 == sender.tag || 2999 == sender.tag{
//刷新节点时延状态
            if (!isFreshing){
                freshGroupNodes()
            }
        }
        else if 3000 == sender.tag{
//立即加速(当前所选节点)
            doConnectProxyNode()
        }
        else if sender.tag > 3000{
//分组查询按钮
            if (iLastSelectedButton != nil){
                iLastSelectedButton?.layer?.backgroundColor = NSColor.white.cgColor
                iLastSelectedButton?.contentTintColor = NSColor("#666666")
            }
            sender.layer?.backgroundColor = NSColor("#E6F0FE").cgColor
            sender.contentTintColor = NSColor("#3B79E0")
            iLastSelectedButton = sender
            showCurrentGroupNodes()
        }
    }
    
    func getCurrentNodeGroupKey()->String?{
        if iLastSelectedButton != nil{
            let title = iLastSelectedButton?.title
            let titleGroup = title!.components(separatedBy: "\n")
            var key = String(format: "\(SUBSCRIBE_PROFILE_KEY).\(titleGroup[0])")
            if titleGroup[0] == "其.它.节.点" {
                key = NODE_PROFILE_KEY
            }
            return key
        }
        else{
            return nil
        }
    }
    
    func resetFreshButton(){
        self.freshButton.layer?.removeAllAnimations()
        self.freshButton.frame = CGRect(x: 687, y: 11, width: 17, height: 17)
        self.freshButton.isEnabled = true
        isFreshing = false
    }
    
    func freshNodeSpeed(_ reloadNodes:Bool) {
//检测节点时延，对本组节点进行ping检测
        if reloadNodes{
            self.justReloadGroupNodes()
        }
        
        self.nodeTcping = NodeTcping()
        self.nodeTcping?.ping(self.currentGroupNodes) {
            DispatchQueue.main.async {
                self.showCurrentGroupNodes()
                self.resetFreshButton()
            }
        }
    }
    
    func freshGroupNodes(){
        isFreshing = true
        
        if iLastSelectedButton == nil {
            self.superVC?.showToast("请点击要刷新的节点组")
            self.resetFreshButton()
            return
        }
//    刷新，如果本节点组为当日首次刷新，则更新节点，然后检查时延；否则只做检查时延操作？
//更新动画
        self.freshButton.isEnabled = false
        self.freshButton.frame = CGRect(x: 687+9, y: 11+9, width: 18, height: 18)
        self.freshButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -2*Double.pi
        rotateAnimation.duration = 1.8
        rotateAnimation.fillMode = .forwards
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.repeatCount = .infinity
        self.freshButton.layer?.add(rotateAnimation, forKey: "freshButton.ani")
        

        let title = iLastSelectedButton?.title
        if title == "其.它.节.点"{
            self.freshNodeSpeed(false)
            return
        }
        
        let iRand = arc4random_uniform(10) //0...9
        if iRand < 3 {
//简单点处理：30%的机会，刷新时会重新拉取订阅节点
            let titleGroup = title!.components(separatedBy: "\n")
            if let groupList = UserDefaults.standard.array(forKey: SUBSCRIBE_Info_KEY){
                for list in groupList {
                    let dict = list as! [String:AnyObject]
                    let groupTitle = dict["group"] as! String
                    if groupTitle == titleGroup[0]{
                        let uri = dict["uri"] as! String
                        DispatchQueue.global().async {
                            let url = URL(string: uri)!
                            guard let urlContent = try? String(contentsOf: url) else {
                                self.freshNodeSpeed(false)
                                return
                            }
                            //   先判断内容是否为base64编码内容
                            let decodeContent = urlContent.base64DecodeStr()
                            if (decodeContent != nil){
                                importNodeList(decodeContent!, Url: uri, GroupTitle: groupTitle,IsModi: true) { success, errMsg in
                                    self.freshNodeSpeed(success)
                                    return
                                }
                            }
                            else{//非base64的URL内容，则当成yaml文件内容处理
                                //              string转Data，然后进入yaml解析
                                let yamlData=urlContent.data(using: .utf8)!
                                let importer_obj : Importer_oc = Importer_oc()
                                let proxyArr: [Any] = importer_obj.loadYamlData(yamlData)
                                guard proxyArr.count>0 else{
                                    self.freshNodeSpeed(false)
                                    return
                                }
                                importYamlDict(proxyArr as! [[String: AnyObject]],Url: uri,GroupTitle: groupTitle,IsModi: true) { success, errMsg in
                                    DispatchQueue.main.async {
                                        self.freshNodeSpeed(success)
                                        return
                                    }
                                }
                            }
                        }
                        return
                    }
                }
            }
        }else{
            self.freshNodeSpeed(false)
        }
    
    }
    
    
    func doConnectProxyNode(){
        if nowSelectedNode.count > 0 {
            //显示连接动画，
            self.startButton.title = ""
            self.startButton.image = NSImage(named: "mainwork_startingback@2x.png")!
            self.startButton.wantsLayer = true
            self.startButton.layer?.cornerRadius = 20
            self.startButton.layer?.borderColor = NSColor("#8cd0ff").cgColor
            self.startButton.layer?.borderWidth = 1.5
            self.startButton.frame = CGRect(x: 755 + 49 + 20, y: 8 + 20, width: 40, height: 40)
            self.startButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            self.startButton.isEnabled = false
            let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
            rotateAnimation.fromValue = 0.0
            rotateAnimation.toValue = -2*Double.pi
            rotateAnimation.duration = 1.6
            rotateAnimation.fillMode = .forwards
            rotateAnimation.isRemovedOnCompletion = false
            rotateAnimation.repeatCount = .infinity
            self.startButton.layer?.add(rotateAnimation, forKey: "startButton.ani")
            
            //如果是已经启动状态，则先关闭再开启？
            let isOn = UserDefaults.standard.bool(forKey: USERDEFAULTS_TROJAN_ON)
            if isOn  {
    //同步更新首页节点地址，如果是已连接状态，则自动切换到新节点上？
    //简单点，不同步更新到首页，需用户再次点击连接，才连接
                if nowSelectedNode.count > 0 {
                    stop_TheProxy(AndNoti: false){
                        let walltime = DispatchWallTime.now()+1.25
                        DispatchQueue.main.asyncAfter(wallDeadline: walltime){
                            self.startProxyNode()
                        }
                    }
                }
            }else{
                startProxyNode()
            }
        }
    }
    
    func resetConnectButtonState(){
        self.startButton.layer?.removeAllAnimations()
        self.startButton.frame = CGRect(x: 755, y: 8, width: 138, height: 39)
        self.startButton.title = "立即加速"
        self.startButton.image = NSImage(named: "page_1_start_btn@2x.png")!
        self.startButton.imagePosition = .imageOverlaps
        self.startButton.layer?.borderWidth = 0
        self.startButton.layer?.cornerRadius = 0
        self.startButton.isEnabled = true
    }
    
    func startProxyNode(){
        if nowSelectedNode.count > 0 {
            let dict = nowSelectedNode
            UserDefaults.standard.set(dict, forKey: LAST_PROXY_NODE_IFNO)//先记录当前启动的节点,下次App启动时默认打开该节点
            UserDefaults.standard.synchronize()
            let remark = dict["Remark"] as! String
            if self.nodeStateChangeBlock != nil {
                self.nodeStateChangeBlock!(remark,1)
            }
            run_TheProxy {
            }
        }
    }
    
    func selectProxyNode(){
//        let isOn = UserDefaults.standard.bool(forKey: USERDEFAULTS_TROJAN_ON)
//        if isOn  {
////同步更新首页节点地址，如果是已连接状态，则自动切换到新节点上？
////简单点，不同步更新到首页，需用户再次点击连接，才连接
//        }else{
            if nowSelectedNode.count > 0 {
                let dict = nowSelectedNode
                UserDefaults.standard.set(dict, forKey: LAST_PROXY_NODE_IFNO)//先记录当前启动的节点,下次App启动时默认打开该节点
                UserDefaults.standard.synchronize()
                let remark = dict["Remark"] as! String
                if self.nodeStateChangeBlock != nil {
                    self.nodeStateChangeBlock!(remark,9) //只改变名称，不改变状态
                }
            }
//        }
    }
    
    func justReloadGroupNodes(){
        if iLastSelectedButton != nil{
            self.currentGroupNodes.removeAll()
            let title = iLastSelectedButton?.title
            let titleGroup = title!.components(separatedBy: "\n")
            let splitTitle = titleGroup.count > 1 ? titleGroup[1] : ""
            var key = String(format: "\(SUBSCRIBE_PROFILE_KEY).\(titleGroup[0])")
            if titleGroup[0] == "其.它.节.点" {
                key = NODE_PROFILE_KEY
            }
            if let nodes = UserDefaults.standard.array(forKey: key) {
                for i in 0 ..< nodes.count{
                    let node = nodes[i] as! [String:AnyObject]
                    let remark = node["Remark"] as! String
                    if remark.contains("剩余流量：") {
                    }else if remark.contains("过期时间："){
                    }else{
                        if splitTitle.isEmpty {
                            self.currentGroupNodes.append(node)
                        }else if splitTitle == "普通线路"{
                            if let nodeClass = node["nodeClass"] {
                                if (nodeClass as! Int) < 4 {
                                    self.currentGroupNodes.append(node)
                                }
                            }
                        }else if splitTitle == "高级线路"{
                            if let nodeClass = node["nodeClass"] {
                                if (nodeClass as! Int) >= 4 {
                                    self.currentGroupNodes.append(node)
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    func showCurrentGroupNodes(){
        self.currentGroupNodes.removeAll()
        self.tableTitle_1.stringValue = "节点"
        if iLastSelectedButton != nil{
            let title = iLastSelectedButton?.title
            let titleGroup = title!.components(separatedBy: "\n")
            let splitTitle = titleGroup.count > 1 ? titleGroup[1] : ""
            var groupStatus:String?
            var key = String(format: "\(SUBSCRIBE_PROFILE_KEY).\(titleGroup[0])")
            if titleGroup[0] == "其.它.节.点" {
                key = NODE_PROFILE_KEY
            }else{
//判断节点组是否存在groupStatus流量及过期时间说明
                if let groupList = UserDefaults.standard.array(forKey: SUBSCRIBE_Info_KEY){
                    for list in groupList {
                        let dict = list as! [String:AnyObject]
                        let groupTitle = dict["group"] as! String
                        if groupTitle == titleGroup[0]{
                            groupStatus = dict["groupStatus"] as? String
                            break
                        }
                    }
                }
            }
            
            if let nodes = UserDefaults.standard.array(forKey: key) {
                for i in 0 ..< nodes.count{
                    let node = nodes[i] as! [String:AnyObject]
                    let remark = node["Remark"] as! String
                    if remark.contains("剩余流量：") {
                        self.tableTitle_1.stringValue = String(format: "\(self.tableTitle_1.stringValue) | \(remark)")
                    }else if remark.contains("过期时间："){
                        self.tableTitle_1.stringValue = String(format: "\(self.tableTitle_1.stringValue) | \(remark)")
                    }else{
                        if splitTitle.isEmpty {
                            self.currentGroupNodes.append(node)
                        }else if splitTitle == "普通线路"{
                            if let nodeClass = node["nodeClass"] {
                                if (nodeClass as! Int) < 4 {
                                    self.currentGroupNodes.append(node)
                                }
                            }
                        }else if splitTitle == "高级线路"{
                            if let nodeClass = node["nodeClass"] {
                                if (nodeClass as! Int) >= 4 {
                                    self.currentGroupNodes.append(node)
                                }
                            }
                        }
                    }
                }
            }
            if !self.tableTitle_1.stringValue.contains("|"){
                if groupStatus != nil {
                    if !groupStatus!.isEmpty{
                        self.tableTitle_1.stringValue = String(format: "\(self.tableTitle_1.stringValue) | \(groupStatus!)")
                    }
                }
            }
        }
    
        let label_title = self.tableTitle_1.stringValue
        if self.tableTitle_1.stringValue.contains("|"){
            let addrMutableString = NSMutableAttributedString(string: label_title, attributes:
                                                                [NSAttributedString.Key.foregroundColor:NSColor("#3B79E0"),NSAttributedString.Key.font:NSFont.systemFont(ofSize: 10)])
            addrMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor("#3F3934"), range: NSRange(location:0,length:2))
            addrMutableString.addAttribute(NSAttributedString.Key.font, value: NSFont.systemFont(ofSize: 14), range: NSRange(location:0,length:2))
            self.tableTitle_1.attributedStringValue = addrMutableString
        }else{
            
            let addrMutableString = NSMutableAttributedString(string: label_title, attributes:
                                                                [NSAttributedString.Key.foregroundColor:NSColor("#3F3934"),NSAttributedString.Key.font:NSFont.systemFont(ofSize: 14)])
            self.tableTitle_1.attributedStringValue = addrMutableString
        }
        
        self.tableview.reloadData()
    }
    
    
//MARK: table
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.currentGroupNodes.count
   }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if self.currentGroupNodes.count > 0 {
            let dict = self.currentGroupNodes[row]
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("firstCol"){
                let cell = tableview.makeView(withIdentifier: NSUserInterfaceItemIdentifier("firstCol"), owner: nil)
                if cell == nil{
                    let text = NSTextField(labelWithString: dict["Remark"] as! String)
                    text.textColor = NSColor("#3F3934")
                    text.font = NSFont.systemFont(ofSize: 14)
                    text.isBordered = false
                    text.isEditable = false
                    text.tag = 123
                    //                text.drawsBackground = true
                    //                text.backgroundColor = NSColor.orange
                    
                    let cellView = NSTableCellView()
                    cellView.identifier = NSUserInterfaceItemIdentifier("firstCol")
                    cellView.addSubview(text)
                    text.snp.makeConstraints { make in
                        make.centerY.equalTo(cellView)
                        make.left.equalTo(30)
                        make.right.equalTo(-10)
                    }
                    if tableView.selectedRow == row{
                        text.textColor = NSColor("#3B79E0")
                    }
                    
                    return cellView
                }else{
                    let cellView = cell as! NSTableCellView
                    let text = cellView.viewWithTag(123) as! NSTextField
                    if tableView.selectedRow == row{
                        text.textColor = NSColor("#3B79E0")
                    }else{
                        text.textColor = NSColor("#3F3934")
                    }
                    text.stringValue = dict["Remark"] as! String
                    return cellView
                }
            }
            else if tableColumn?.identifier == NSUserInterfaceItemIdentifier("secondCol"){
                let cell = tableview.makeView(withIdentifier: NSUserInterfaceItemIdentifier("secondCol"), owner: nil)
                if cell == nil{
                    let btn_edit = NSButton(title: "编辑", target: self, action: #selector(onTapButton(sender:)))
                    btn_edit.isBordered = false
                    btn_edit.font = NSFont.systemFont(ofSize: 14)
                    btn_edit.contentTintColor = NSColor("#3F3934")
                    btn_edit.tag = 222
                    btn_edit.toolTip = String("编辑节点:\(row)")
                    let btn_del = NSButton(title: "删除", target: self, action: #selector(onTapButton(sender:)))
                    btn_del.isBordered = false
                    btn_del.font = NSFont.systemFont(ofSize: 14)
                    btn_del.contentTintColor = NSColor("#3F3934")
                    btn_del.tag = 223
                    btn_del.toolTip = String("删除节点:\(row)")
                    let imageView = NSImageView(image: NSImage(named: "online_n")!)
                    imageView.tag = 224
                    
                    let cellView = NSTableCellView()
                    cellView.identifier = NSUserInterfaceItemIdentifier("secondCol")
                    cellView.addSubview(btn_edit)
                    cellView.addSubview(btn_del)
                    cellView.addSubview(imageView)
                    imageView.snp.makeConstraints { make in
                        make.centerY.equalTo(cellView)
                        make.left.equalTo(0)
                        make.width.height.equalTo(13)
                    }
                    btn_edit.snp.makeConstraints { make in
                        make.centerY.equalTo(cellView)
                        make.left.equalTo(imageView.snp.right).offset(5)
                        make.width.equalTo(40)
                        make.height.equalTo(36)
                    }
                    btn_del.snp.makeConstraints { make in
                        make.centerY.equalTo(cellView)
                        make.left.equalTo(btn_edit.snp.right).offset(5)
                        make.width.equalTo(40)
                        make.height.equalTo(36)
                    }
                    
                    if tableView.selectedRow == row{
//                        btn_edit.contentTintColor = NSColor("#3B79E0")
//                        btn_del.contentTintColor = NSColor("#3B79E0")
                        imageView.image = NSImage(named: "online_h")!
                    }
                    return cellView
                }else{
                    let cellView = cell as! NSTableCellView
                    let btn_edit = cellView.viewWithTag(222) as! NSButton
                    btn_edit.toolTip = String("编辑节点:\(row)")
                    let btn_del = cellView.viewWithTag(223) as! NSButton
                    btn_del.toolTip = String("删除节点:\(row)")
                    let imageView = cellView.viewWithTag(224) as! NSImageView
                    if tableView.selectedRow == row{
//                        btn_edit.contentTintColor = NSColor("#3B79E0")
//                        btn_del.contentTintColor = NSColor("#3B79E0")
                        imageView.image = NSImage(named: "online_h")!
                    }else{
//                        btn_edit.contentTintColor = NSColor("#3F3934")
//                        btn_del.contentTintColor = NSColor("#3F3934")
                        imageView.image = NSImage(named: "online_n")!
                    }
                    return cellView
                }
                
            }
            else{
                var latency = dict["latency"]
                if latency == nil {
                    let host  = dict["ServerHost"] as! String
                    let port = (dict["ServerPort"] as! NSNumber).uint16Value
                    let speedKey = String("latency.\(host).\(port)")
                    latency = UserDefaults.standard.string(forKey: speedKey) as AnyObject?
                }
                
                let cell = tableview.makeView(withIdentifier: NSUserInterfaceItemIdentifier("thirdCol"), owner: nil)
                if cell == nil{
                    let text = NSTextField(labelWithString: "")
                    text.textColor = NSColor("#6F737C")
                    text.font = NSFont.systemFont(ofSize: 14)
                    text.isBordered = false
                    text.isEditable = false
                    text.tag = 323
                    let imageView = NSImageView(image: NSImage(named: "speed_50")!)
                    imageView.tag = 324
                    
                    if latency == nil {
                        text.stringValue = "-- --"
                        imageView.image = NSImage(named: "speed_0")!
                        text.textColor = NSColor("#6F737C")
                    }else{
                        let iLatency = Int(latency as! String)!
                        text.stringValue = String("\(iLatency) ms")
                        if 0 == iLatency{
                            imageView.image = NSImage(named: "speed_0")!
                            text.textColor = NSColor("#6F737C")
                            text.stringValue = "-- --"
                        }
                        else if iLatency < 122 {
                            imageView.image = NSImage(named: "speed_50")!
                            text.textColor = NSColor("#75D66B")
                        }else if iLatency < 500 {
                            imageView.image = NSImage(named: "speed_100")!
                            text.textColor = NSColor("#FFCC30")
                        }else if iLatency >= 500 {
                            imageView.image = NSImage(named: "speed_500")!
                            text.textColor = NSColor("#F28462")
                        }
                    }
                    let cellView = NSTableCellView()
                    cellView.identifier = NSUserInterfaceItemIdentifier("thirdCol")
                    cellView.addSubview(text)
                    cellView.addSubview(imageView)
                    imageView.snp.makeConstraints { make in
                        make.centerY.equalTo(cellView)
                        make.left.equalTo(0)
                        make.width.height.equalTo(13)
                    }
                    text.snp.makeConstraints { make in
                        make.centerY.equalTo(cellView)
                        make.left.equalTo(imageView.snp.right).offset(5)
                        make.right.equalTo(-10)
                    }
                    return cellView
                }else{
                    let cellView = cell as! NSTableCellView
                    let text = cellView.viewWithTag(323) as! NSTextField
                    let imageView = cellView.viewWithTag(324) as! NSImageView
                    
                    if latency == nil {
                        imageView.image = NSImage(named: "speed_0")!
                        text.textColor = NSColor("#6F737C")
                        text.stringValue = "-- --"
                    }else{
                        let iLatency = Int(latency as! String)!
                        text.stringValue = String("\(iLatency) ms")
                        if 0 == iLatency{
                            imageView.image = NSImage(named: "speed_0")!
                            text.textColor = NSColor("#6F737C")
                            text.stringValue = "-- --"
                        }
                        else if iLatency < 122 {
                            imageView.image = NSImage(named: "speed_50")!
                            text.textColor = NSColor("#75D66B")
                        }else if iLatency < 500 {
                            imageView.image = NSImage(named: "speed_100")!
                            text.textColor = NSColor("#FFCC30")
                        }else if iLatency >= 500 {
                            imageView.image = NSImage(named: "speed_500")!
                            text.textColor = NSColor("#F28462")
                        }
                    }
                    
                    return cellView
                }
            }
        }else{
            return nil
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = YQTableRowView()
        rowView.isEmphasized = false
        return rowView
    
    }
    
     func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 45
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object
        if tableView != nil{
            let iRow = (tableView! as! NSTableView).selectedRow
            NSLog("选择\(iRow)")
            changeRowCellState(atRow: iRow, whenSeleted: true)
            if self.currentGroupNodes.count > iRow{
                self.toolbarTitleLabel.stringValue = self.currentGroupNodes[iRow]["Remark"] as! String
                nowSelectedNode = self.currentGroupNodes[iRow]
                selectProxyNode()
            }
            if(iLastSelectedRow>=0 && iLastSelectedRow != iRow){
                changeRowCellState(atRow: iLastSelectedRow, whenSeleted: false)
            }
            iLastSelectedRow = iRow
        }
        
    }
    
    func changeRowCellState(atRow:Int,whenSeleted:Bool){
        let cell_0 = self.tableview.view(atColumn: 0, row: atRow, makeIfNecessary: false)
        if cell_0 != nil{
            let cellView = cell_0 as! NSTableCellView
            let textfield = cellView.viewWithTag(123) as! NSTextField
            textfield.textColor = whenSeleted ? NSColor("#3B79E0") : NSColor("#3F3934")
        }
        
        let cell_1 = self.tableview.view(atColumn: 1, row: atRow, makeIfNecessary: false)
        if cell_1 != nil{
            let cellView = cell_1 as! NSTableCellView
//            let btn_edit = cellView.viewWithTag(222) as! NSButton
//            let btn_del = cellView.viewWithTag(223) as! NSButton
            let imageView = cellView.viewWithTag(224) as! NSImageView
//            btn_edit.contentTintColor = whenSeleted ? NSColor("#3B79E0") : NSColor("#3F3934")
//            btn_del.contentTintColor = whenSeleted ? NSColor("#3B79E0") : NSColor("#3F3934")
            imageView.image = whenSeleted ? NSImage(named: "online_h")! : NSImage(named: "online_n")!
        }
    }
}


//MARK: 导入配置页面
class ImportNodePage: YQPageView {
    lazy var pathField: NSTextField = {
        let field = NSTextField()
        field.isBordered = true
        field.isEditable = true
        field.font = NSFont.systemFont(ofSize: 14)
        field.textColor = NSColor("#303030")
        field.backgroundColor = NSColor("#E8E8E8")
        field.alignment = .left
        let testAttributes = [NSAttributedString.Key.foregroundColor: NSColor(hexString:"#666666",alpha:0.7)] as [NSAttributedString.Key : Any]
        let testAttributeString = NSAttributedString(string: "请输入有效的uri(支持http://,https://,ssr://,trojan://等)", attributes:testAttributes)
        field.placeholderAttributedString = testAttributeString
        return field
    }()
    
    lazy var importButton: NSButton = {
        let button = NSButton(title: "导 入", image: NSImage(named: "page_1_start_btn@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.isBordered = false
        button.imagePosition = .imageOverlaps
        button.font = NSFont.systemFont(ofSize: 16)
        button.contentTintColor = NSColor.white
        button.tag = 4000
        return button
    }()
    
    var currentGroupTitle:String?
    
    override func initUI(){
        super.initUI()
        self.toolbarTitleLabel.stringValue = "导入配置-从连接导入"
        
        let width = self.bounds.width
        let height = self.bounds.height
        
        let workView = NSView(frame: CGRect(x: 0, y: 0, width: width, height: height-64))
        self.addSubview(workView)
        workView.wantsLayer = true
        workView.layer?.backgroundColor = NSColor.white.cgColor
        
        workView.addSubview(self.pathField)
        self.pathField.frame = CGRect(x: 72, y: 316, width: 610, height: 39)
        
        workView.addSubview(self.importButton)
        self.importButton.frame = CGRect(x: 721, y: 316, width: 138, height: 39)
        
        let btn_subscribe = NSButton(title: "订阅", target: self, action: #selector(onTapButton(sender:)))
        btn_subscribe.tag = 4001
        workView.addSubview(btn_subscribe)
        btn_subscribe.frame = CGRect(x: 76, y: 283, width: 30, height: 15)
        btn_subscribe.isBordered = false
        btn_subscribe.font = NSFont.systemFont(ofSize: 12)
        btn_subscribe.contentTintColor = NSColor("#3B79E0")
        let attributes_1 = [NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        let attributeString_1 = NSAttributedString(string: "订阅", attributes:attributes_1)
        btn_subscribe.attributedTitle = attributeString_1
        
        let btn_teach = NSButton(title: "使用教程", target: self, action: #selector(onTapButton(sender:)))
        btn_teach.tag = 4002
        workView.addSubview(btn_teach)
        btn_teach.frame = CGRect(x: 142, y: 283, width: 60, height: 15)
        btn_teach.isBordered = false
        btn_teach.font = NSFont.systemFont(ofSize: 12)
        btn_teach.contentTintColor = NSColor("#3B79E0")
        let attributes_2 = [NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        let attributeString_2 = NSAttributedString(string: "使用教程", attributes:attributes_2)
        btn_teach.attributedTitle = attributeString_2
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
        
        if sender.tag == 4000{
//导入节点
            let uri = self.pathField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines) //空格换行不算
            if uri .isEmpty{
                self.superVC?.showToast("请输入有效的uri地址")
                return
            }
            
            let okuri = uri.lowercased()
            if okuri.hasPrefix("ssr://") {
                if let ssrProfile = importSSR(uri){
                    ssrProfile.appendNewNode()
                    self.superVC?.showToast("SSR节点导入成功！")
                    self.superVC?.changePage(iPage: 1,true)
                }
            }
            else if okuri.hasPrefix("trojan://") {
                if let trojanProfile = importTrojan(uri) {
                    trojanProfile.appendNewNode()
                    self.superVC?.showToast("Trojan节点导入成功！")
                    self.superVC?.changePage(iPage: 1,true)
                }
            }
            else if okuri.hasPrefix("http://") || okuri.hasPrefix("https://") {
//显示节点组输入框，先输入组名，才进行下一步
//          let alertBack = NSVisualEffectView(frame: self.bounds)
//使用NSVisualEffectView，其上的添加的控制颜色无法控制
                let alertBack = CancelTapView(frame: self.bounds) //直接用NSView，半透明点击会自动
                self.addSubview(alertBack)
                alertBack.wantsLayer = true
                alertBack.layer?.backgroundColor = NSColor(hexString: "#cecece",alpha: 0.75).cgColor
                
                let inputAlert = InputAlertView.init(frame: CGRect(x: self.bounds.width/2 - 150, y: self.bounds.height - 50 - 150, width: 300, height: 150),parentVC: self.superVC)
                alertBack.addSubview(inputAlert)
                inputAlert.showAlert { value in
                    inputAlert.removeFromSuperview()
                    alertBack.removeFromSuperview()
                    
                    self.currentGroupTitle = value
                    self.importHttp(uri,ShowToast: true)
                }
            }
            else{
                self.superVC?.showToast("暂不支持的uri格式，请输入有效的uri地址")
            }
        }
        else if sender.tag == 4001{
            
        }
        else if sender.tag == 4002{
            
        }
        
    }
    
    func importSSR(_ uriString:String) -> SSRProfile?{
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
            self.superVC?.showToast("!error.uri.format")
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
            self.superVC?.showToast("!error.ssr.hostSection")
            return nil
        }

        guard let p = Int(hostComps[1]) else {//12127
            self.superVC?.showToast("!error.ssr.port")
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
    
    func importTrojan(_ uriString:String) -> TrojanProfile?{
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

        let otherArr=uriString.components(separatedBy: "?") //先判断是否有？隔开的参数
        let leftStr=otherArr[0]
        let firstArr = leftStr.components(separatedBy: "@")
        guard firstArr.count == 2 else {
            self.superVC?.showToast("!error.trojan.hostSection")
            return nil
        }
        let hostString: String = firstArr[1]
        let hostComps = hostString.components(separatedBy: ":")
        guard hostComps.count == 2 else {
            self.superVC?.showToast("!error.trojan.hostport")
            return nil
        }
        guard let p = Int(hostComps[1]) else {
            self.superVC?.showToast("!error.trojan.port")
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
    
    func importHttp(_ uri:String,ShowToast bShow:Bool){
        if (self.currentGroupTitle == nil || self.currentGroupTitle!.isEmpty){
            if bShow{
                self.superVC?.showToast("请先输入节点组名称！")
            }
            return
        }
        if bShow{
            animateImportButton()
        }
//订阅地址导入,
        DispatchQueue.global().async {
            let url = URL(string: uri)!
            guard let urlContent = try? String(contentsOf: url) else {
                if bShow{
                    self.showImportMsg("Failed:load.urldata.error")
                }
                return
            }
//   先判断内容是否为base64编码内容
            let decodeContent = urlContent.base64DecodeStr()
            if (decodeContent != nil){
                importNodeList(decodeContent!, Url: uri, GroupTitle: self.currentGroupTitle!,IsModi: false) { success, errMsg in
                    DispatchQueue.main.async {
                        if bShow{
                            if success{
                                self.superVC?.showToast("节点组导入成功！")
                                self.superVC?.changePage(iPage: 1,true)
                            }else{
                                self.superVC?.showToast(errMsg)
                            }
                            self.resetImportButton()
                        }
                        
                    }
                }
            }
            else{//非base64的URL内容，则当成yaml文件内容处理
//              string转Data，然后进入yaml解析
                let yamlData=urlContent.data(using: .utf8)!
                let importer_obj : Importer_oc = Importer_oc()
                let proxyArr: [Any] = importer_obj.loadYamlData(yamlData)
                guard proxyArr.count>0 else{
                    if bShow{
                        self.showImportMsg("Failed:load.yamldata.error")
                    }
                    return
                }
                importYamlDict(proxyArr as! [[String: AnyObject]],Url: uri,GroupTitle: self.currentGroupTitle!,IsModi: false) { success, errMsg in
                    DispatchQueue.main.async {
                        if bShow{
                            if success{
                                self.superVC?.showToast("节点组导入成功！")
                                self.superVC?.changePage(iPage: 1,true)
                            }else{
                                self.superVC?.showToast(errMsg)
                            }
                            self.resetImportButton()
                        }
                    }
                }
            }
            
            DispatchQueue.main.async {
                if bShow{
                    self.resetImportButton()
                }
            }
        }
    }
    
    func animateImportButton(){
        self.importButton.title = ""
        self.importButton.image = NSImage(named: "mainwork_startingback@2x.png")!
        self.importButton.wantsLayer = true
        self.importButton.layer?.cornerRadius = 20
        self.importButton.layer?.borderColor = NSColor("#8cd0ff").cgColor
        self.importButton.layer?.borderWidth = 1.5
        self.importButton.frame = CGRect(x: 721 + 20, y: 316 + 20, width: 40, height: 40)
        self.importButton.isEnabled = false
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = -2*Double.pi
        rotateAnimation.duration = 1.6
        rotateAnimation.fillMode = .forwards
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.repeatCount = .infinity
        self.importButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.importButton.layer?.add(rotateAnimation, forKey: "button.ani")
    }
    
    func resetImportButton(){
        self.importButton.layer?.removeAllAnimations()
        self.importButton.title = "导 入"
        self.importButton.image = NSImage(named: "page_1_start_btn@2x.png")!
        self.importButton.isEnabled = true
        self.importButton.layer?.borderWidth = 0
        self.importButton.layer?.cornerRadius = 0
        self.importButton.frame = CGRect(x: 721, y: 316, width: 138, height: 39)
    }
    
    func showImportMsg(_ msg:String){
        DispatchQueue.main.async {
            self.superVC?.showToast(msg)
            self.resetImportButton()
        }
    }
}


//MARK: 添加(或编辑)节点页面
class AddNodePage: YQPageView,NSComboBoxDelegate {
    var paramsFields:[YQTextField] = []
    var paramsComboxs:[NSComboBox] = []
    var paramsLabels:[NSTextField] = []
    var s_ModiKey: String?
    var i_ModiRow:Int?
    
    lazy var comboxType: NSComboBox = {
        let combox = NSComboBox(labelWithString: "ssr")
        combox.isEditable = false
        combox.isBordered = false
        combox.font = NSFont.systemFont(ofSize: 14)
        combox.textColor = NSColor("#3B79E0")
        combox.drawsBackground = false
        combox.isSelectable = true
        combox.focusRingType = .none //编辑时边框样式
//        let testAttributes = [NSAttributedString.Key.foregroundColor: NSColor("#DADADA")] as [NSAttributedString.Key : Any]
//        let testAttributeString = NSAttributedString(string: "节点类型", attributes:testAttributes)
//        combox.placeholderAttributedString = testAttributeString
        combox.usesDataSource = false
        combox.addItems(withObjectValues: ["ssr","trojan"])
        return combox
    }()
    
    override func initUI(){
        super.initUI()
        self.toolbarTitleLabel.stringValue = "添加节点" //or 编辑节点
        self.toolView.addSubview(self.comboxType)
        self.comboxType.frame = CGRect(x: 155, y: 11, width: 200, height: 20)
        self.comboxType.delegate = self
        
        let width = self.bounds.width
        let height = self.bounds.height
        
        let button = NSButton(title: "保 存", image: NSImage(named: "page_1_start_btn@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.isBordered = false
        button.imagePosition = .imageOverlaps
        button.font = NSFont.systemFont(ofSize: 16)
        button.contentTintColor = NSColor.white
        button.tag = 5000
        toolView.addSubview(button)
        button.frame = CGRect(x: 755, y: 8, width: 138, height: 39)
        
        let resetBtn = NSButton(title: "重置", image: NSImage(named: "page_1_fresh@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        resetBtn.isBordered = false
        resetBtn.imagePosition = .imageLeft
        resetBtn.font = NSFont.systemFont(ofSize: 12)
        resetBtn.contentTintColor = NSColor("#3F3934")
        resetBtn.tag = 5001
        toolView.addSubview(resetBtn)
        resetBtn.frame = CGRect(x: 155+200+30, y: 11, width: 50, height: 15)
        
        let workView = NSView(frame: CGRect(x: 0, y: 0, width: width, height: height-64))
        self.addSubview(workView)
        workView.wantsLayer = true
        workView.layer?.backgroundColor = NSColor.white.cgColor
        
        let titles = ["地址 *","端口 *","加密方法 *","密码 *"]
        let titleY = [344,289,234,179]
        for i in 0..<titles.count{
            let labelAddr = NSTextField(labelWithString: titles[i])
            workView.addSubview(labelAddr)
            labelAddr.font = NSFont.systemFont(ofSize: 14)
            labelAddr.textColor = NSColor("#3F3934")
            labelAddr.isBordered = false
            labelAddr.isEditable = false
            labelAddr.frame = CGRect(x: 50, y: titleY[i], width: 80, height: 16)
            
            let addrMutableString = NSMutableAttributedString(string: titles[i], attributes:
                                                                [NSAttributedString.Key.foregroundColor:NSColor("#3F3934")])
            addrMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: NSRange(location:titles[i].count-1,length:1))
            labelAddr.attributedStringValue = addrMutableString
            
            paramsLabels.append(labelAddr)
        }
        
        let remarks = ["标签","协议插件(protocol)","协议插件参数","混淆插件(obfs)","混淆插件参数"]
        let remarkY = [344,289,234,179]
        for i in 0 ..< remarks.count{
            let labelRemark = NSTextField(labelWithString: remarks[i])
            workView.addSubview(labelRemark)
            labelRemark.font = NSFont.systemFont(ofSize: 14)
            labelRemark.textColor = NSColor("#3F3934")
            switch i {
            case 0:
                labelRemark.frame = CGRect(x: 50, y: 124, width: 50, height: 16)
            default:
                let workWidth = width / 2
                labelRemark.frame = CGRect(x: (Int)(workWidth), y: remarkY[i-1], width: 130, height: 16)
            }
            paramsLabels.append(labelRemark)
            //["地址 *","端口 *","加密方法 *","密码 *","标签","协议插件(protocol)","协议插件参数","混淆插件(obfs)","混淆插件参数"]
        }
//需要输入的框
        let edtField = ["域名或IP","1~65535","请输入密码","给节点起个名字","协议插件参数","混淆插件参数"]
        let fieldY = [344,291,178,123,291,178]
        for i in 0 ..< edtField.count{
            let field = YQTextField()
            workView.addSubview(field)
            field.isEditable = true
            field.isBordered = false
            field.font = NSFont.systemFont(ofSize: 14)
            field.textColor = NSColor("#3F3934")
            field.drawsBackground = false
            field.alignment = .left
            field.isSelectable = true
            field.focusRingType = .none //编辑时边框样式
            field.insertColor = NSColor("#AAAAAA") //设置光标颜色
            if 1 == i{
                field.formatter = OnlyIntegerValueFormatter()
            }
            let testAttributes = [NSAttributedString.Key.foregroundColor: NSColor("#DADADA")] as [NSAttributedString.Key : Any]
            let testAttributeString = NSAttributedString(string: edtField[i], attributes:testAttributes)
            field.placeholderAttributedString = testAttributeString
            field.frame = CGRect(x: 155, y: fieldY[i], width: 280, height: 16)
            if i >= 4{
                let workWidth = width / 2
                field.frame = CGRect(x: Int(workWidth) + 150, y: fieldY[i], width: 280, height: 16)
            }
            paramsFields.append(field)
        }
    
//需要下拉选择的框
        let comboxTitle = ["选择加密方法","选择协议插件","选择混淆插件"]
        let workWidth = width / 2
        for i in 0 ..< comboxTitle.count{
            let combox = NSComboBox()
            workView.addSubview(combox)
            combox.isEditable = false
            combox.isBordered = false
            combox.font = NSFont.systemFont(ofSize: 14)
            combox.textColor = NSColor("#3F3934")
            combox.drawsBackground = false
            combox.isSelectable = true
            combox.focusRingType = .none //编辑时边框样式
            let testAttributes = [NSAttributedString.Key.foregroundColor: NSColor("#DADADA")] as [NSAttributedString.Key : Any]
            let testAttributeString = NSAttributedString(string: comboxTitle[i], attributes:testAttributes)
            combox.placeholderAttributedString = testAttributeString
            combox.usesDataSource = false
            paramsComboxs.append(combox)
            switch i {
            case 0:
                combox.frame = CGRect(x: 155, y: 234, width: 200, height: 20)
                combox.addItems(withObjectValues: [
                    "none","table","rc4","rc4-md5-6","rc4-md5",
                    "aes-128-cfb","aes-192-cfb","aes-256-cfb","aes-128-ctr","aes-192-ctr","aes-256-ctr",
                    "bf-cfb","camellia-128-cfb","camellia-192-cfb","camellia-256-cfb",
                    "cast5-cfb","des-cfb","idea-cfb","rc2-cfb","seed-cfb","salsa20","chacha20","chacha20-ietf",
                    ])
            case 1:
                combox.frame = CGRect(x: Int(workWidth) + 150, y: 344, width: 200, height: 20)
                combox.addItems(withObjectValues: [
                    "origin","verify_deflate",
                    "auth_sha1","auth_sha1_v2","auth_sha1_v4","auth_aes128_sha1",
                    "auth_aes128_md5","auth_chain_a","auth_chain_b",
                    ])
            default:
                combox.frame = CGRect(x: Int(workWidth) + 150, y: 234, width: 200, height: 20)
                combox.addItems(withObjectValues: [
                    "plain",
                    "http_simple",
                    "tls_simple",
                    "http_post",
                    "tls1.2_ticket_auth",
                    ])
            }
//            id objectValueOfSelectedItem = combo_box.objectValueOfSelectedItem;
        }
        
 
        var iTop = 335
        for _ in 0...4{
            let layer_1 = CALayer()
            workView.layer?.addSublayer(layer_1)
            layer_1.frame = CGRect(x: 41, y: iTop, width: 839, height: 1)
            layer_1.backgroundColor = NSColor("#E8E8E8").cgColor
            iTop -= 54
        }
    }
    
    func updateParamUIAtType(typeIndex:Int) {
        if 0 == typeIndex{
//ssr
//         paramsLabels=["地址 *","端口 *","加密方法 *","密码 *","标签","协议插件(protocol)","协议插件参数","混淆插件(obfs)","混淆插件参数"]
            for field in paramsLabels {
                field.isHidden = false
            }
            let title = "加密方法 *"
            let addrMutableString = NSMutableAttributedString(string:title , attributes:
                                                                [NSAttributedString.Key.foregroundColor:NSColor("#3F3934")])
            addrMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: NSRange(location:title.count-1,length:1))
            paramsLabels[2].attributedStringValue = addrMutableString
            
            paramsFields[4].isHidden = false
            paramsFields[5].isHidden = false
            paramsComboxs[0].removeAllItems()
            paramsComboxs[0].addItems(withObjectValues: [
                "none","table","rc4","rc4-md5-6","rc4-md5",
                "aes-128-cfb","aes-192-cfb","aes-256-cfb","aes-128-ctr","aes-192-ctr","aes-256-ctr",
                "bf-cfb","camellia-128-cfb","camellia-192-cfb","camellia-256-cfb",
                "cast5-cfb","des-cfb","idea-cfb","rc2-cfb","seed-cfb","salsa20","chacha20","chacha20-ietf",
                ])
            paramsComboxs[0].stringValue = "aes-256-cfb"
            paramsComboxs[1].isHidden = false
            paramsComboxs[2].isHidden = false
        }else{
//trojan
            let title = "证书校验 *"
            let addrMutableString = NSMutableAttributedString(string:title , attributes:
                                                                [NSAttributedString.Key.foregroundColor:NSColor("#3F3934")])
            addrMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: NSRange(location:title.count-1,length:1))

            paramsLabels[2].attributedStringValue = addrMutableString
            
            for i in 5 ..< paramsLabels.count {
                paramsLabels[i].isHidden = true
            }
            paramsFields[4].isHidden = true
            paramsFields[5].isHidden = true
            paramsComboxs[0].removeAllItems()
            paramsComboxs[0].addItems(withObjectValues: ["否","是"])
            paramsComboxs[0].stringValue = "否"
            paramsComboxs[1].isHidden = true
            paramsComboxs[2].isHidden = true
        }
    }
    
    func comboBoxSelectionDidChange(_ notification: Notification) {
        updateParamUIAtType(typeIndex: self.comboxType.indexOfSelectedItem)
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
        if 5000 == sender.tag{
            //保存节点
            if paramsFields[0].stringValue .isEmpty{
                self.superVC?.showToast("地址不能为空")
                let _ = paramsFields[0].becomeFirstResponder()
                return
            }
            if paramsFields[1].stringValue .isEmpty || 0 == paramsFields[1].intValue{
                self.superVC?.showToast("端口不能为空或为0")
                let _ = paramsFields[1].becomeFirstResponder()
                return
            }
            if self.comboxType.stringValue == "ssr"{
                if paramsFields[2].stringValue .isEmpty{
                    self.superVC?.showToast("密码不能为空")
                    let _ = paramsFields[2].becomeFirstResponder()
                    return
                }
                
                if paramsComboxs[0].stringValue.isEmpty{
                    self.superVC?.showToast("请选择加密方法")
                    return
                }
            }
            
            //        ["域名或IP","1~65535","请输入密码","给节点起个名字","协议插件参数","混淆插件参数"]
            if self.comboxType.stringValue == "ssr"{
                let ssrProfile = SSRProfile()
                ssrProfile.serverHost = paramsFields[0].stringValue
                ssrProfile.serverPort = uint16(paramsFields[1].intValue)
                ssrProfile.password = paramsFields[2].stringValue
                ssrProfile.remark = paramsFields[3].stringValue.isEmpty ? "ssr线路" : paramsFields[3].stringValue
                ssrProfile.ssrProtocolParam = paramsFields[4].stringValue
                ssrProfile.ssrObfsParam = paramsFields[5].stringValue
                ssrProfile.method = paramsComboxs[0].stringValue
                ssrProfile.ssrProtocol = paramsComboxs[1].stringValue
                ssrProfile.ssrObfs = paramsComboxs[2].stringValue
                //单个添加的节点，存入“其.它.节.点”
                //            ssrProfile.ssrGroup = "其.它.节.点" //默认即为"其.它.节.点"
                if !ssrProfile.isValid(){
                    self.superVC?.showToast("参数有误，请检查参数格式！")
                    return
                }
                if s_ModiKey != nil && i_ModiRow != nil {
                    if let nodes = UserDefaults.standard.array(forKey: s_ModiKey!) {
                        if nodes.count > i_ModiRow!{
                            var newNodes = nodes
                            let dict = ssrProfile.toDictionary()
                            let index = i_ModiRow!
                            newNodes.replaceSubrange(index..<(index+1), with: [dict])
                            UserDefaults.standard.set(newNodes, forKey: s_ModiKey!)
                            UserDefaults.standard.synchronize()
                            self.superVC?.showToast("节点已编辑成功！")
                        }
                    }
                }else{
                    ssrProfile.appendNewNode()
                    self.superVC?.showToast("节点已添加成功！")
                }
            }else{
                let trojanProfile = TrojanProfile()
                trojanProfile.serverHost = paramsFields[0].stringValue
                trojanProfile.serverPort = uint16(paramsFields[1].intValue)
                trojanProfile.password = paramsFields[2].stringValue
                trojanProfile.sslVerify = (paramsComboxs[0].stringValue == "是")
                trojanProfile.remark = paramsFields[3].stringValue.isEmpty ? "trojan线路" : paramsFields[3].stringValue
                if !trojanProfile.isValid(){
                    self.superVC?.showToast("参数有误，请检查参数格式！")
                    return
                }
                if s_ModiKey != nil && i_ModiRow != nil {
                    if let nodes = UserDefaults.standard.array(forKey: s_ModiKey!) {
                        if nodes.count > i_ModiRow!{
                            var newNodes = nodes
                            let dict = trojanProfile.toDictionary()
                            let index = i_ModiRow!
                            newNodes.replaceSubrange(index..<(index+1), with: [dict])
                            UserDefaults.standard.set(newNodes, forKey: s_ModiKey!)
                            UserDefaults.standard.synchronize()
                            self.superVC?.showToast("节点已编辑成功！")
                        }
                    }
                }else{
                    trojanProfile.appendNewNode()
                    self.superVC?.showToast("节点已添加成功！")
                }
            }
            
            self.superVC?.changePage(iPage: 1,true)
        }else{
//重置(当页面进行编辑状态下，如果要再次添加节点，则需要重置)
            self.comboxType.selectItem(at: 0)
            self.comboxType.stringValue = "ssr"
            self.updateParamUIAtType(typeIndex: 0)
            self.toolbarTitleLabel.stringValue = "添加节点"
            s_ModiKey = nil
            i_ModiRow = nil
            paramsFields[0].stringValue = ""
            paramsFields[1].stringValue = ""
            paramsFields[2].stringValue = ""
            paramsFields[3].stringValue = ""
            paramsFields[4].stringValue = ""
            paramsFields[5].stringValue = ""
            paramsComboxs[0].stringValue = ""
            paramsComboxs[1].stringValue = ""
            paramsComboxs[2].stringValue = ""
        }
    }
    
    func modiNodeInfo(nodeKey:String,nodeIndex:Int){
        if let nodes = UserDefaults.standard.array(forKey: nodeKey) {
            if nodes.count > nodeIndex{
                let nodeInfo = nodes[nodeIndex] as? [String:AnyObject]
                if let type = nodeInfo!["type"] as? String{
                    self.toolbarTitleLabel.stringValue = "编辑节点"
                    s_ModiKey = nodeKey
                    i_ModiRow = nodeIndex
                    if type == "ssr"{
                        self.comboxType.selectItem(at: 0)
                        self.comboxType.stringValue = "ssr"
                        self.updateParamUIAtType(typeIndex: 0)
                        
                        paramsFields[0].stringValue = nodeInfo!["ServerHost"] as! String
                        paramsFields[1].integerValue = (nodeInfo!["ServerPort"] as! NSNumber).intValue
                        paramsFields[2].stringValue = nodeInfo!["Password"] as! String
                        paramsFields[3].stringValue = nodeInfo!["Remark"] as! String
                        paramsFields[4].stringValue = nodeInfo!["ssrProtocolParam"] as! String
                        paramsFields[5].stringValue = nodeInfo!["ssrObfsParam"] as! String
                        paramsComboxs[0].stringValue = nodeInfo!["Method"] as! String
                        paramsComboxs[1].stringValue = nodeInfo!["ssrProtocol"] as! String
                        paramsComboxs[2].stringValue = nodeInfo!["ssrObfsParam"] as! String
                        
                    }else{//if type == "trojan"
                        self.comboxType.selectItem(at: 1)
                        self.comboxType.stringValue = "trojan"
                        self.updateParamUIAtType(typeIndex: 1)
                        paramsFields[0].stringValue = nodeInfo!["ServerHost"] as! String
                        paramsFields[1].integerValue = (nodeInfo!["ServerPort"] as! NSNumber).intValue
                        paramsFields[2].stringValue = nodeInfo!["Password"] as! String
                        paramsFields[3].stringValue = nodeInfo!["Remark"] as! String
                        paramsComboxs[0].stringValue = nodeInfo!["SSLVerify"] as! Bool ? "是" : "否"
                        
                    }
                }
            }
        }
    }
    
}

//MARK: 会员中心页面
class UserAccountPage: YQPageView {
    lazy var superUserHeader: NSImageView = {
        let imgview = CanTapImageView(image: NSImage(named: "page_4_v_free_over@2x.png")!)
        return imgview
    }()
    lazy var accountLabel: NSTextField = {
        let label = NSTextField(labelWithString: "ID：----")
        label.isEditable = false
        label.isBordered = false
        label.font = NSFont.systemFont(ofSize: 12)
        label.textColor = NSColor("#666666")
        label.alignment = .center
        return label
    }()
    lazy var userLabel: NSTextField = {
        let label = NSTextField(labelWithString: "---@---")
        label.isEditable = false
        label.isBordered = false
        label.font = NSFont.systemFont(ofSize: 12)
        label.textColor = NSColor("#666666")
        label.alignment = .left
        return label
    }()
    
    lazy var exprietimeBtn: NSButton = {
        let expireBtn = NSButton(title: "SVIP：----天", image: NSImage(named: "page_4_expiretime@2x.png")!, target: nil, action: nil)
        expireBtn.isBordered = false
        expireBtn.imagePosition = .imageLeft
        expireBtn.font = NSFont.systemFont(ofSize: 15)
        expireBtn.contentTintColor = NSColor("#303030")
        return expireBtn
    }()
    lazy var expiretimeLabel: NSTextField = {
        let expireLabel = NSTextField(labelWithString: "到期时间：xxxx-xx-xx")
        expireLabel.isBordered = false
        expireLabel.isEditable = false
        expireLabel.alignment = .center
        expireLabel.font = NSFont.systemFont(ofSize: 12)
        expireLabel.textColor = NSColor("#666666")
        return expireLabel
    }()
    
    lazy var mergeBtn: NSButton = {
        let button = NSButton(title: "剩余流量：---.-- GB", image: NSImage(named: "page_4_merge@2x.png")!, target: nil, action: nil)
        button.isBordered = false
        button.imagePosition = .imageLeft
        button.font = NSFont.systemFont(ofSize: 15)
        button.contentTintColor = NSColor("#303030")
        return button
    }()
    
    lazy var autolaunchButton: NSButton = {
        let btn = NSButton(checkboxWithTitle: "开机启动", target: nil, action: nil)
        btn.state = .on
        btn.font = NSFont.systemFont(ofSize: 12)
        btn.contentTintColor = NSColor("#666666") //设置的字体颜色实际无效(为checkBox时颜色是自动的),但不设置这一项又不行，默认是白色的，在白View上看不见
        btn.isBordered = false
        return btn
    }()
    lazy var autologinButton: NSButton = {
        let btn = NSButton(checkboxWithTitle: "自动登录", target: nil, action: nil)
        btn.state = .off
        btn.font = NSFont.systemFont(ofSize: 12)
        btn.contentTintColor = NSColor("#666666")
        btn.isBordered = false
        return btn
    }()
    
    override func initUI(){
        super.initUI()
        self.toolbarTitleLabel.stringValue = "基本信息"
        
        let threeView_1 = NSView(frame: CGRect(x: 11, y: 231, width: 375, height: 157))
        self.addSubview(threeView_1)
        threeView_1.wantsLayer = true
        threeView_1.layer?.backgroundColor = NSColor.white.cgColor
        threeView_1.layer?.cornerRadius = 3
        drawView_1(parentView: threeView_1)
        
        let threeView_2 = NSView(frame: CGRect(x: 389, y: 231, width: 259, height: 157))
        self.addSubview(threeView_2)
        threeView_2.wantsLayer = true
        threeView_2.layer?.backgroundColor = NSColor.white.cgColor
        threeView_2.layer?.cornerRadius = 3
        drawView_2(parentView: threeView_2)
        
        let threeView_3 = NSView(frame: CGRect(x: 651, y: 231, width: 259, height: 157))
        self.addSubview(threeView_3)
        threeView_3.wantsLayer = true
        threeView_3.layer?.backgroundColor = NSColor.white.cgColor
        threeView_3.layer?.cornerRadius = 3
        drawView_3(parentView: threeView_3)
        
        let nodeLayer = CALayer()
        self.layer?.addSublayer(nodeLayer)
        nodeLayer.frame = CGRect(x: 21, y: 194, width: 2, height: 15)
        nodeLayer.backgroundColor = NSColor("#558EE8").cgColor
        
        let textfield = NSTextField(labelWithString: "系统设置")
        textfield.font = NSFont.systemFont(ofSize: 14)
        textfield.textColor = NSColor(hexString: "#3F3934")
        textfield.isEditable = false
        self.addSubview(textfield)
        textfield.frame = CGRect(x: 34, y: 194, width: 200, height: 16)
        
        let bottomView = NSView(frame: CGRect(x: 11, y: 51, width: 899, height: 125))
        self.addSubview(bottomView)
        bottomView.wantsLayer = true
        bottomView.layer?.backgroundColor = NSColor.white.cgColor
        bottomView.layer?.cornerRadius = 3
        
        bottomView.addSubview(self.autolaunchButton)
        self.autolaunchButton.frame = CGRect(x: 64, y: 80, width: 80, height: 15)
        autolaunchButton.state = AppDelegate.getLauncherStatus() ? .on:.off
        
        bottomView.addSubview(self.autologinButton)
        self.autologinButton.frame = CGRect(x: 64, y: 32, width: 80, height: 15)
        
        let saveButton = NSButton(title: "保存设置", image: NSImage(named: "page_4_btn_border@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        bottomView.addSubview(saveButton)
        saveButton.tag = 6001
        saveButton.isBordered = false
        saveButton.imagePosition = .imageOverlaps
        saveButton.font = NSFont.systemFont(ofSize: 12)
        saveButton.contentTintColor = NSColor("#666666") //单纯button可以设置字体颜色
        saveButton.frame = CGRect(x: 759, y: 67, width: 133, height: 44)
        
        let logoutButton = NSButton(title: "退出登录", image: NSImage(named: "page_4_btn_border@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        bottomView.addSubview(logoutButton)
        logoutButton.tag = 6002
        logoutButton.isBordered = false
        logoutButton.imagePosition = .imageOverlaps
        logoutButton.font = NSFont.systemFont(ofSize: 12)
        logoutButton.contentTintColor = NSColor("#666666")
        logoutButton.frame = CGRect(x: 759, y: 19, width: 133, height: 44)
        
        let btnTitles = ["常见问题","关于我们","官方网站：www.totocloud.com"]
        for i in 0...2{
            let btn_1 = NSButton(title: btnTitles[i], target: self, action: #selector(onTapButton(sender:)))
            btn_1.tag = 6003 + i
            self.addSubview(btn_1)
            if 0 == i{
                btn_1.frame = CGRect(x: 35, y: 6, width: 55, height: 15)
            }else if (1 == i){
                btn_1.frame = CGRect(x: 155, y: 6, width: 55, height: 15)
            }else{
                btn_1.frame = CGRect(x: 274, y: 6, width: 180, height: 15)
            }
            btn_1.isBordered = false
            btn_1.font = NSFont.systemFont(ofSize: 12)
            btn_1.contentTintColor = NSColor("#3B79E0")
            let attributes_1 = [NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
            let attributeString_1 = NSAttributedString(string: btnTitles[i], attributes:attributes_1)
            btn_1.attributedTitle = attributeString_1
        }
        freshAccoutInfo()
    }
    
    func drawView_1(parentView:NSView){
        let headimgview = CanTapImageView(image: NSImage(named: "page_4_header@2x.png")!)
        parentView.addSubview(headimgview)
        headimgview.frame = CGRect(x: 67, y: 59, width: 75, height: 74)
        
        parentView.addSubview(self.superUserHeader)
        self.superUserHeader.frame = CGRect(x: 69, y: 56, width: 71, height: 21)
        
        parentView.addSubview(self.accountLabel)
        self.accountLabel.frame = CGRect(x: 49, y: 29, width: 80, height: 20)
        
        parentView.addSubview(self.userLabel)
        self.userLabel.frame = CGRect(x: 173, y: 96, width: 200, height: 20)
        
        let btn = NSButton(title: "续  费", image: NSImage(named: "page_1_start_btn@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        parentView.addSubview(btn)
        btn.tag = 6000
        btn.frame = CGRect(x: 173, y: 48, width: 138, height: 39)
        btn.isBordered = false
        btn.imagePosition = .imageOverlaps
        btn.font = NSFont.systemFont(ofSize: 16)
        btn.contentTintColor = NSColor.white
    }
    
    func drawView_2(parentView:NSView){
        parentView.addSubview(self.exprietimeBtn)
        self.exprietimeBtn.frame = CGRect(x: 66, y: 81, width: 135, height: 18)
        
        parentView.addSubview(self.expiretimeLabel)
        self.expiretimeLabel.frame = CGRect(x: 66, y: 56, width: 135, height: 15)
        
    }
    
    func drawView_3(parentView:NSView){
        parentView.addSubview(self.mergeBtn)
        self.mergeBtn.frame = CGRect(x: 42, y: 81, width: 188, height: 20)
    }
    
    func freshAccoutInfo() {
        let userInfo = UserDefaults.standard.object(forKey: "key.toto.user.info")
        let isLogin = (userInfo != nil)
        if (isLogin){
            let userDict = userInfo as! [String:AnyObject]
            let user_id = userDict["user_id"] as! String
            self.accountLabel.stringValue = String(format: "ID：\(user_id)")
            
            let user_email = userDict["user_email"] as! String
            self.userLabel.stringValue = user_email
            
            let user_class = userDict["user_class"] as! String
            //1free免费用户,2试用vip,3充值vip，4高级vip
            let iClass = Int(user_class)!
            let class_expire = userDict["class_expire"] as! String
            let expireDay = class_expire.prefix(10)
            let day_count = getTodayToADayDiff(aDay: String(expireDay))
            self.exprietimeBtn.title = String(format: "SVIP：\(day_count)天")
            self.expiretimeLabel.stringValue = String(format: "到期时间：\(expireDay)")
            if day_count < 0{
                if  1 == iClass || 2 == iClass{
                    self.superUserHeader.image = NSImage(named: "page_4_v_free_over@2x.png")!
                }else if iClass > 2{
                    self.superUserHeader.image = NSImage(named: "page_4_v_vip_over@2x.png")!
                }
            }else{
                if 1 == iClass{
                    self.superUserHeader.image = NSImage(named: "page_4_v_free@2x.png")!
                }else if 2 == iClass{
                    self.superUserHeader.image =  NSImage(named: "page_4_v_try@2x.png")!
                }else if 3 == iClass{
                    self.superUserHeader.image =  NSImage(named: "page_4_v_vip@2x.png")!
                }else if 4 == iClass{
                    self.superUserHeader.image =  NSImage(named: "page_4_v_svip@2x.png")!
                }
            }
            
            let class_amount = userDict["class_amount"] as! String
            self.mergeBtn.title = String(format: "剩余流量：\(class_amount)")
        }else{
            self.accountLabel.stringValue =  "ID：----"
            self.userLabel.stringValue = "---@---"
            self.superUserHeader.image = NSImage(named: "page_4_v_free_over@2x.png")!
            self.exprietimeBtn.title = "SVIP：----天"
            self.expiretimeLabel.stringValue = "到期时间：xxxx-xx-xx"
            self.mergeBtn.title = "剩余流量：---.-- GB"
        }
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
        NSLog("\(sender.title).\(sender.state)")
        switch sender.tag {
        case 6001:
//保存设置
            AppDelegate.setLauncherStatus(open: autolaunchButton.state == .on ? true : false)
        case 6002:
//退出登录
            UserDefaults.standard.removeObject(forKey: "key.toto.user.info")
            UserDefaults.standard.removeObject(forKey: "Key_Ok_Accout_Token")
            freshAccoutInfo()
//通知主界面更新
            self.superVC?.freshUserInfo()
        default:
//续费、常见问题、关于我们、官网
            openHomeUrl()
            break
        }
    }
}

//MARK: 节点组名输入对话框
class InputAlertView: NSView {
    lazy var inputValue: NSTextField = {
        let field = NSTextField()
        field.isBordered = true
        field.isEditable = true
        field.font = NSFont.systemFont(ofSize: 14)
        field.textColor = NSColor("#303030")
        field.backgroundColor = NSColor("#E8E8E8")
        field.wantsLayer = true
        field.layer?.cornerRadius = 3
        field.layer?.borderWidth = 0.5
        field.layer?.borderColor = NSColor("#C6DBFA").cgColor
        field.alignment = .left
        return field
    }()
    
    typealias ValueBackBlock = (String)->Void
    var valuebackBlock: ValueBackBlock?
    
    var superVC:NodesInfoVC?
    
    convenience init(frame frameRect: NSRect,parentVC:NodesInfoVC?) {
        self.init(frame: frameRect)
        self.superVC = parentVC
        initUI()
    }
    
    func initUI(){
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.white.cgColor
        self.layer?.borderWidth = 1
        self.layer?.borderColor = NSColor("#C6DBFA").cgColor
        self.layer?.cornerRadius = 6
        
        let width = self.bounds.width
        let height = self.bounds.height
        
        let label = NSTextField()
        self.addSubview(label)
        label.isEditable = false
        label.isBordered = false
        label.frame = CGRect(x: 0, y: height-36, width: width, height: 36)
        label.textColor = NSColor("#3B79E0")
        label.font = NSFont.boldSystemFont(ofSize: 12)
        label.backgroundColor = NSColor("#C6DBFA") //NSTextField(labelWithString: alertTitle)如果这种方式创建，背景颜色会无效，cao
        label.stringValue = String(format:"\n  请输入节点组名称：")
        self.addSubview(self.inputValue)
        self.inputValue.frame = CGRect(x: 15, y: height/2 - 10 , width: width - 30, height: 30)
        
        let okBtn = NSButton(title: "确定", target: self, action: #selector(onTapButton(sender:)))
        okBtn.tag = 8001
        okBtn.isBordered = false
        okBtn.wantsLayer = true
        okBtn.layer?.borderColor = NSColor("#C6DBFA").cgColor
        okBtn.layer?.borderWidth = 1.0
        okBtn.layer?.cornerRadius = 3
        okBtn.font = NSFont.systemFont(ofSize: 12)
        okBtn.contentTintColor = NSColor("#666666")
        okBtn.frame = CGRect(x: width - 20 - 50, y: 15, width: 50, height: 26)
        self.addSubview(okBtn)
        
        let cancelBtn = NSButton(title: "取消", target: self, action: #selector(onTapButton(sender:)))
        cancelBtn.tag = 8002
        cancelBtn.isBordered = false
        cancelBtn.wantsLayer = true
        cancelBtn.layer?.borderColor = NSColor("#303030").cgColor
        cancelBtn.layer?.borderWidth = 0.5
        cancelBtn.layer?.cornerRadius = 3
        cancelBtn.font = NSFont.systemFont(ofSize: 12)
        cancelBtn.contentTintColor = NSColor("#666666")
        cancelBtn.frame = CGRect(x: width - 60 - 100, y: 15, width: 50, height: 26)
        self.addSubview(cancelBtn)
    }
    
    func showAlert(backValue:@escaping ValueBackBlock) {
         self.valuebackBlock = backValue
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
        
        if 8001 == sender.tag{
            //读取订阅地址列表，查看是否有相同组名的记录存在
            if self.inputValue.stringValue == "其.它.节.点" || self.inputValue.stringValue == "totoCloud"{
                self.superVC?.showToast("节点组名称已存在，请输入新的组名！")
                return
            }
            
            if let groupList = UserDefaults.standard.array(forKey: SUBSCRIBE_Info_KEY){
                for list in groupList {
                    let node = list as! [String:AnyObject]
                    if let nodeGroup = node["group"] {
                        let sGroup = nodeGroup as! String
                        if sGroup == self.inputValue.stringValue{
                            self.superVC?.showToast("节点组名称已存在，请输入新的组名！")
                            return
                        }
                    }
                }
            }
            
        }else{
            self.inputValue.stringValue = ""
        }
        if self.valuebackBlock != nil{
            self.valuebackBlock!(self.inputValue.stringValue)
        }
    }
}

//MARK: 登录对话框
class LoginAlertView: NSView{
    typealias ValueBackBlock = (String)->Void
    var valuebackBlock: ValueBackBlock?
    
    lazy var accountField: NSTextField = {
        let field = NSTextField()
        field.isBordered = false
        field.isEditable = true
        field.font = NSFont.systemFont(ofSize: 14)
        field.textColor = NSColor("#3F3934")
        field.backgroundColor = NSColor("#E8E8E8")
        let testAttributes = [NSAttributedString.Key.foregroundColor: NSColor(hexString:"#666666",alpha: 0.75)] as [NSAttributedString.Key : Any]
        let testAttributeString = NSAttributedString(string: "请输入TOTO账号", attributes:testAttributes)
        field.placeholderAttributedString = testAttributeString
        return field
    }()
    lazy var passwordField: NSTextField = {
        let field = NSTextField()
        field.isBordered = false
        field.isEditable = true
        field.font = NSFont.systemFont(ofSize: 14)
        field.textColor = NSColor("#3F3934")
        field.backgroundColor = NSColor("#E8E8E8")
        field.placeholderString = "请输入密码"
        let testAttributes = [NSAttributedString.Key.foregroundColor: NSColor(hexString:"#666666",alpha: 0.75)] as [NSAttributedString.Key : Any]
        let testAttributeString = NSAttributedString(string: "请输入密码", attributes:testAttributes)
        field.placeholderAttributedString = testAttributeString
        return field
    }()
    
    lazy var recordCheckButton: NSButton = {
        let btn = NSButton(checkboxWithTitle: "记住密码", target: nil, action: nil)
        btn.state = .off
        btn.font = NSFont.systemFont(ofSize: 12)
        btn.contentTintColor = NSColor("#666666")
        btn.isBordered = false
        return btn
    }()
    lazy var loginCheckButton: NSButton = {
        let button = NSButton(checkboxWithTitle: "自动登录", target: self, action: nil)
        button.font = NSFont.systemFont(ofSize: 12)
        button.contentTintColor = NSColor("#666666")
        button.isBordered = false
        button.state = .on
        return button
    }()
    lazy var startLoginButton: NSButton = {
        let button = NSButton(image: NSImage(named: "LoginAlert_start@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        button.isBordered = false
        button.tag = 10
        return button
    }()
    
    var superVC:NodesInfoVC?
    var iRetry = 0
    
    func showLoginAlert(backValue:@escaping ValueBackBlock) {
         self.valuebackBlock = backValue
    }
    
    convenience init(frame frameRect: NSRect, parentVC: NodesInfoVC) {
        self.init(frame: frameRect)
        self.superVC = parentVC
        initUI()
    }
    
    func initUI(){
        let backView = NSImageView(frame: self.bounds)
        self.addSubview(backView)
        backView.image = NSImage(named: "LoginAlert_bg@2x.png")
        
        let contentView = NSView(frame: CGRect(x: 10, y: 10, width: self.bounds.width - 20, height: self.bounds.height - 16))
        backView.addSubview(contentView)
        contentView.wantsLayer = true
        contentView.layer?.backgroundColor = NSColor.white.cgColor
        
        let verLayer = CALayer()
        contentView.layer?.addSublayer(verLayer)
        verLayer.frame = CGRect(x: 17, y: 361, width: 2, height: 15)
        verLayer.backgroundColor = NSColor("#558EE8").cgColor
        
        let titleLabel = NSTextField(labelWithString: "账号登录")
        contentView.addSubview(titleLabel)
        titleLabel.frame = CGRect(x: 33, y: 362, width: 100, height: 16)
        titleLabel.font = NSFont.systemFont(ofSize: 14)
        titleLabel.textColor = NSColor("#3F3934")
        titleLabel.isBordered = false
        titleLabel.isEditable = false
        
        let jgLayer = CALayer()
        contentView.layer?.addSublayer(jgLayer)
        jgLayer.frame = CGRect(x: 15, y: 348, width: 339, height: 1)
        jgLayer.backgroundColor = NSColor("#E8E8E8").cgColor
        
        contentView.addSubview(self.accountField)
        self.accountField.frame = CGRect(x: 17, y: 275, width: 336, height: 39)
        
        contentView.addSubview(self.passwordField)
        self.passwordField.frame = CGRect(x: 17, y: 219, width: 336, height: 39)
        
        contentView.addSubview(self.recordCheckButton)
        self.recordCheckButton.frame = CGRect(x: 16, y: 188, width: 80, height: 18)
        
        contentView.addSubview(self.loginCheckButton)
        self.loginCheckButton.frame = CGRect(x: 284, y: 188, width: 80, height: 18)
        
        if let  lastAccount = UserDefaults.standard.object(forKey: "Key_Last_Accout_Id_Pw"){
            let accountInfo = lastAccount as! [String:AnyObject]
            let accountID = accountInfo["accountid"] as! String
            let accountPw = accountInfo["accountpw"] as! String
            self.accountField.stringValue = accountID
            self.passwordField.stringValue = accountPw
            self.recordCheckButton.state = .on
        }else{
            self.recordCheckButton.state = .off
        }
//
        contentView.addSubview(self.startLoginButton)
        self.startLoginButton.frame = CGRect(x: 37, y: 104, width: 295, height: 44)
        
        let btn_register = NSButton(title: "免费注册>", target: self, action: #selector(onTapButton(sender:)))
        btn_register.tag = 13
        contentView.addSubview(btn_register)
        btn_register.frame = CGRect(x: 18, y: 72, width: 60, height: 15)
        btn_register.isBordered = false
        btn_register.font = NSFont.systemFont(ofSize: 12)
        btn_register.contentTintColor = NSColor("#3B79E0") //自动变成白色的了，见鬼
        let attributes_1 = [NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        let attributeString_1 = NSAttributedString(string: "免费注册>", attributes:attributes_1)
        btn_register.attributedTitle = attributeString_1
//
        let btn_forget = NSButton(title: "忘记密码？", target: self, action: #selector(onTapButton(sender:)))
        btn_forget.tag = 14
        contentView.addSubview(btn_forget)
        btn_forget.frame = CGRect(x: 284, y: 72, width: 60, height: 15)
        btn_forget.isBordered = false
        btn_forget.font = NSFont.systemFont(ofSize: 12)
        btn_forget.contentTintColor = NSColor("#3B79E0")
        let attributes_2 = [NSAttributedString.Key.underlineStyle:NSUnderlineStyle.single.rawValue] as [NSAttributedString.Key : Any]
        let attributeString_2 = NSAttributedString(string: "忘记密码？", attributes:attributes_2)
        btn_forget.attributedTitle = attributeString_2

        let serverProtocol = NSButton(title: "服务协议", target: self, action: #selector(onTapButton(sender:)))
        contentView.addSubview(serverProtocol)
        serverProtocol.tag = 15
        serverProtocol.isBordered = false
        serverProtocol.font = NSFont.systemFont(ofSize: 12)
        serverProtocol.contentTintColor = NSColor("#A3B2BA")
        serverProtocol.frame = CGRect(x: 17, y: 10, width: 60, height: 15)

        let privateProtocol = NSButton(title: "隐私协议", target: self, action: #selector(onTapButton(sender:)))
        contentView.addSubview(privateProtocol)
        privateProtocol.tag = 16
        privateProtocol.isBordered = false
        privateProtocol.font = NSFont.systemFont(ofSize: 12)
        privateProtocol.contentTintColor = NSColor("#A3B2BA")
        privateProtocol.frame = CGRect(x: 95, y: 10, width: 60, height: 15)
//
        let closeBtn = NSButton(image: NSImage(named: "titlebar_close@2x.png")!, target: self, action: #selector(onTapButton(sender:)))
        closeBtn.frame =  CGRect(x: contentView.bounds.width - 15 - 13, y: contentView.bounds.height - 15 - 13, width: 13, height: 13)
        closeBtn.isBordered = false //无边框时按钮为图片大小，有边框时按钮最好设置为图片的2x
        contentView.addSubview(closeBtn)
        
    }
    
    func showLogining(){
        self.startLoginButton.wantsLayer = true
        self.startLoginButton.layer?.removeAllAnimations()
        self.startLoginButton.isEnabled = false
        self.startLoginButton.image = NSImage(named: "mainwork_startingback@2x.png")!
        self.startLoginButton.frame = CGRect(x: 37 + 125 , y: 104 + 22, width: 44, height: 44)
        self.startLoginButton.layer?.cornerRadius = 22
        self.startLoginButton.layer?.borderColor = NSColor("#8cd0ff").cgColor
        self.startLoginButton.layer?.borderWidth = 0.5
        self.startLoginButton.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0
        rotateAnimation.toValue = -2 * Double.pi
        rotateAnimation.duration = 1.25
        rotateAnimation.fillMode = .forwards
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.repeatCount = .infinity
        self.startLoginButton.layer?.add(rotateAnimation, forKey: "logining.roate")
    }
    
    func resetLogining(){
        self.startLoginButton.layer?.removeAllAnimations()
        self.startLoginButton.layer?.cornerRadius = 0
        self.startLoginButton.layer?.borderWidth = 0
        self.startLoginButton.image = NSImage(named: "LoginAlert_start@2x.png")!
        self.startLoginButton.frame = CGRect(x: 37, y: 104, width: 295, height: 44)
        self.startLoginButton.isEnabled = true
    }
    
    @objc func onTapButton(sender:NSButton){
        NSApp.keyWindow?.makeFirstResponder(nil)
        switch sender.tag {
        case 10://登录
            let accoutID = self.accountField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if accoutID.isEmpty{
                self.superVC?.showToast("账号或密码不能为空")
                return
            }
            let accoutPW = self.passwordField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            if accoutPW.isEmpty{
                self.superVC?.showToast("账号或密码不能为空")
                return
            }
            
            self.updateLoginButtonState(isLoading: true)
            loginWithAccount(account: accoutID, pwd: accoutPW)
            
            //记住密码
            if self.recordCheckButton.state == .on{
                UserDefaults.standard.set(["accountid":accoutID,"accountpw":accoutPW], forKey: "Key_Last_Accout_Id_Pw")
                UserDefaults.standard.synchronize()
            }else{
                UserDefaults.standard.removeObject(forKey: "Key_Last_Accout_Id_Pw")
            }
        
        case 13,14,15,16:
//免费注册
            openHomeUrl("https://www.totocloud.com/auth/register.html")
        case 14:
//忘记密码
            openHomeUrl("https://www.totocloud.com/password/reset.html")
        case 15:
//服务协议
            openHomeUrl("https://www.totocloud.com/license/%E7%94%A8%E6%88%B7%E5%8D%8F%E8%AE%AE.txt")
        case 16:
//隐私协议
            openHomeUrl("https://www.totocloud.com/license/%E9%9A%90%E7%A7%81%E5%8D%8F%E8%AE%AE.txt")
        default:
//关闭
            self.updateLoginButtonState(isLoading: false)
            if (self.valuebackBlock != nil){
                self.valuebackBlock!("Cancel")
            }
        }
    }
    
    func loginWithAccount(account:String, pwd:String){
        // 这个session可以使用刚才创建的。
        let session = URLSession(configuration: .default)
        // 设置URL
        var host = "login.rcooco.com"
        if 1 == iRetry{
            host = "login.xcdoo.com"
        }else if 2 == iRetry {
            host = "login.totofar.com"
        }
        let url = String(format: "https://\(host)/app/emailLogin")
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        // 设置要post的内容，字典格式
        let postData = ["email":account,"passwd":pwd]
        let postString = postData.compactMap({ (key, value) -> String in
            return "\(key)=\(value)"
        }).joined(separator: "&")
        request.httpBody = postString.data(using: .utf8)
        let task = session.dataTask(with: request) {(data, response, error) in
//URLSession.shared.dataTask本身即是异步执行的
            if data == nil || response == nil || error != nil { //url有误时data,response返回nil
                self.retryLogin(account: account, pwd: pwd)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    self.retryLogin(account: account, pwd: pwd)
                    return
                }
                
                if let xDemAuth_1 = httpResponse.allHeaderFields["token"] as? String {
                    if !xDemAuth_1.isEmpty{
//{"token":"","accoutID":"","expireTime":"","merge":"","userDegree":""}
                        UserDefaults.standard.set(xDemAuth_1, forKey: "Key_Ok_Accout_Token")
                        UserDefaults.standard.set(host, forKey: "Key_Ok_Accout_Host") //每次开启App的时候，可以根据此2者请求最新的用户信息
                        UserDefaults.standard.synchronize()
                       
                        self.requestUserData(tokenStr: xDemAuth_1, host: host) //请求用户信息
                        return
                    }
                }
            }
            
            self.retryLogin(account: account, pwd: pwd)
            
        }
        task.resume()
    }
    
    func notiMainUpdateAccount(info:String){
        DispatchQueue.main.async {
            if self.valuebackBlock != nil{
                self.valuebackBlock!(info)
            }
        }
    }
    
    func requestUserData(tokenStr:String,host:String){
        // 这个session可以使用刚才创建的。
        let session = URLSession(configuration: .default)
        // 设置URL
//        let url = "https://www.jiguang520.com/app/userInfo"
        let url = String(format: "https://\(host)/app/userInfo")
        var request = URLRequest(url: URL(string: url)!)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue(tokenStr, forHTTPHeaderField: "token")
        request.httpMethod = "GET"
        let task = session.dataTask(with: request) {(data, response, error) in
//URLSession.shared.dataTask本身即是异步执行的
            do {
                let jsonObj = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                let values = jsonObj as? NSDictionary
                if values != nil{
                    let dict = values!
//                    let code = dict["code"]  as! Int
                    let valueinfo = dict["data"] as? NSDictionary
                    if valueinfo != nil {
                        //valueinfo即为用户信息,保存至本地，以便我的页面使用
                        let user_id = valueinfo!["id"] as? Int
                        let user_email = valueinfo!["email"] as? String
                        let transfer_enable = valueinfo!["transfer_enable"] as? Double //总量
                        let transfer_u = valueinfo!["u"] as? Double
                        let transfer_d = valueinfo!["d"] as? Double // transfer_enable-u-d = 剩余流量
                        let user_class = valueinfo!["class"] as? Int //1free免费用户,2试用vip,3充值vip，4高级vip
                        let class_expire = valueinfo!["class_expire"] as? String //vip过期时间
                        
                        if user_id != nil && user_email != nil && class_expire != nil{
                            var remain_amount = 0.0
                            if transfer_enable != nil{
                                remain_amount = transfer_enable!
                                if transfer_u != nil{
                                    remain_amount -= transfer_u!
                                }
                                if transfer_d != nil{
                                    remain_amount -= transfer_d!
                                }
                            }
                            //转成M或G的字符串
                            var a_m = Double(remain_amount)/1024.0/1024.0 //MB
                            var class_amount = String(format:"%.2f MB",a_m)
                            if a_m > 1024{
                                a_m = a_m / 1024 //GB
                                class_amount = String(format:"%.2f GB",a_m)
                            }
                            
                            UserDefaults.standard.set(["user_id":String(user_id!),"user_email":user_email,"user_class":String(user_class!),"class_expire":class_expire!,"class_amount":class_amount], forKey: "key.toto.user.info")
                            UserDefaults.standard.synchronize()
                            
                            self.notiMainUpdateAccount(info: "Account")
                        }
                        
                        let subLink = valueinfo!["subLink"] as? NSDictionary
                        if subLink != nil {
                            if let ssrInfo = subLink!["ssr"] { //默认免费使用节点
                                let ssrUri = ssrInfo as! String
                                self.importDefaultSSR(uri: ssrUri)
                            }
                            return
                        }
                    }
                }
                self.updateLoginButtonState(isLoading: false)
                self.notiMainUpdateAccount(info: "Cancel")
            } catch {
                self.updateLoginButtonState(isLoading: false)
                self.notiMainUpdateAccount(info: "Cancel")
            }
        }
        task.resume()
    }
    
    func retryLogin(account:String, pwd:String){
        self.iRetry += 1
        if self.iRetry >= 3 {
            DispatchQueue.main.async {
                self.superVC?.showToast("登录失败，请稍候重试")
                self.updateLoginButtonState(isLoading: false)
                self.iRetry = 0
            }
        }else{
            self.loginWithAccount(account: account, pwd: pwd)
        }
    }
    
    func importDefaultSSR(uri:String){
        DispatchQueue.global().async {
            let url = URL(string: uri)!
            guard let urlContent = try? String(contentsOf: url) else {
                self.updateLoginButtonState(isLoading: false)
                self.notiMainUpdateAccount(info: "Cancel")
                return
            }
            
            let decodeContent = urlContent.base64DecodeStr()
            if (decodeContent != nil){
                importNodeList(decodeContent!, Url: uri, GroupTitle: "totoCloud",IsModi: false) { success, errMsg in
                    self.updateLoginButtonState(isLoading: false)
                    self.notiMainUpdateAccount(info: success ? "Route" : "Cancel")
                }
            }
            else{//非base64的URL内容，则当成yaml文件内容处理
    //              string转Data，然后进入yaml解析
                let yamlData=urlContent.data(using: .utf8)!
                let importer_obj : Importer_oc = Importer_oc()
                let proxyArr: [Any] = importer_obj.loadYamlData(yamlData)
                guard proxyArr.count>0 else{
                    return
                }
                importYamlDict(proxyArr as! [[String: AnyObject]],Url: uri,GroupTitle: "totoCloud",IsModi: false) { success, errMsg in
                    self.updateLoginButtonState(isLoading: false)
                    self.notiMainUpdateAccount(info: success ? "Route" : "Cancel")
                }
            }
        }
        
        
    }
    
    func updateLoginButtonState(isLoading:Bool){
        DispatchQueue.main.async {
            if isLoading{
                self.showLogining()
            }else{
                self.resetLogining()
            }
        }
       
    }
}

class SocketTcping: NSObject, GCDAsyncSocketDelegate {
    var socket:GCDAsyncSocket?
    var startTime = Date()
    var speed = TimeInterval.infinity
    var domain = ""
    var host = ""
    var port:UInt16 = 80
    
    func connectSocket(domain: String, port: UInt16) {
        self.domain = domain
        self.port = port
        self.socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global())
        if !self.socket!.isConnected {
            do {
                startTime = Date()
                try self.socket?.connect(toHost: domain, onPort: port, withTimeout: NodeTcping.timeout)
            } catch let error {
                print(error)
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        self.host = host
        self.speed = Date().timeIntervalSince(startTime) * 1000
        sock.disconnect()
    }
}

class NodeTcping {
    static let timeout:TimeInterval = 1.8
    var pings = [SocketTcping]()
    
    func ping(_ nodeDict:[[String:AnyObject]], finish: @escaping ()->()) {
        for i in 0 ..< nodeDict.count {
            let item = nodeDict[i]
            let host  = item["ServerHost"] as! String
            let port = (item["ServerPort"] as! NSNumber).uint16Value
            
            let t = SocketTcping()
            pings.append(t)
            t.connectSocket(domain: host, port: port) //开始检测
        }
//随后(超时)检测每个item.speed
        let walltime = DispatchWallTime.now() + NodeTcping.timeout + 0.2 //超时1.8s，则返回检测结果
        DispatchQueue.global().asyncAfter(wallDeadline: walltime){ [weak self] in
            guard let weakself = self else {
                finish()
                return
            }
            
            for i in 0 ..< weakself.pings.count{
                let item = weakself.pings[i]
                item.socket?.disconnect() //超时还未返回的，则取消连接
                let speed = item.speed
                var perDict = nodeDict[i]
                let host  = perDict["ServerHost"] as! String
                let port = (perDict["ServerPort"] as! NSNumber).uint16Value
                let speedKey = String("latency.\(host).\(port)")
                if speed == TimeInterval.infinity {
                    perDict["latency"] = "0" as AnyObject?
                }else{
                    let value = String(format: "%.0f", speed)
                    perDict["latency"] = value as AnyObject?
                    UserDefaults.standard.set(value, forKey: speedKey)
                }
            }
            UserDefaults.standard.synchronize()
            finish()
        }
        
        
    }
}
