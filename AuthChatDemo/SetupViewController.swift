//
//  SetupViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-06.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class SetupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

		PerfectLocalAuth.sessionid = UserDefaults.standard.string(forKey: "sessionid") ?? ""
		PerfectLocalAuth.csrf = UserDefaults.standard.string(forKey: "csrf") ?? ""

		if PerfectLocalAuth.sessionid.isEmpty {
			Alamofire.request("\(PerfectLocalAuth.host)/api/v1/session", headers: PerfectLocalAuth.setHeaders()).responseJSON {
				response in
				if response.response?.statusCode != 400 {
					if let json = response.result.value {
						let j = json as? [String: Any] ?? [String: Any]()
						PerfectLocalAuth.sessionid = j["sessionid"] as? String ?? ""
						PerfectLocalAuth.csrf = j["csrf"] as? String ?? ""

						UserDefaults.standard.set(PerfectLocalAuth.sessionid, forKey: "sessionid")
						UserDefaults.standard.set(PerfectLocalAuth.csrf, forKey: "csrf")

					}
				} else {
					print("SESSION FAIL")
				}

				DispatchQueue.main.async { self.go("finishedLoading") }
			}

		} else {
			// Load user data
//			print("Load user data for session \(PerfectLocalAuth.sessionid)")


			Alamofire.request("\(PerfectLocalAuth.host)/api/v1/me", headers: PerfectLocalAuth.setHeaders()).responseJSON {
				response in
				if response.response?.statusCode != 400 {
					if let json = response.result.value {
						let j = json as? [String: Any] ?? [String: Any]()
						PerfectLocalAuth.userid 	= j["userid"] as? String ?? ""
						PerfectLocalAuth.username 	= j["username"] as? String ?? ""
						PerfectLocalAuth.email 		= j["email"] as? String ?? ""
						PerfectLocalAuth.usertype 	= j["usertype"] as? String ?? ""
					}
//					print("loggedIn")

					DispatchQueue.main.async { self.go("loggedIn") }
				} else {
					print("Failure to retrieve user data (likely not logged in)")
					PerfectLocalAuth.getSession()

					DispatchQueue.main.async { self.go("finishedLoading") }
				}
			}

		}

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

	func go(_ segue: String) {
		self.performSegue(withIdentifier: segue, sender: nil)
	}
}
