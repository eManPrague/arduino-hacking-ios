//
//  Created by Pavel Dolezal on 03/07/15.
//  Copyright (c) 2015 eMan s.r.o. All rights reserved.
//

import UIKit

/// Flow managing app-level navigation.
class AppFlow: Flow {
	
    lazy var vc: UIViewController = {
		let client = Client(configuration: configurationForApp)
		let arduinoVC = ArduinoVC(client: client)
		
		return UINavigationController(rootViewController: arduinoVC)
	}()

}
