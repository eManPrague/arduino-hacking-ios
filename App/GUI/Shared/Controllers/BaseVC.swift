//
//  Created by Pavel Dolezal on 03/07/15.
//  Copyright (c) 2015 eMan s.r.o. All rights reserved.
//

import UIKit

/// Base view controller for all app’s VCs.
class BaseVC: UIViewController {
    
    /// Name suitable for xib name.
    static var nibName: String {
        let components = NSStringFromClass(self).componentsSeparatedByString(".")
        return components[components.count - 1]
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Log.info("\(self.dynamicType.nibName) did appear.")
    }

}
