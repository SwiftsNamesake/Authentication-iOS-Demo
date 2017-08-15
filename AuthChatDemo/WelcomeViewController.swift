//
//  WelcomeViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit
import SwiftyJSON

class WelcomeViewController: UIViewController {
//	var chpwdview = ChangePasswordView()

	@IBOutlet var chpwdview: ChangePasswordView!
	@IBOutlet var btnChangePwd: UIButton!
	@IBOutlet var txtPrefKey: UITextField!
	@IBOutlet var txtPrefValue: UITextField!
	@IBOutlet var btnPrefSave: UIButton!
	@IBOutlet var prefText: UITextView!

	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		if PerfectLocalAuth.accountType != "local" {
			btnChangePwd.isHidden = true
		} else {
			btnChangePwd.isHidden = false
		}
		labelUsername.text = PerfectLocalAuth.realname()
		PerfectLocalAuth.getMyData{
			self.prefText.text = "\(JSON(PerfectLocalAuth.userdata))"
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	// Welcome
	@IBOutlet var labelUsername: UILabel!
	@IBAction func btnLogout(_ sender: Any) {
		PerfectLocalAuth.logout({
			PerfectLocalAuth.sessionid 	= ""
			PerfectLocalAuth.csrf 		= ""
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
	

	@IBAction func btnSavePrefsAction(_ sender: Any) {
		guard !(txtPrefKey.text ?? "").isEmpty, !(txtPrefValue.text ?? "").isEmpty else {
//			self.labelMessage.text = "Please supply matching passwords."
			return
		}
		PerfectLocalAuth.userdata[txtPrefKey.text ?? ""] = txtPrefValue.text ?? ""
		PerfectLocalAuth.saveMyData(PerfectLocalAuth.userdata, {
			error, msg in
//			print(msg)
//			self.labelMessage.text = msg
			self.prefText.text = "\(JSON(PerfectLocalAuth.userdata))"

			self.txtPrefKey.text = ""
			self.txtPrefValue.text = ""
		})


	}

}
