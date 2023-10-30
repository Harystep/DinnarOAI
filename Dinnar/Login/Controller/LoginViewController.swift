//
//  ViewController.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/20.
//

import UIKit

class LoginViewController: BaseViewController {
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        // Do any additional setup after loading the view.
    }
    private func setupSubviews() {
        self.navigationController?.navigationBar.isHidden = true
        userNameTextField.superview?.setCornerRadius(cornerRadius: 20, borderWidth: 1, borderColor: .black)
        passwordTextField.superview?.setCornerRadius(cornerRadius: 20, borderWidth: 1, borderColor: .black)
    }
    @IBAction private func loginBtClick(){
        if userNameTextField.isEmpty(){
            showToast("请填写用户名称")
            return
        }
        if passwordTextField.isEmpty(){
            showToast("请填写密码")
            return
        }
       let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.removeFromSuperViewOnHide = true
        NetworkService.requestWithNoBusinessFilter(target: API.login(userName: userNameTextField.text!, password: passwordTextField.text!)) { (dict, response) in
            hud.hide(animated: true)
            print(dict)
            guard let dic = dict as? [String:Any],let msg = dic["msg"] as? String else {
                self.showToast("登录失败")
                return
            }
            guard let token = dic["data"] as? String else {
                self.showToast(msg)
                return
            }
            DataTool.saveToken(token: token, userName: self.userNameTextField.text)
            self.loginSuccess()
            
        } failure: { (error) in
            hud.hide(animated: true)
            self.showToast("登录失败")
        }
        
    }
    func loginSuccess(){
        let navC = UINavigationController.init(rootViewController:SelectVC.initWithNib())
        navC.navigationBar.isHidden = true
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.window?.rootViewController = navC
        appdelegate.window?.makeKeyAndVisible()
    }

    deinit {
        print("释放了")
    }
}
