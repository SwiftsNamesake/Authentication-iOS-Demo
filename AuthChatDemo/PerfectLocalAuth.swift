//
//  PerfectLocalAuth.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import Foundation
import Alamofire

// TODO: Abstract the POST and GET requests
public struct PerfectLocalAuth {
	public static var host 		= "https://auth.perfect.org" //http://localhost:8181 // https://auth.perfect.org
	public static var sessionid = ""
	public static var csrf 		= ""
	public static var userid 	= ""

	public static var username	= ""
	public static var name		= ""
	public static var firstname	= ""
	public static var lastname	= ""
	public static var email		= ""
	public static var usertype	= ""

	// User preferences
	public static var userdata	= [String:Any]()

	public static var accountType	= "none"

	public static func realname() -> String {
		if !name.isEmpty {
			return name
		} else if !username.isEmpty {
			return username
		} else {
			return "unknown"
		}
	}

	public static func setHeaders() -> HTTPHeaders {
		print("Authorization: Bearer \(sessionid)")
		let headers: HTTPHeaders = [
			"Authorization": "Bearer \(sessionid)",
			"X-CSRF-Token": "\(csrf)"
		]
		return headers
	}



	public static func startup() {
		print("running startup")

		PerfectLocalAuth.sessionid = UserDefaults.standard.string(forKey: "sessionid") ?? ""
		PerfectLocalAuth.csrf = UserDefaults.standard.string(forKey: "csrf")  ?? ""

		if PerfectLocalAuth.sessionid.isEmpty {
			PerfectLocalAuth.getSession()
		} else {
			// Load user data
			PerfectLocalAuth.getMe()
//			print("end of startup: \(PerfectLocalAuth.userid)")
		}
	}

	/// Load user info
	/// Requires LoacalAuth 1.1.0 or later
	private static func getMe(){
		if !PerfectLocalAuth.sessionid.isEmpty {
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
				} else {
					print("Failure to retrieve user data (likely not logged in)")
				}
			}
		}
	}

	/// Load User Preference Data
	public static func getMyData(_ callback: @escaping ()->Void){
		if !PerfectLocalAuth.sessionid.isEmpty {
			Alamofire.request("\(PerfectLocalAuth.host)/api/v1/mydata", headers: PerfectLocalAuth.setHeaders()).responseJSON {
				response in
				if response.response?.statusCode != 400 {
					if let json = response.result.value {
						let j = json as? [String: Any] ?? [String: Any]()
						PerfectLocalAuth.userdata 	= j["userdata"] as? [String: Any] ?? [String: Any]()
					}
					callback()
				} else {
					print("Failure to retrieve user data (likely not logged in)")
				}
			}
		}
	}
	/// Save User Preference Data
	public static func saveMyData(_ data: [String:Any], _ callback: @escaping (String, String)->Void) {

		let parameters: Parameters = data

		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/mydata", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: PerfectLocalAuth.setHeaders()).responseJSON {
			response in
			if response.response?.statusCode != 400 {
				if let json = response.result.value {
					let j = json as? [String: Any] ?? [String: Any]()

					let msg = j["msg"] as? String ?? ""
					let error = j["error"] as? String ?? ""

					callback(error,msg)
				}
			} else {
				//				print("Change Password Fail: \(response.result.value)")
				callback("commerror","Failed to communicate with Authentication Server")
			}
		}
	}
	public static func getSession() {
			Alamofire.request("\(PerfectLocalAuth.host)/api/v1/session").responseJSON {
				response in
			if response.response?.statusCode != 400 {
				if let json = response.result.value {
					let j = json as? [String: Any] ?? [String: Any]()
					PerfectLocalAuth.saveSessionIdentifiers(j["sessionid"] as? String ?? "",j["csrf"] as? String ?? "")
				}
			} else {
				print("SESSION FAIL")
			}
		}
	}

	public static func saveSessionIdentifiers(_ sessionid: String, _ csrf: String) {
		PerfectLocalAuth.sessionid = sessionid
		PerfectLocalAuth.csrf = csrf

		UserDefaults.standard.set(sessionid, forKey: "sessionid")
		UserDefaults.standard.set(csrf, forKey: "csrf")
	}

	public static func login(username: String, password: String, _ callback: @escaping (String)->Void) {
		let parameters: Parameters = [
			"username": username,
			"password": password
		]
		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: PerfectLocalAuth.setHeaders()).responseJSON {
			response in
			if response.response?.statusCode != 400 {
				if let json = response.result.value {
//					debugPrint(response)

//					print("JSON from login: \(json)")
					let j = json as? [String: Any] ?? [String: Any]()

					let msg = j["error"] as? String ?? ""
					PerfectLocalAuth.userid 	= j["userid"] as? String ?? ""
					PerfectLocalAuth.username 	= j["username"] as? String ?? "."
					PerfectLocalAuth.email 		= j["email"] as? String ?? ""
					PerfectLocalAuth.usertype 	= j["usertype"] as? String ?? ""

					callback(msg)
				}
			} else {
				callback("Incorrect login")
			}
		}
	}

	public static func register(username: String, email: String, _ callback: @escaping (String)->Void) {
		let parameters: Parameters = [
			"username": username,
			"email": email
		]
		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/register", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: PerfectLocalAuth.setHeaders()).responseJSON {
			response in
			if response.response?.statusCode != 400 {
				if let json = response.result.value {
					let j = json as? [String: Any] ?? [String: Any]()

					let msg = j["error"] as? String ?? ""

					callback(msg)
				}
			} else {
//				print("Register Fail")
				callback("Registration error: Please make sure you have entered a valid username and email.")
			}
		}
	}

	public static func changePassword(_ password1: String, _ password2: String, _ callback: @escaping (String, String)->Void) {
		guard password1 == password1 else {
			callback("pwdmatch","The passwords do not match")
			return
		}
		// Add any other password criteria checking here

		let parameters: Parameters = [
			"password": password1
		]
		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/changepassword", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: PerfectLocalAuth.setHeaders()).responseJSON {
			response in
			if response.response?.statusCode != 400 {
				if let json = response.result.value {
					let j = json as? [String: Any] ?? [String: Any]()

					let msg = j["msg"] as? String ?? ""
					let error = j["error"] as? String ?? ""

					callback(error,msg)
				}
			} else {
//				print("Change Password Fail: \(response.result.value)")
				callback("commerror","Failed to communicate with Authentication Server")
			}
		}
	}

	public static func logout(_ callback: @escaping ()->Void) {
		// reset props
		PerfectLocalAuth.userid 	= ""
		PerfectLocalAuth.username 	= ""
		PerfectLocalAuth.email 		= ""
		PerfectLocalAuth.usertype 	= ""
		PerfectLocalAuth.userdata 	= [String:Any]()

		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/logout", headers: PerfectLocalAuth.setHeaders()).responseJSON {
			_ in
			PerfectLocalAuth.saveSessionIdentifiers("","")

			// now get new session
			PerfectLocalAuth.getSession()
			callback()
		}

	}

	public static func upgradeUser(_ provider: String, _ token: String, _ callback: @escaping (String)->Void) {

		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/oauth/upgrade/\(provider)/\(token)", method: .get, headers: PerfectLocalAuth.setHeaders()).responseJSON {
			response in
			if response.response?.statusCode != 400 {
				if let json = response.result.value {
					let j = json as? [String: Any] ?? [String: Any]()

					let userid = j["userid"] as? String ?? ""
					PerfectLocalAuth.firstname = j["firstname"] as? String ?? ""
					PerfectLocalAuth.lastname = j["lastname"] as? String ?? ""
					PerfectLocalAuth.name = "\(PerfectLocalAuth.firstname) \(PerfectLocalAuth.lastname)"

					callback(userid)
				}
			} else {
				callback("Failed to communicate with Authentication Server")
			}
		}
	}

}
