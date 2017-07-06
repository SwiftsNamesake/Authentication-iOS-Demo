//
//  PerfectLocalAuth.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import Foundation
import Alamofire
import CoreData

public struct PerfectLocalAuth {
	public static var host 		= "http://localhost:8181"
	public static var sessionid = ""
	public static var csrf 		= ""
	public static var userid 	= ""

	public static var username	= ""
	public static var email		= ""
	public static var usertype	= ""

	//let coreDataStack = AppDelegate.coreDataStack

	private static func setHeaders() -> HTTPHeaders {
		let headers: HTTPHeaders = [
			"Authorization": "Bearer \(sessionid)",
			"_csrf": "\(csrf)"
		]
		return headers
	}

	public static func save(name: String, value: String) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		let managedContext = appDelegate.persistentContainer.viewContext
//		let entity = NSEntityDescription.entity(forEntityName: "Auth", in: managedContext)!
//		let obj = NSManagedObject(entity: entity, insertInto: managedContext)
//		obj.setValue(name, forKeyPath: "name")
//		obj.setValue(value, forKeyPath: "value")
		let entity = Auth(context: managedContext)
		entity.name = name
		entity.value = value
		do {
			try managedContext.save()
			print("saved")
		} catch let error as NSError {
			print("Could not save. \(error), \(error.userInfo)")
		}
	}

	public static func delete(name: String) {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return
		}
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Auth")
		fetchRequest.predicate = NSPredicate(format: "name = %@", name)
		do {
			var result = try managedContext.fetch(fetchRequest)
			if result.count > 0 {
				managedContext.delete(result[0])
			} else {
				return
			}
		} catch let error as NSError {
			print("Could not fetch to delete. \(error), \(error.userInfo)")
		}
	}


	public static func load(name: String) -> String {
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return ""
		}
		let managedContext = appDelegate.persistentContainer.viewContext
		let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Auth")
		fetchRequest.predicate = NSPredicate(format: "name = %@", name)
		do {
			var result = try managedContext.fetch(fetchRequest)
			if result.count > 0 {
				print("loaded \(name) as \(result[0].value(forKey: "value") as? String ?? "")")
				return result[0].value(forKey: "value") as? String ?? ""
			} else {
				return ""
			}
		} catch let error as NSError {
			print("Could not fetch. \(error), \(error.userInfo)")
		}
		return ""
	}

	public static func startup() -> Bool{
		print("running startup")
		PerfectLocalAuth.sessionid 	= PerfectLocalAuth.load(name: "sessionid")
		PerfectLocalAuth.csrf 		= PerfectLocalAuth.load(name: "csrf")
		PerfectLocalAuth.userid 	= PerfectLocalAuth.load(name: "userid")
		PerfectLocalAuth.username 	= PerfectLocalAuth.load(name: "username")
		PerfectLocalAuth.email 		= PerfectLocalAuth.load(name: "email")
		PerfectLocalAuth.usertype 	= PerfectLocalAuth.load(name: "usertype")
//		print("userid: \(PerfectLocalAuth.userid)")
//		print("username: \(PerfectLocalAuth.username)")
		return true
	}

	public static func getSession(){
		if PerfectLocalAuth.sessionid.isEmpty {
			Alamofire.request("\(PerfectLocalAuth.host)/api/v1/session", headers: PerfectLocalAuth.setHeaders()).responseJSON {
				response in
				if response.result.isSuccess {
					if let json = response.result.value {
						let j = json as? [String: Any] ?? [String: Any]()
						PerfectLocalAuth.sessionid = j["sessionid"] as? String ?? ""
						PerfectLocalAuth.csrf = j["csrf"] as? String ?? ""

						PerfectLocalAuth.save(name: "sessionid", value: PerfectLocalAuth.sessionid)
						PerfectLocalAuth.save(name: "csrf", value: PerfectLocalAuth.csrf)

					}
				} else {
					print("SESSION FAIL")
				}
			}
		}
	}

	public static func login(username: String, password: String, _ callback: @escaping (String)->Void) {
		let parameters: Parameters = [
			"username": username,
			"password": password
		]
		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/login", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: PerfectLocalAuth.setHeaders()).responseJSON {
			response in
			if response.result.isSuccess {
				if let json = response.result.value {
//					debugPrint(response)

//					print("JSON from login: \(json)")
					let j = json as? [String: Any] ?? [String: Any]()

					let msg = j["error"] as? String ?? ""
					PerfectLocalAuth.userid 	= j["userid"] as? String ?? ""
					PerfectLocalAuth.username 	= j["username"] as? String ?? "."
					PerfectLocalAuth.email 		= j["email"] as? String ?? ""
					PerfectLocalAuth.usertype 	= j["usertype"] as? String ?? ""

					PerfectLocalAuth.save(name: "userid", value: PerfectLocalAuth.userid)
					PerfectLocalAuth.save(name: "username", value: PerfectLocalAuth.username)
					PerfectLocalAuth.save(name: "email", value: PerfectLocalAuth.email)
					PerfectLocalAuth.save(name: "usertype", value: PerfectLocalAuth.usertype)
					callback(msg)
				}
			} else {
				print("SESSION FAIL")
				callback("Failed to communicate with Authentication Server")
			}
		}
	}

	public static func register(username: String, email: String) {

	}

	public static func changePassword(_ password1: String, _ password2: String) {

	}

	public static func logout(_ callback: @escaping ()->Void) {
		// remove props
		PerfectLocalAuth.sessionid 	= "."
		PerfectLocalAuth.csrf 		= "."
		PerfectLocalAuth.userid 	= "."
		PerfectLocalAuth.username 	= "."
		PerfectLocalAuth.email 		= "."
		PerfectLocalAuth.usertype 	= "."

		// save cleared rows
		//			PerfectLocalAuth.saveProperties(callback)

		PerfectLocalAuth.delete(name: "sessionid")
		PerfectLocalAuth.delete(name: "csrf")
		PerfectLocalAuth.delete(name: "userid")
		PerfectLocalAuth.delete(name: "username")
		PerfectLocalAuth.delete(name: "email")
		PerfectLocalAuth.delete(name: "usertype")
		
		Alamofire.request("\(PerfectLocalAuth.host)/api/v1/logout", headers: PerfectLocalAuth.setHeaders()).responseJSON {
			_ in

			callback()
		}

	}

	public static func saveProperties(_ callback: @escaping ()->Void) {

		PerfectLocalAuth.save(name: "sessionid", value: PerfectLocalAuth.sessionid)
		PerfectLocalAuth.save(name: "csrf", value: PerfectLocalAuth.csrf)
		PerfectLocalAuth.save(name: "userid", value: PerfectLocalAuth.userid)
		PerfectLocalAuth.save(name: "username", value: PerfectLocalAuth.username)
		PerfectLocalAuth.save(name: "email", value: PerfectLocalAuth.email)
		PerfectLocalAuth.save(name: "usertype", value: PerfectLocalAuth.usertype)

		callback()

	}

}
