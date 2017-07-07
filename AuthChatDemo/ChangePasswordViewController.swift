//
//  changePasswordViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-06.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Change Password
	@IBOutlet var pwd1: UITextField!
	@IBOutlet var pwd2: UITextField!
	@IBOutlet var labelMessage: UILabel!

	@IBAction func btnSaveChangePassword(_ sender: Any) {
		PerfectLocalAuth.changePassword(pwd1.text ?? "", pwd2.text ?? "", {
			error, msg in
			if error == "none" {
				self.labelMessage.text = msg
			} else if msg == "Login Failure" {
				self.labelMessage.text = "Please supply a valid username and password"
			} else {
				self.labelMessage.text = msg
			}
		})

	}
	@IBAction func btnCancel(_ sender: Any) {
	}

}
