//
//  Created by Pavel Dolezal on 06/07/16.
//  Copyright © 2016 eMan s.r.o. All rights reserved.
//

import UIKit

protocol SwitchViewDelegate: class {
	func switchView(view: SwitchView, didChangeValue value: Bool)
}

final class SwitchView: UIView {
	
	@IBOutlet private var diodSwitch: UISwitch!
	@IBOutlet private var titleLabel: UILabel!
	
	weak var delegate: SwitchViewDelegate?
	
	var diod: Diod?
	
	var title: String {
		get { return titleLabel.text ?? "" }
		set { titleLabel.text = newValue }
	}
	
	var color: UIColor? {
		get { return diodSwitch.onTintColor }
		set { diodSwitch.onTintColor = newValue }
	}
	
	var value: Bool {
		get { return diodSwitch.on }
		set { diodSwitch.on = newValue }
	}
	
	@IBAction func didChangeValue(sender: UISwitch) {
		delegate?.switchView(self, didChangeValue: sender.on)
	}
}
