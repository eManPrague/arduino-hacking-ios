//
//  Created by Pavel Dolezal on 06/07/16.
//  Copyright © 2016 eMan s.r.o. All rights reserved.
//

import UIKit

extension UIView {
	
	public static var em_nibName: String {
		let components = NSStringFromClass(self).componentsSeparatedByString(".")
		return components[components.count - 1]
	}
	
	public static var em_nib: UINib {
		return UINib(nibName: em_nibName, bundle: nil)
	}
	
	/// Load custom UIView subclass from nib.
	///
	/// Usage:
	///
	///     let n: CustomView = CustomView.em_nibInstance()
	public class func em_nibInstance<T>() -> T {
		let array = em_nib.instantiateWithOwner(nil, options: nil)
		return array.first as! T
	}
}
