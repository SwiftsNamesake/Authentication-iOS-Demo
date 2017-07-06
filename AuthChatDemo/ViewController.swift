//
//  ViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}


	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

//		print("Current session: \(PerfectLocalAuth.sessionid)")
//		print("Current userid: \(PerfectLocalAuth.userid)")


//		if !PerfectLocalAuth.userid.isEmpty {
//			performSegue(withIdentifier: "welcome", sender: nil)
//		}
		if PerfectLocalAuth.userid.characters.count > 1 {
			performSegue(withIdentifier: "welcome", sender: nil)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	@IBOutlet var txtUsername: UITextField!
	@IBOutlet var txtPassword: UITextField!
	@IBOutlet var labelMessage: UILabel!

	@IBAction func btnLogin(_ sender: Any) {
		PerfectLocalAuth.login(username: txtUsername.text ?? "", password: txtPassword.text ?? "", {
			msg in
			if msg == "Login Success" {
				self.performSegue(withIdentifier: "welcome", sender: self)
			} else if msg == "Login Failure" {
				self.labelMessage.text = "Please supply a valid username and password"
			} else {
//				print("CALLBACK MESSAGE IS \(msg)")
				self.labelMessage.text = msg
			}
		})
	}

}

