//
//  Created by Pavel Dolezal on 03/07/15.
//  Copyright (c) 2015 eMan s.r.o. All rights reserved.
//

import UIKit
import CoreMotion
import CocoaMQTT
import WatchConnectivity

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, WCSessionDelegate, ClientDelegate {

    var window: UIWindow?
    var flow: AppFlow!
	
	var client: Client!

    // MARK: - App life-cycle

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setupLogging()
		setupWatchKitSession()
        setupWindow()
		
        return true
    }
    
    // MARK: - Setup
	
	private func setupWatchKitSession() {
		if WCSession.isSupported() {
			let session = WCSession.defaultSession()
			session.delegate = self
			session.activateSession()
			
			client = Client(configuration: configurationForWatch)
			client.delegate = self
			client.connect()
		}
	}
    
    private func setupWindow() {
		flow = AppFlow()
		window = UIWindow()
        window?.frame = UIScreen.mainScreen().bounds
        window?.rootViewController = flow.vc
        window?.makeKeyAndVisible()
    }
    
    private func setupLogging() {
        #if DEBUG
            Log.enabled = true
            Log.level = .Debug
        #endif
	}
	
	// MARK: - WCSessionDelegate
	
	func sessionDidDeactivate(session: WCSession) {
		Log.info("Session did deactivate")
	}
	
	func sessionDidBecomeInactive(session: WCSession) {
		Log.info("Session did become inactive")
	}
	
	/// Possbile messages:
	/// 1. Diod change: ["red: "on"]
	/// 2. Reconnect: ["reconnectBroker": "..."]
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		Log.info("Session did recieve message: \(message)")
		
		let key = message.keys.first!
		let value = message.values.first as! String
		
		if let diod = Diod(rawValue: key) {
			client.publish(diod, on: value == "on")
		}
		
		if key == "reconnectBroker" {
			client.disconnect()
			client.connect()
		}
	}
	
	func sessionWatchStateDidChange(session: WCSession) {
		Log.info("Session watch state did change")
		
		if session.watchAppInstalled && session.paired {
			Log.info("Watch app installed and paired")
		}
	}
	
	// MARK: - ClientDelegate
	
	func client(client: Client, deviceDidChangeOnlineStatus: Bool) {
		
	}
	
	func client(client: Client, didChangeDiod diod: Diod, on: Bool) {
		let message = [diod.rawValue: on ? "on" : "off"]
		
		WCSession.defaultSession().sendMessage(message, replyHandler: nil, errorHandler: nil)
	}
	
	func client(client: Client, didChangeConnectionToMessageBroker: Bool) {

	}
	
}

