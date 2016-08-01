//
//  Created by Pavel Dolezal on 18/07/16.
//  Copyright © 2016 eMan s.r.o. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

class InterfaceController: WKInterfaceController, WCSessionDelegate {
	
	@IBOutlet private var redSwitch: WKInterfaceSwitch!
	@IBOutlet private var greenSwitch: WKInterfaceSwitch!
	@IBOutlet private var blueSwitch: WKInterfaceSwitch!
	
	private var redStatus = false
	private var greenStatus = false
	private var blueStatus = false
	
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
		
		redSwitch.setColor(UIColor.ah_redColor)
		greenSwitch.setColor(UIColor.ah_greenColor)
		blueSwitch.setColor(UIColor.ah_blueColor)
    }

    override func willActivate() {
        super.willActivate()
		
		Log.info("will activate")
		
		setupSession()
		sendMessage(key: "reconnectBroker", value: "")
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
	
	func setupSession() {
		let session = WCSession.defaultSession()
		session.delegate = self
		session.activateSession()
	}
	
	// MARK: - Actions
	
	@IBAction func setRedStatus(status: Bool) {
		redStatus = status
		sendMessage(key: Diod.Red.rawValue, status: status)
	}
	
	@IBAction func setGreenStatus(status: Bool) {
		greenStatus = status
		sendMessage(key: Diod.Green.rawValue, status: status)
	}
	
	@IBAction func setBlueStatus(status: Bool) {
		blueStatus = status
		sendMessage(key: Diod.Blue.rawValue, status: status)
	}
	
	func sendMessage(key key: String, value: String, retries: Int = 10) {
		let session = WCSession.defaultSession()
//		guard session.reachable else { return }
		
		let message = [key: value]
		
		session.sendMessage(message, replyHandler: nil, errorHandler: { [unowned self] (error) in
			if 0 < retries {
				// This hack ensures (sort of) that message gets delivered if session is temporarily unavailable
				// which happens often when activating the watch app. As of watchOS 2 there is no reliable way
				// to find out that session is reachable and message can be sent.
				dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
					self.sendMessage(key: key, value: value, retries: retries - 1)
				}
			}
		})
	}
	
	func sendMessage(key key: String, status: Bool) {
		sendMessage(key: key, value: status ? "on" : "off")
	}
	
	// MARK: - WCSessionDelegate
	
	func session(session: WCSession, activationDidCompleteWithState activationState: WCSessionActivationState, error: NSError?) {
	}
	
	func sessionDidBecomeInactive(session: WCSession) {
	}
	
	func sessionWatchStateDidChange(session: WCSession) {
		Log.info("Session watch state did change")
	}
	
	/// Possible messages:
	/// 1. Connection change: ["state": "online"/"offline"] - NOT IMPLEMENTED
	/// 2. Diod change: ["red": "off"]
	func session(session: WCSession, didReceiveMessage message: [String : AnyObject]) {
		Log.info("Session did recieve user info: \(message)")
		
		let key = message.keys.first!
		let value = message.values.first as! String
		
		if let diod = Diod(rawValue: key) {
			let sw: WKInterfaceSwitch
			
			switch diod {
			case .Red: sw = redSwitch
			case .Green: sw = greenSwitch
			case .Blue: sw = blueSwitch
			}
			
			sw.setOn(value == "on")
		}
		
	}

}
