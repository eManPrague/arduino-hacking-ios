//
//  Created by Pavel Dolezal on 06/07/16.
//  Copyright © 2016 eMan s.r.o. All rights reserved.
//

import UIKit

final class ArduinoVC: BaseVC, ClientDelegate, SwitchViewDelegate {
	
	@IBOutlet private var headerView: HeaderView!
	@IBOutlet private var stackView: UIStackView!
	
	private let client: Client
	
	private var redSwitch: SwitchView!
	private var greenSwitch: SwitchView!
	private var blueSwitch: SwitchView!
	
	init(client: Client) {
		self.client = client
		super.init(nibName: nil, bundle: nil)
		self.client.delegate = self
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		headerView.deviceName = client.configuration.deviceID
		headerView.statusText = "Unknown"
		
		redSwitch = addSwitchView(title: "Red", diod: .Red, color: UIColor.ah_redColor)
		greenSwitch = addSwitchView(title: "Green", diod: .Green, color: UIColor.ah_greenColor)
		blueSwitch = addSwitchView(title: "Blue", diod: .Blue, color: UIColor.ah_blueColor)
		stackView.addArrangedSubview(UIView())
		
		showControls(false)
		client.connect()
	}
	
	private func addSwitchView(title title: String, diod: Diod, color: UIColor) -> SwitchView {
		let switchView: SwitchView = SwitchView.em_nibInstance()
		switchView.delegate = self
		switchView.title = title
		switchView.diod = diod
		switchView.color = color
		stackView.addArrangedSubview(switchView)
		return switchView
	}
	
	private func showControls(show: Bool) {
		stackView.hidden = !show
	}
	
	// MARK: - ClientDelegate
	
	func client(client: Client, deviceDidChangeOnlineStatus status: Bool) {
		headerView.statusText = status ? "Online" : "Offline"
	}
	
	func client(client: Client, didChangeDiod diod: Diod, on: Bool) {
		switch diod {
		case .Red: redSwitch.value = on
		case .Green: greenSwitch.value = on
		case .Blue: blueSwitch.value = on
		}
	}
	
	func client(client: Client, didChangeConnectionToMessageBroker connection: Bool) {
		showControls(connection)
	}
	
	// MARK: - SwitchViewDelegate
	
	func switchView(view: SwitchView, didChangeValue value: Bool) {
		guard let diod = view.diod else { return }
		
		client.publish(diod, on: value)
	}
}
