//
//  App configuration settings and global functions.
//
//  Created by Pavel Dolezal on 03/07/15.
//  Copyright (c) 2015 eMan s.r.o. All rights reserved.
//

import Foundation
import UIKit

/// Configuration for 
struct RabbitMQ {
	static let host = ""
	static let port: UInt16 = 1883
	static let username = ""
	static let password = ""
}

/// Arduino identifier on message broker.
let kDeviceID = "arduino-uno"

/// MQTT keep alive time interval.
let kKeepAlive: UInt16 = 1


private func clientID(suffix suffix: String) -> String {
	return "\(UIDevice.currentDevice().identifierForVendor!.UUIDString)/\(suffix)"
}

private func configuration(suffix suffix: String) -> Configuration {
	return Configuration(host: RabbitMQ.host,
	                     port: RabbitMQ.port,
	                     clientID: clientID(suffix: suffix),
	                     deviceID: kDeviceID,
	                     keepAlive: kKeepAlive,
	                     username: RabbitMQ.username,
	                     password: RabbitMQ.password)
}

var configurationForApp: Configuration {
	return configuration(suffix: "app")
}

var configurationForWatch: Configuration {
	return configuration(suffix: "watch")
}
