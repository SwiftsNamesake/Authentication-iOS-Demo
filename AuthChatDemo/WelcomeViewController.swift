//
//  WelcomeViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
//	var chpwdview = ChangePasswordView()

	@IBOutlet var chpwdview: ChangePasswordView!

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		labelUsername.text = PerfectLocalAuth.username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Welcome
	@IBOutlet var labelUsername: UILabel!
	@IBAction func btnLogout(_ sender: Any) {
		PerfectLocalAuth.logout({
			self.performSegue(withIdentifier: "logout", sender: nil)
		})
	}

	@IBAction func btnOpenChangePassword(_ sender: Any) {
		chpwdview.isHidden = false

	}
	// Change Password
	@IBOutlet var pwd1: UITextField!
	@IBOutlet var pwd2: UITextField!
	@IBOutlet var labelMessage: UILabel!
	
	@IBAction func btnSaveChangePassword(_ sender: Any) {
		guard pwd1.text == pwd2.text, !(pwd1.text ?? "").isEmpty else {
			self.labelMessage.text = "Please supply matching passwords."
			return
		}

		PerfectLocalAuth.changePassword(pwd1.text ?? "", pwd2.text ?? "", {
			error, msg in
			self.labelMessage.text = msg
			if error == "none" {
				self.chpwdview.isHidden = true
			}
			self.pwd1.text = ""
			self.pwd2.text = ""
		})

	}
	@IBAction func btnCancel(_ sender: Any) {
		chpwdview.isHidden = true
	}
	


}
