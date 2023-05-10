//
//  MainViewController.swift
//  TotoCloud
//
//  Created by 黄龙 on 2023/4/11.
//

import Cocoa

class MainViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.green.cgColor
        
        initUI()
    }
    
    override func loadView() {
        view = NSView(frame: CGRect(x: 0, y: 0, width: 920, height: 580))
        //only-one: view的大小才是真正的初始后的window大小
    }
    
    func initUI(){
        let button = NSButton(title: "拷贝", target: self, action: #selector(tapButton))
        view.addSubview(button)
        button.frame = CGRect(x: 100, y: 100, width: 100, height: 100)
        button.wantsLayer = true
        button.layer?.borderWidth = 1
        button.layer?.borderColor = NSColor.red.cgColor
        
    }
    
    @objc func tapButton(){
//        NSString *helperPath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], @"install_helper.sh"];
        let bundle = Bundle.main
        let installerPath = bundle.path(forResource: "install_test.sh", ofType: nil)
//        NSString *script = [NSString stringWithFormat:@"do shell script \"bash %@\" with administrator privileges", helperPath];
        let script = String(format: "bash %@", installerPath!)
        let (isSuccess,executeResult) = runCommand(script, needAuthorize: true)
        NSLog("\(isSuccess),\(executeResult)")
        
    }
    
    /// 执行脚本命令
    ///
    /// - Parameters:
    ///   - command: 命令行内容
    ///   - needAuthorize: 执行脚本时,是否需要 sudo 授权
    /// - Returns: 执行结果
    private func runCommand(_ command: String, needAuthorize: Bool) -> (isSuccess: Bool, executeResult: String?) {
        let scriptWithAuthorization = """
        do shell script "\(command)" with administrator privileges
        """
        //with administrator privileges即为提权，一般会触发授权对话框，在另一个老工程里可以触发，但在新工程里始终无法触发，见鬼了！！！
        let scriptWithoutAuthorization = """
        do shell script "\(command)"
        """
        
        let script = needAuthorize ? scriptWithAuthorization : scriptWithoutAuthorization
        let appleScript = NSAppleScript(source: script)
        
        var error: NSDictionary? = nil
        let result = appleScript!.executeAndReturnError(&error)
        if let error = error {
            self.showAlert(error.description)
            print("执行 \n\(command)\n命令出错:")
            print(error)
            return (false, nil)
        }
        self.showAlert("Success!")
        return (true, result.stringValue)
    }
    
    func showAlert(_ title:String){
        let alert = NSAlert.init()
        alert.messageText = title
        alert.informativeText = title
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        alert.runModal()
    }
    
}
