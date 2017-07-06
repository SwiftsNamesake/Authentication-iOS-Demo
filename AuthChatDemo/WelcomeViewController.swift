//
//  WelcomeViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		labelUsername.text = PerfectLocalAuth.username
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
	@IBOutlet var labelUsername: UILabel!
	@IBAction func btnLogout(_ sender: Any) {
		PerfectLocalAuth.logout({
			self.performSegue(withIdentifier: "logout", sender: nil)
		})
	}
}
