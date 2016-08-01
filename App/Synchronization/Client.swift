//
//  Created by Pavel Dolezal on 04/07/16.
//  Copyright © 2016 eMan s.r.o. All rights reserved.
//

import Foundation
import CocoaMQTT

/// Delegate for Arduino client.
protocol ClientDelegate: class {
	/// Fired whenever remote device (Arduino) goes online/offline.
	func client(client: Client, deviceDidChangeOnlineStatus: Bool)
	
	/// Fired when any diod on remote device (Arduino) changes state.
	func client(client: Client, didChangeDiod diod: Diod, on: Bool)
	
	/// Fired when the client connects/disconnects from message broker.
	/// Publish messages only after this methods is called with true in parameter
	/// and not after it is called with false in parameter.
	func client(client: Client, didChangeConnectionToMessageBroker connected: Bool)
}

/// Arduino client configuration.
struct Configuration {
	let host: String
	let port: UInt16
	let clientID: String
	let deviceID: String
	let keepAlive: UInt16
	let username: String
	let password: String
}

private struct State {
	static let off: UInt8 = 0x0
	static let on:  UInt8 = 0x1
}

/// Client for communication with remote device (Arduino).
final class Client: CocoaMQTTDelegate {
	
	private let mqtt: CocoaMQTT
	
	deinit {
		switch mqtt.connState {
		case .CONNECTED, .CONNECTING:
			mqtt.disconnect()
		default: break
		}
	}
	
	let configuration: Configuration
	
	private let namespace = "arduino"
	
	weak var delegate: ClientDelegate?
	
	init(configuration: Configuration) {
		self.configuration = configuration
		mqtt = CocoaMQTT(clientId: configuration.clientID, host: configuration.host, port: configuration.port)
		mqtt.keepAlive = configuration.keepAlive
		mqtt.username = configuration.username
		mqtt.password = configuration.password
//		mqtt.secureMQTT = true
		mqtt.delegate = self
	}
	
	func connect() {
		mqtt.connect()
	}
	
	func disconnect() {
		mqtt.disconnect()
	}
	
	var isConnected = false
	
	/// Publish new diod on/off state.
	func publish(diod: Diod, on: Bool) {
		let topic = topicWithEndpoint(diod.rawValue)
		let payload: [UInt8] = on ? [State.on] : [State.off]
		let message = CocoaMQTTMessage(topic: topic, payload: payload, qos: .QOS1, retained: true, dup: false)
		mqtt.publish(message)
	}
	
	private func topicWithEndpoint(endpoint: String) -> String {
		return "\(namespace)/\(configuration.deviceID)/\(endpoint)"
	}
	
	// MARK: - MQTTDelegate
	
	func mqtt(mqtt: CocoaMQTT, didConnect host: String, port: Int) {
		Log.info("didConnect")
	}
	
	func mqtt(mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
		Log.info("didConnectAck")
		
		// Subscribing to this doesn’t return retained values
//		let allTopics = topicWithEndpoint("+")
		
		mqtt.subscribe(topicWithEndpoint(Diod.Red.rawValue))
		mqtt.subscribe(topicWithEndpoint(Diod.Green.rawValue))
		mqtt.subscribe(topicWithEndpoint(Diod.Blue.rawValue))
		mqtt.subscribe(topicWithEndpoint("status"))
	}
	
	func mqtt(mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
		Log.info("didPublishMessage")
	}
	
	func mqtt(mqtt: CocoaMQTT, didPublishAck id: UInt16) {
		Log.info("didPublishAck")
	}
	
	func mqtt(mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16 ) {
		Log.info("didReceiveMessage: \(message.topic) \(message.string)")
		
		let endpoint = message.topic.componentsSeparatedByString("/").last ?? ""
		let firstByte = message.payload.first ?? 0
		let state = !(firstByte == State.off) // 0 means off, everything else means on
		
		if let diod = Diod(rawValue: endpoint) {
			delegate?.client(self, didChangeDiod: diod, on: state)
		} else if endpoint == "status" {
			delegate?.client(self, deviceDidChangeOnlineStatus: state)
		}
	}
	
	func mqtt(mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
		Log.info("didSubscribeTopic \(topic)")
		
		if !isConnected {
			isConnected = true
			delegate?.client(self, didChangeConnectionToMessageBroker: isConnected)
		}
	}
	
	func mqtt(mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
		Log.info("didUnsubscribeTopic")
	}
	
	func mqttDidPing(mqtt: CocoaMQTT) {
//		Log.info("mqttDidPing")
	}
	
	func mqttDidReceivePong(mqtt: CocoaMQTT) {
//		Log.info("mqttDidReceivePong")
	}
	
	func mqttDidDisconnect(mqtt: CocoaMQTT, withError err: NSError?) {
		Log.info("mqttDidDisconnect \(err)")
		
		isConnected = false
		delegate?.client(self, didChangeConnectionToMessageBroker: isConnected)
		
		if err != nil {
			let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
			dispatch_after(delayTime, dispatch_get_main_queue()) {
				self.connect()
			}
		}
	}
	
}
