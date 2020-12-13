//
//  LandingButton.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class LandingButton: BaseButton {
	override func prepare() {
		super.prepare()
		
		layer.borderWidth = 4
		layer.borderColor = Theme.common.buttonBorder.cgColor
		layer.cornerRadius = 24
		backgroundColor = Theme.common.buttonBackground
		contentEdgeInsets = UIEdgeInsets(uniform:10)
	}
}
