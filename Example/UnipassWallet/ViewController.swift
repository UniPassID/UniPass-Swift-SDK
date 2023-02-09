//
//  ViewController.swift
//  UnipassWallet
//
//

import UIKit
import UniPassSDK
class ViewController: UIViewController {
    var loginView: UIView?
    var userInfoView: UIScrollView?

    var addressReturnSwitch: UISwitch?
    var emailReturnSwitch: UISwitch?

    var addressValueText: UITextView?
    var emailValueText: UITextView?
    var siweMsgValueText: UITextView?
    var siweSigValueText: UITextView?

    var googleLoginBtn: UIButton?
    var emailLoginBtn: UIButton?
    var unipassLoginBtn: UIButton?
    var loginAuth: UIButton?
    var loginAuthEmail: UIButton?

    var loginStatusLabel: UILabel?

    var logoutBtn: UIButton?
    var signMessageBtn: UIButton?
    var signTextField: UITextField?
    var signatureValueText: UITextView?

    var transctionBtn: UIButton?
    var transactionHashLabel: UITextView?

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

        NotificationCenter.default.addObserver(self, selector: #selector(receiveUrlScheme(notifition:)), name: NSNotification.Name("receiveUrlScheme"), object: nil)
    }

    @objc func receiveUrlScheme(notifition: Notification) {
        let receiveUrl = notifition.object as? NSURL
        print("receive url", receiveUrl)

//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
        loginBtnClicked(loginOption: nil)
//        }
    }

    func buildLoginUi() {
        let addressReturnLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 160, height: 50))
        addressReturnLabel.font = UIFont.systemFont(ofSize: 14)
        addressReturnLabel.textAlignment = .center
        addressReturnLabel.textColor = UIColor.black
        addressReturnLabel.text = "Return Address:"
        loginView?.addSubview(addressReturnLabel)

        addressReturnSwitch = UISwitch(frame: CGRect(x: view.width() - 120, y: 10, width: 100, height: 50))
        addressReturnSwitch?.isOn = true
        addressReturnSwitch?.isEnabled = false
        loginView?.addSubview(addressReturnSwitch!)

        let emailReturnLabel = UILabel(frame: CGRect(x: 20, y: addressReturnLabel.bottom + 10, width: 160, height: 50))
        emailReturnLabel.font = UIFont.systemFont(ofSize: 14)
        emailReturnLabel.textAlignment = .center
        emailReturnLabel.textColor = UIColor.black
        emailReturnLabel.text = "Return Email:"
        loginView?.addSubview(emailReturnLabel)

        emailReturnSwitch = UISwitch(frame: CGRect(x: view.width() - 120, y: addressReturnLabel.bottom + 10, width: 100, height: 50))
        emailReturnSwitch?.isOn = false
        loginView?.addSubview(emailReturnSwitch!)

        let spanLabel = UILabel(frame: CGRect(x: view.width() / 2 - 120, y: emailReturnLabel.bottom + 30, width: 240, height: 50))
        spanLabel.font = UIFont.systemFont(ofSize: 10)
        spanLabel.text = "Onboarding users through Google and Email"
        spanLabel.numberOfLines = 3
        spanLabel.textAlignment = .center
        spanLabel.textColor = UIColor.black
        loginView?.addSubview(spanLabel)

        googleLoginBtn = UIButton(frame: CGRect(x: view.width() / 2 - 120, y: spanLabel.bottom + 10, width: 240, height: 50))
        googleLoginBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        googleLoginBtn?.addTarget(self, action: #selector(googleLoginBtnClicked), for: .touchUpInside)
        googleLoginBtn?.backgroundColor = UIColor.blue
        googleLoginBtn?.setTitle("Connect with Google", for: .normal)
        loginView!.addSubview(googleLoginBtn!)

        emailLoginBtn = UIButton(frame: CGRect(x: view.width() / 2 - 120, y: googleLoginBtn!.bottom + 20, width: 240, height: 50))
        emailLoginBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        emailLoginBtn?.addTarget(self, action: #selector(emailLoginBtnClicked), for: .touchUpInside)
        emailLoginBtn?.backgroundColor = UIColor.blue
        emailLoginBtn?.setTitle("Connect with Email", for: .normal)
        loginView!.addSubview(emailLoginBtn!)

        let spanLabel2 = UILabel(frame: CGRect(x: view.width() / 2 - 120, y: emailLoginBtn!.bottom + 50, width: 240, height: 50))
        spanLabel2.font = UIFont.systemFont(ofSize: 10)
        spanLabel2.text = "Connect UniPass through one button"
        spanLabel2.numberOfLines = 3
        spanLabel2.textAlignment = .center
        spanLabel2.textColor = UIColor.black
        loginView?.addSubview(spanLabel2)

        unipassLoginBtn = UIButton(frame: CGRect(x: view.width() / 2 - 120, y: spanLabel2.bottom + 10, width: 240, height: 50))
        unipassLoginBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        unipassLoginBtn?.addTarget(self, action: #selector(unipassLoginBtnClicked), for: .touchUpInside)
        unipassLoginBtn?.backgroundColor = UIColor.blue
        unipassLoginBtn?.setTitle("Connect with UniPass", for: .normal)
        loginView!.addSubview(unipassLoginBtn!)

        loginAuth = UIButton(frame: CGRect(x: view.width() / 2 - 120, y: unipassLoginBtn!.bottom + 20, width: 240, height: 50))
        loginAuth?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        loginAuth?.addTarget(self, action: #selector(loginAuthClicked), for: .touchUpInside)
        loginAuth?.backgroundColor = UIColor.blue
        loginAuth?.setTitle("Connect & Auth with UniPass", for: .normal)
        loginView!.addSubview(loginAuth!)
    }

    func buildUserInfoUi() {
        let addressLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        addressLabel.font = UIFont.systemFont(ofSize: 12)
        addressLabel.backgroundColor = UIColor.white
        addressLabel.text = "Your address: "
        addressLabel.numberOfLines = 3
        addressLabel.textAlignment = .left
        addressLabel.textColor = UIColor.black
        userInfoView!.addSubview(addressLabel)

        addressValueText = UITextView(frame: CGRect(x: 10, y: addressLabel.bottom, width: view.width() - 20, height: 30))
        addressValueText?.font = UIFont.systemFont(ofSize: 12)
        addressValueText?.backgroundColor = UIColor.lightGray
        addressValueText?.text = "empty"
        addressValueText?.isEditable = false
        addressValueText?.textAlignment = .center
        addressValueText?.textColor = UIColor.black
        userInfoView!.addSubview(addressValueText!)

        let emailLabel = UILabel(frame: CGRect(x: 0, y: addressValueText!.bottom, width: 200, height: 30))
        emailLabel.font = UIFont.systemFont(ofSize: 12)
        emailLabel.backgroundColor = UIColor.white
        emailLabel.text = "Your email: "
        emailLabel.numberOfLines = 3
        emailLabel.textAlignment = .left
        emailLabel.textColor = UIColor.black
        userInfoView!.addSubview(emailLabel)

        emailValueText = UITextView(frame: CGRect(x: 10, y: emailLabel.bottom, width: view.width() - 20, height: 30))
        emailValueText?.font = UIFont.systemFont(ofSize: 12)
        emailValueText?.backgroundColor = UIColor.lightGray
        emailValueText?.text = ""
        emailValueText?.isEditable = false
        emailValueText?.textAlignment = .center
        emailValueText?.textColor = UIColor.black
        userInfoView!.addSubview(emailValueText!)

        let siweMsgLabel = UILabel(frame: CGRect(x: 0, y: emailValueText!.bottom, width: 200, height: 30))
        siweMsgLabel.font = UIFont.systemFont(ofSize: 12)
        siweMsgLabel.backgroundColor = UIColor.white
        siweMsgLabel.text = "Sign With Ethereum message: "
        siweMsgLabel.numberOfLines = 3
        siweMsgLabel.textAlignment = .left
        siweMsgLabel.textColor = UIColor.black
        userInfoView!.addSubview(siweMsgLabel)

        siweMsgValueText = UITextView(frame: CGRect(x: 10, y: siweMsgLabel.bottom, width: view.width() - 20, height: 60))
        siweMsgValueText?.font = UIFont.systemFont(ofSize: 12)
        siweMsgValueText?.backgroundColor = UIColor.lightGray
        siweMsgValueText?.text = ""
        siweMsgValueText?.isEditable = false
        siweMsgValueText?.textAlignment = .left
        siweMsgValueText?.textColor = UIColor.black
        userInfoView!.addSubview(siweMsgValueText!)

        let siweSigLabel = UILabel(frame: CGRect(x: 0, y: siweMsgValueText!.bottom, width: 200, height: 30))
        siweSigLabel.font = UIFont.systemFont(ofSize: 12)
        siweSigLabel.backgroundColor = UIColor.white
        siweSigLabel.text = "Sign With Ethereum Signature: "
        siweSigLabel.numberOfLines = 3
        siweSigLabel.textAlignment = .left
        siweSigLabel.textColor = UIColor.black
        userInfoView!.addSubview(siweSigLabel)

        siweSigValueText = UITextView(frame: CGRect(x: 10, y: siweSigLabel.bottom, width: view.width() - 20, height: 60))
        siweSigValueText?.font = UIFont.systemFont(ofSize: 12)
        siweSigValueText?.backgroundColor = UIColor.lightGray
        siweSigValueText?.text = ""
        siweSigValueText?.isEditable = false
        siweSigValueText?.textAlignment = .left
        siweSigValueText?.textColor = UIColor.black
        userInfoView!.addSubview(siweSigValueText!)

        logoutBtn = UIButton(frame: CGRect(x: view.width() / 2 - 80, y: siweSigValueText!.bottom + 10, width: 160, height: 30))
        logoutBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        logoutBtn?.addTarget(self, action: #selector(logoutBtnClicked), for: .touchUpInside)
        logoutBtn?.backgroundColor = UIColor.blue
        logoutBtn?.setTitle("Logout", for: .normal)
        userInfoView!.addSubview(logoutBtn!)

        signTextField = UITextField(frame: CGRect(x: 10, y: logoutBtn!.bottom + 30, width: view.width() - 20, height: 45))
        signTextField?.text = "hello world"
        signTextField?.font = UIFont.systemFont(ofSize: 12)
        signTextField?.backgroundColor = UIColor.darkGray
        userInfoView!.addSubview(signTextField!)

        signMessageBtn = UIButton(frame: CGRect(x: view.width() / 2 - 80, y: signTextField!.bottom + 10, width: 160, height: 30))
        signMessageBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        signMessageBtn?.addTarget(self, action: #selector(signMessageBtnClicked), for: .touchUpInside)
        signMessageBtn?.backgroundColor = UIColor.blue
        signMessageBtn?.setTitle("Sign Message", for: .normal)
        userInfoView!.addSubview(signMessageBtn!)

        signatureValueText = UITextView(frame: CGRect(x: 10, y: signMessageBtn!.bottom + 10, width: view.width() - 20, height: 60))
        signatureValueText?.font = UIFont.systemFont(ofSize: 12)
        signatureValueText?.backgroundColor = UIColor.lightGray
        signatureValueText?.text = "signature"
        signatureValueText?.textAlignment = .left
        signatureValueText?.textColor = UIColor.black
        signatureValueText?.isEditable = false
        userInfoView!.addSubview(signatureValueText!)

        transctionBtn = UIButton(frame: CGRect(x: view.width() / 2 - 80, y: signatureValueText!.bottom + 30, width: 160, height: 30))
        transctionBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        transctionBtn?.addTarget(self, action: #selector(transctionBtnBtnClicked), for: .touchUpInside)
        transctionBtn?.backgroundColor = UIColor.blue
        transctionBtn?.setTitle("send transaction", for: .normal)
        userInfoView!.addSubview(transctionBtn!)

        transactionHashLabel = UITextView(frame: CGRect(x: 10, y: transctionBtn!.bottom + 10, width: view.width() - 20, height: 60))
        transactionHashLabel?.font = UIFont.systemFont(ofSize: 12)
        transactionHashLabel?.backgroundColor = UIColor.lightGray
        transactionHashLabel?.text = "transaction hash"
        transactionHashLabel?.textAlignment = .left
        transactionHashLabel?.isEditable = false
        transactionHashLabel?.textColor = UIColor.black
        userInfoView!.addSubview(transactionHashLabel!)
    }

    func buildUi() {
        let titleLabel = UILabel(frame: CGRect(x: view.width() / 2 - 120, y: 80, width: 240, height: 30))
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.text = "UniPass SDK Demo"
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.black
        view?.addSubview(titleLabel)

        loginView = UIView(frame: CGRect(x: 0, y: titleLabel.bottom + 10, width: view.width(), height: view.height()))
        loginView?.isHidden = false
        buildLoginUi()
        view.addSubview(loginView!)

        userInfoView = UIScrollView(frame: CGRect(x: 0, y: titleLabel.bottom + 10, width: view.width(), height: view.height() + 200))
        userInfoView?.isHidden = true
        userInfoView?.isScrollEnabled = true
        buildUserInfoUi()
        view.addSubview(userInfoView!)
    }

    func refreshUI() {
        if let userInfo = unipassSdk?.getUserInfo() {
            loginView?.isHidden = true
            userInfoView?.isHidden = false

            addressValueText?.text = userInfo.address
            emailValueText?.text = userInfo.email
            siweMsgValueText?.text = userInfo.message
            siweSigValueText?.text = userInfo.signature

            print(userInfo)
        } else {
            loginView?.isHidden = false
            userInfoView?.isHidden = true

            addressValueText?.text = "empty"
            transactionHashLabel?.text = "transaction hash"
            signatureValueText?.text = "signature"
        }
    }

    @objc func googleLoginBtnClicked() {
        loginBtnClicked(loginOption: UniPassSDKLoginOption(connectType: ConnectType.google, authorize: false, returnEmail: emailReturnSwitch?.isOn))
    }

    @objc func emailLoginBtnClicked() {
        loginBtnClicked(loginOption: UniPassSDKLoginOption(connectType: ConnectType.email, authorize: false, returnEmail: emailReturnSwitch?.isOn))
    }

    @objc func unipassLoginBtnClicked() {
        loginBtnClicked(loginOption: UniPassSDKLoginOption(connectType: ConnectType.both, authorize: false, returnEmail: emailReturnSwitch?.isOn))
    }

    @objc func loginAuthClicked() {
        loginBtnClicked(loginOption: UniPassSDKLoginOption(connectType: ConnectType.both, authorize: true, returnEmail: emailReturnSwitch?.isOn))
    }

    func loginBtnClicked(loginOption: UniPassSDKLoginOption?) {
        unipassSdk?.logIn(loginSuccessBlock: { userInfo in
            print("unipassSdk: Login successfully ✅")
            print("userInfo = ", userInfo)
//            self.addressValueText?.text = userInfo.address

            self.refreshUI()

        }, loginErrorBlock: { error in
            print("unipassSdk: Login failed ❎", error)
        }, loginOption: loginOption)
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
                self.signatureValueText?.text = signature
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
