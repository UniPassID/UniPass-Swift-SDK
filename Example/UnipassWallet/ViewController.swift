//
//  ViewController.swift
//  UnipassWallet
//
//

import UIKit
import UniPassSDK
class ViewController: UIViewController {
    
    var userIdLabel: UILabel?
    var googleLoginBtn: UIButton?
    var emailLoginBtn: UIButton?
    var unipassLoginBtn: UIButton?
    var loginStatusLabel: UILabel?

    var logoutBtn: UIButton?
    var signMessageBtn: UIButton?
    var signTextField: UITextField?
    var signatureLabel: UILabel?

    var transctionBtn: UIButton?
    var transactionHashLabel: UILabel?

    var unipassSdk: UniPassSDK?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white

        buildUi()

        let setting = UniPassSDKAppSetting()
        setting.appName = "testWallect"
        setting.chain = .polygon
        setting.theme = .dark
        
        let option = UniPassSDKOption()
        option.environment = .Testnet
        option.appSetting = setting
        option.context = self
        
        unipassSdk = UniPassSDK(sdkOption: option)
        refreshUI()
    }

    func buildUi() {
        userIdLabel = UILabel(frame: CGRect(x: 50, y: 80, width: view.width() - 200, height: 60))
        userIdLabel?.font = UIFont.systemFont(ofSize: 14)
        userIdLabel?.backgroundColor = UIColor.lightGray
        userIdLabel?.text = "empty"
        userIdLabel?.numberOfLines = 3
        userIdLabel?.textAlignment = .center
        userIdLabel?.textColor = UIColor.black
        view.addSubview(userIdLabel!)
        
        logoutBtn = UIButton(frame: CGRect(x: view.width() - 100 - 40, y: 80, width: 80, height: 50))
        logoutBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        view.addSubview(logoutBtn!)
        logoutBtn?.addTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
        logoutBtn?.backgroundColor = UIColor.blue
        logoutBtn?.setTitle("Logout", for: .normal)

        googleLoginBtn = UIButton(frame: CGRect(x: 50, y: userIdLabel!.bottom + 20, width: 80, height: 50))
        googleLoginBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        googleLoginBtn?.addTarget(self, action: #selector(googleLoginBtnClicked), for: .touchUpInside)
        googleLoginBtn?.backgroundColor = UIColor.blue
        googleLoginBtn?.setTitle("Google Login", for: .normal)
        view.addSubview(googleLoginBtn!)

        emailLoginBtn = UIButton(frame: CGRect(x: view.width()/2 - 40 , y: userIdLabel!.bottom + 20, width: 80, height: 50))
        emailLoginBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        emailLoginBtn?.addTarget(self, action: #selector(emailLoginBtnClicked), for: .touchUpInside)
        emailLoginBtn?.backgroundColor = UIColor.blue
        emailLoginBtn?.setTitle("Email Login", for: .normal)
        view.addSubview(emailLoginBtn!)
        
        unipassLoginBtn = UIButton(frame: CGRect(x: view.width() - 100 - 40, y: userIdLabel!.bottom + 20, width: 80, height: 50))
        unipassLoginBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        unipassLoginBtn?.addTarget(self, action: #selector(unipassLoginBtnClicked), for: .touchUpInside)
        unipassLoginBtn?.backgroundColor = UIColor.blue
        unipassLoginBtn?.setTitle("UniPass Login", for: .normal)
        view.addSubview(unipassLoginBtn!)

        signTextField = UITextField(frame: CGRect(x: 50, y: googleLoginBtn!.bottom + 50, width: view.width() - 100, height: 80))
        signTextField?.text = "hello world"
        view.addSubview(signTextField!)
        signTextField?.backgroundColor = UIColor.darkGray

        signMessageBtn = UIButton(frame: CGRect(x: view.width() / 2 - 70, y: signTextField!.bottom + 20, width: 140, height: 50))
        signMessageBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        view.addSubview(signMessageBtn!)
        signMessageBtn?.addTarget(self, action: #selector(signMessageBtnClicked), for: .touchUpInside)
        signMessageBtn?.backgroundColor = UIColor.blue
        signMessageBtn?.setTitle("sign message", for: .normal)

        signatureLabel = UILabel(frame: CGRect(x: 50, y: signMessageBtn!.bottom + 20, width: view.width() - 100, height: 100))
        signatureLabel?.font = UIFont.systemFont(ofSize: 12)
        signatureLabel?.backgroundColor = UIColor.lightGray
        signatureLabel?.text = "signature"
        signatureLabel?.numberOfLines = 10
        signatureLabel?.textAlignment = .center
        signatureLabel?.textColor = UIColor.black
        view.addSubview(signatureLabel!)

        transctionBtn = UIButton(frame: CGRect(x: view.width() / 2 - 70, y: signatureLabel!.bottom + 70, width: 140, height: 50))
        transctionBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        transctionBtn?.addTarget(self, action: #selector(transctionBtnBtnClicked), for: .touchUpInside)
        transctionBtn?.backgroundColor = UIColor.blue
        transctionBtn?.setTitle("send transaction", for: .normal)
        view.addSubview(transctionBtn!)

        transactionHashLabel = UILabel(frame: CGRect(x: 50, y: transctionBtn!.bottom + 20, width: view.width() - 100, height: 60))
        transactionHashLabel?.font = UIFont.systemFont(ofSize: 14)
        transactionHashLabel?.backgroundColor = UIColor.lightGray
        transactionHashLabel?.text = "transaction hash"
        transactionHashLabel?.numberOfLines = 10
        transactionHashLabel?.textAlignment = .center
        transactionHashLabel?.textColor = UIColor.black
        view.addSubview(transactionHashLabel!)
    }

    func refreshUI() {
        if let userInfo = unipassSdk?.getUserInfo() {
            userIdLabel?.text = userInfo.address
            print(userInfo)
        } else {
            userIdLabel?.text = "empty"
            transactionHashLabel?.text = "transaction hash"
            signatureLabel?.text = "signature"
        }
    }
    @objc func googleLoginBtnClicked() {
        loginBtnClicked(loginType: ConnectType.google)
    }
    
    @objc func emailLoginBtnClicked() {
        loginBtnClicked(loginType: ConnectType.email)
    }

    @objc func unipassLoginBtnClicked() {
        loginBtnClicked(loginType: ConnectType.both)
    }
    
    func loginBtnClicked(loginType: ConnectType) {
        unipassSdk?.logIn(loginType: loginType, loginSuccessBlock: { userinfo in
            print("unipassSdk: Login successfully ✅")
            self.userIdLabel?.text = userinfo.address
        }, loginErrorBlock: { error in
            print("unipassSdk: Login failed ❎", error)
        })
    }

    @objc func logoutBtnClicked() {
        unipassSdk?.logOut(logOutSuccessBlock: {
            print("unipassSdk: Logout successfully ✅")
            self.refreshUI()
        }, logoutErrorBlock: { error in
            print("unipassSdk: Logout failed ❎", error)
        }, deep: false)
    }

    @objc func signMessageBtnClicked() {
        if let userInfo = unipassSdk?.getUserInfo() {
            let signInput = UniPassSignInput()
            signInput.from = userInfo.address
            signInput.type = UniPassSignType.PersonalSign
            signInput.msg = signTextField?.text ?? "Test Sign Message"
                
            unipassSdk?.signMessage(signInput, SuccessBlock: { signature in
                print("unipassSdk: sign message successfully ✅", signature)
                self.signatureLabel?.text = signature
            }, ErrorBlock: { error in
                print("unipassSdk: sign message failed ❎", error)
            })
        } else {
            print("unipassSdk: user not login ❎")
        }
    }

    @objc func transctionBtnBtnClicked() {
        if let userInfo = unipassSdk?.getUserInfo() {
            let tx = UniPassTransaction()
            tx.from = userInfo.address
            tx.to = "0x635b8f68aa1407712a3158782A7E21833bB392CC"
            tx.value = "0x38d7ea4c68000"

                unipassSdk?.sendTransaction(tx, SuccessBlock: { transactionHash in
                    print("unipassSdk: send transaction success ✅", transactionHash)
                    self.transactionHashLabel?.text = transactionHash
                }, ErrorBlock: { error in
                    print("unipassSdk: send transaction failed ❎", error)
                })
        } else {
            print("unipassSdk: user not login ❎")
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        signTextField?.endEditing(true)
    }
}
