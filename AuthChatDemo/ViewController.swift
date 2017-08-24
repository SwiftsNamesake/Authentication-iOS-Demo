//
//  ViewController.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import UIKit
import OAuthSwift
import SafariServices
import SwiftyJSON

let services = Services()
let DocumentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
let FileManager: FileManager = Foundation.FileManager.default

class ViewController: OAuthViewController { // UIViewController

	// oauth swift object (retain)
	var oauthswift: OAuthSwift?
	var currentParameters = [String: String]()

//	lazy var internalWebViewController: WebViewController = {
//		let controller = WebViewController()
//		#if os(OSX)
//			controller.view = NSView(frame: NSRect(x:0, y:0, width: 450, height: 500)) // needed if no nib or not loaded from storyboard
//		#elseif os(iOS)
//			controller.view = UIView(frame: UIScreen.main.bounds) // needed if no nib or not loaded from storyboard
//		#endif
//		controller.delegate = self
//		controller.viewDidLoad() // allow WebViewController to use this ViewController as parent to be presented
//		return controller
//	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		// Load config from files
		initConf()

		// init now web view handler
//		let _ = internalWebViewController.webView

	}


	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

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
				PerfectLocalAuth.accountType = "local"
				self.performSegue(withIdentifier: "welcome", sender: self)
			} else if msg == "Login Failure" {
				self.labelMessage.text = "Please supply a valid username and password"
			} else {
				self.labelMessage.text = msg
			}
		})
	}
	func getProfileFacebook(_ oauthswift: OAuth2Swift, success: @escaping () -> Void ) {
		let _ = oauthswift.client.get(
			"https://graph.facebook.com/me?",
			success: { response in
				let data = JSON(data: response.data)
				PerfectLocalAuth.name = data["name"].stringValue
				success()
		}, failure: { error in
			print(error)
		}
		)
	}

	func getProfilePerfect(_ oauthswift: OAuth2Swift, url: String, success: @escaping () -> Void ) {
		let _ = oauthswift.client.get(
			url,
			success: { response in
				let data = JSON(data: response.data)
				PerfectLocalAuth.name 		= "\(data["firstname"].stringValue) \(data["lastname"].stringValue)"
				PerfectLocalAuth.firstname 	= data["firstname"].stringValue
				PerfectLocalAuth.lastname 	= data["lastname"].stringValue
				success()
		}, failure: { error in
			print(error)
		}
		)
	}


	func getURLHandler() -> OAuthSwiftURLHandlerType {
//		#if os(iOS)
//			if #available(iOS 9.0, *) {
//				let handler = SafariURLHandler(viewController: self, oauthSwift: self.oauthswift!)
//				handler.presentCompletion = {
//					print("Safari presented")
//				}
//				handler.dismissCompletion = {
//					print("Safari dismissed")
//				}
//				handler.factory = { url in
//					let controller = SFSafariViewController(url: url)
//					// Customize it, for instance
//					if #available(iOS 10.0, *) {
//						//  controller.preferredBarTintColor = UIColor.red
//					}
//					return controller
//				}
//
//				return handler
//			}
//		#endif
		return OAuthSwiftOpenURLExternally.sharedInstance

	}



	/* ==========================================================
	FACEBOOK
	========================================================== */
	@IBAction func doFacebookOAuth(_ sender: Any) {
		let service = "Facebook"

		guard var parameters = services[service] else {
			print("\(service) not configured")
			return
		}

		let oauthswift = OAuth2Swift(
			consumerKey:    parameters["consumerKey"] ?? "",
			consumerSecret: parameters["consumerSecret"] ?? "",
			authorizeUrl:   "https://www.facebook.com/dialog/oauth",
			accessTokenUrl: "https://graph.facebook.com/oauth/access_token",
			responseType:   "code"
		)

		
		self.oauthswift = oauthswift
		oauthswift.authorizeURLHandler = getURLHandler()
		let state = generateState(withLength: 20)
		let _ = oauthswift.authorize(
			withCallbackURL: URL(string: "\(PerfectLocalAuth.host)/api/v1/oauth/return/facebook")!, scope: "public_profile", state: state,
			success: { credential, response, parameters in

				// send upgrade user signal to Perfect OAuth2 Server
				PerfectLocalAuth.upgradeUser("facebook", credential.oauthToken, {
					userid in
					PerfectLocalAuth.accountType = "facebook"
					self.getProfileFacebook(oauthswift, success: {
						self.performSegue(withIdentifier: "welcome", sender: self)
					})
				})

		}, failure: { error in
			print(error.localizedDescription, terminator: "")
		}
		)
	}




	/* ==========================================================
	LINKEDIN
	========================================================== */
	@IBAction func doLinkeInOAuth(_ sender: Any) {
		let service = "Linkedin"

		guard var parameters = services[service] else {
			print("\(service) not configured")
			return
		}
		// Note, something is weird with Linkedin OAuth2, it seems to require the secret here and it should not
		let oauthswift = OAuth2Swift(
			consumerKey:    parameters["consumerKey"] ?? "",
			consumerSecret: parameters["consumerSecret"] ?? "",
			authorizeUrl:   "https://www.linkedin.com/oauth/v2/authorization",
			accessTokenUrl: "https://www.linkedin.com/oauth/v2/accessToken",
			responseType:   "code"
		)
		//oauth-swift://oauth-callback/github
		self.oauthswift = oauthswift
		oauthswift.authorizeURLHandler = getURLHandler()
		let state = generateState(withLength: 20)

		let _ = oauthswift.authorize(
			withCallbackURL: URL(string: "\(PerfectLocalAuth.host)/api/v1/oauth/return/linkedin")!,
			scope: "r_basicprofile", state:state,
			success: { credential, response, parameters in

				// send upgrade user signal to Perfect OAuth2 Server
				PerfectLocalAuth.upgradeUser("linkedin", credential.oauthToken, {
					userid in
					PerfectLocalAuth.accountType = "linkedin"
					// Do your request
					self.performSegue(withIdentifier: "welcome", sender: self)
				})
		},
			failure: { error in
				print(error.localizedDescription)
		}
		)
	}


	/* ==========================================================
	GOOGLE
	========================================================== */
	@IBAction func doGoogleOAuth(_ sender: Any) {
		let service = "Google"

		guard var parameters = services[service] else {
			print("\(service) not configured")
			return
		}

		let oauthswift = OAuth2Swift(
			consumerKey:    parameters["consumerKey"] ?? "",
			consumerSecret: parameters["consumerSecret"] ?? "",
			authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
			accessTokenUrl: "https://www.googleapis.com/oauth2/v4/token",
			responseType:   "token"
		)
		//oauth-swift://oauth-callback/github
		self.oauthswift = oauthswift
		oauthswift.authorizeURLHandler = getURLHandler()
		let state = generateState(withLength: 20)

		let _ = oauthswift.authorize(
			withCallbackURL: URL(string: "\(PerfectLocalAuth.host)/api/v1/oauth/return/google")!,
			scope: "profile", state:state,
			success: { credential, response, parameters in

				// send upgrade user signal to Perfect OAuth2 Server
				PerfectLocalAuth.upgradeUser("google", credential.oauthToken, {
					userid in
					PerfectLocalAuth.accountType = "google"
					// Do your request
					self.performSegue(withIdentifier: "welcome", sender: self)
				})
			},
			failure: { error in
				print("Google OAuth2 Error: \(error.localizedDescription)")
			}
		)
	}

	/* ==========================================================
	PERFECT AUTH SERVER
	========================================================== */
	@IBAction func doPerfectAuthOAuth(_ sender: Any) {
		let service = "Perfect"

		guard var parameters = services[service] else {
			print("\(service) not configured")
			return
		}

		let oauthswift = OAuth2Swift(
			consumerKey:    parameters["consumerKey"] ?? "",
			consumerSecret: parameters["consumerSecret"] ?? "",
			authorizeUrl:   "\(PerfectLocalAuth.host)/oauth/authenticate",
			accessTokenUrl: "\(PerfectLocalAuth.host)/oauth/token",
			responseType:   "code"
		)
		//oauth-swift://oauth-callback/github
		self.oauthswift = oauthswift
		oauthswift.authorizeURLHandler = getURLHandler()
		let state = generateState(withLength: 20)

		let _ = oauthswift.authorize(
			withCallbackURL: URL(string: "\(PerfectLocalAuth.host)/api/v1/oauth/return/perfect")!,
			scope: "profile", state:state,
			success: { credential, response, parameters in
				// send upgrade user signal to Perfect OAuth2 Server
				print(credential.oauthToken)
				PerfectLocalAuth.upgradeUser("local", credential.oauthToken, {
					userid in

					PerfectLocalAuth.accountType = "perfect"
					//PerfectLocalAuth.saveSessionIdentifiers(credential.oauthToken,"")
					print("Perfect OAuth Token: \(credential.oauthToken)")
					// Do your request
					self.performSegue(withIdentifier: "welcome", sender: self)
//					self.getProfilePerfect(oauthswift, url: "\(PerfectLocalAuth.host)/oauth/profile", success: {
//					})
				})
		},
			failure: { error in
				print("Perfect OAuth2 Error: \(error.localizedDescription)")
		}
		)
	}


	// MARK: utility methods

	var confPath: String {
		let appPath = "\(DocumentDirectory)/.oauth/"
		if !FileManager.fileExists(atPath: appPath) {
			do {
				try FileManager.createDirectory(atPath: appPath, withIntermediateDirectories: false, attributes: nil)
			}catch {
				print("Failed to create \(appPath)")
			}
		}
		return "\(appPath)Services.plist"
	}

	func initConf() {
//		initConfOld()
		print("Load configuration from \n\(self.confPath)")

		// Load config from model file
		if let path = Bundle.main.path(forResource: "Services", ofType: "plist") {
			services.loadFromFile(path)

			if !FileManager.fileExists(atPath: confPath) {
				do {
					try FileManager.copyItem(atPath: path, toPath: confPath)
				}catch {
					print("Failed to copy empty conf to\(confPath)")
				}
			}
		}
		services.loadFromFile(confPath)
	}

}

extension ViewController: OAuthWebViewControllerDelegate {
	#if os(iOS) || os(tvOS)

	func oauthWebViewControllerDidPresent() {

	}
	func oauthWebViewControllerDidDismiss() {

	}
	#endif

	func oauthWebViewControllerWillAppear() {

	}
	func oauthWebViewControllerDidAppear() {

	}
	func oauthWebViewControllerWillDisappear() {

	}
	func oauthWebViewControllerDidDisappear() {
		// Ensure all listeners are removed if presented web view close
		oauthswift?.cancel()
	}
}


