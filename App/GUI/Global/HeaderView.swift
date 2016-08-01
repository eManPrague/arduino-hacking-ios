//
//  Created by Pavel Dolezal on 06/07/16.
//  Copyright © 2016 eMan s.r.o. All rights reserved.
//

import UIKit

final class HeaderView: UILabel {
	
	var deviceName = "" {
		didSet { reload() }
	}
	
	var statusText = "" {
		didSet { reload() }
	}
	
	func reload() {
		text = "Device: \(deviceName)\nStatus: \(statusText)"
	}
}
