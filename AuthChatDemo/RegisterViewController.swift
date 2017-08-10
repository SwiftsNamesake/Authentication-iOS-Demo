//
//  RegisterViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-13.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBOutlet var btnRegister: UIButton!
	@IBOutlet var btnCancel: UIButton!
	@IBOutlet var txtRegisterUsername: UITextField!
	@IBOutlet var txtRegisterEmail: UITextField!
	@IBOutlet var labelFeedback: UILabel!
	@IBOutlet var btnReturnToLogin: UIButton!

	@IBAction func btnRegisterAction(_ sender: Any) {
		PerfectLocalAuth.register(username: txtRegisterUsername.text ?? "", email: txtRegisterEmail.text ?? "", {
			msg in
			if msg == "Registration Success" {
				// Show message, and the return to login button
				self.btnReturnToLogin.isHidden = false
				self.labelFeedback.text = "Registration successful - Check your email for an email from us. It contains instructions to complete your signup."
			} else if msg == "Registration Failure" {
				self.labelFeedback.text = "Please supply a valid username and email"
			} else {
				self.labelFeedback.text = msg
			}
		})
	}
}
