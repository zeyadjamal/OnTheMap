//
//  ViewController.swift
//  OnThe Map
//
//  Created by zico on 5/17/19.
//  Copyright © 2019 mansoura Unversity. All rights reserved.
//

import UIKit
class ViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var LoginButton: UIButton!
    @IBOutlet weak var EmailTextFeild: UITextField!
    @IBOutlet weak var passwordTextFields: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToNotificationsObserver()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotificationsObserver()
    }
    func enableForm(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.EmailTextFeild.isEnabled = isEnabled
            self.passwordTextFields.isEnabled = isEnabled
            self.LoginButton.isEnabled = isEnabled
            self.signUpButton.isEnabled = isEnabled
        }
    }
    @IBAction func LogInbutton(_ sender: Any) {
        guard let email = EmailTextFeild.text,!email.isEmpty,
            let password = passwordTextFields.text,!password.isEmpty else{
                Alert(title: "Error", message: "Email and password is empty...")
                return
        }
        let ai = self.startAnActivityIndicator()
        enableForm(false)
        API.postSession(username: email, password: password) { (errString) in
            ai.stopAnimating()
            self.enableForm(true)
            guard errString == nil else {
                self.Alert(title: "Error", message: errString!)
                return
            }
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "Login", sender: nil)
            }
        }
    }
    @IBAction func SignUpButton(_ sender: Any) {
        if let url = URL(string: "https://www.udacity.com/account/auth#!/signup"),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            
        }
        
    }
    
}


