//
//  GuestSignInView.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class GuestSignInView: BaseView, UITextFieldDelegate {
	struct Furniture {
		let namePlaceholder:String
		let birthdateCaption:String
		let confirmButton:String
		let minimumAgeInYears:Int
	}
	
	struct Layout {
		static let spacing:CGFloat = 10
		static let margin:CGFloat = 30
		static let nameStyle = Style(font: .title, size: 36, color: Theme.common.primaryText, alignment: .natural)
		static let buttonStyle = Style(font: .title, size: 36, color: Theme.common.primaryText, alignment: .center)
		static let captionStyle = Style(font: .body, size: 18, color: Theme.common.primaryText, alignment: .center)
		static let buttonSize = CGSize(width:320, height:120)
		static let createMemberSize = CGSize(width:50, height:50)
	}
	
	let nameView = UITextField()
	let birthdateView = UIDatePicker()
	let birthdateLabel = BaseLabel()
	let confirmButton = LandingButton()
	let createMemberView = UIView()
	
	override func prepareContent() {
		super.prepareContent()
		
		backgroundColor = Theme.common.primaryBackground
		createMemberView.backgroundColor = backgroundColor
		nameView.delegate = self
		nameView.borderStyle = .bezel
		nameView.applyStyle(Layout.nameStyle, minimumScale:0.5)
		birthdateView.datePickerMode = .date
		birthdateView.preferredDatePickerStyle = .wheels
		birthdateLabel.applyStyle(Layout.captionStyle, minimumScale:0.5, maximumLines:1)
		confirmButton.applyStyle(Layout.buttonStyle, maximumLines:2)
	}
	
	override func prepareHierarchy() {
		super.prepareHierarchy()
		
		addSubviews(createMemberView, nameView, birthdateView, birthdateLabel, confirmButton)
	}
	
	override func sizeChanged() {
		super.sizeChanged()
		
		let box = safeBounds
		let nameSize = nameView.intrinsicContentSize
		let captionSize = birthdateLabel.intrinsicContentSize
		let availableHeight = box.size.height - nameSize.height - captionSize.height - Layout.buttonSize.height - Layout.spacing * 3 - Layout.margin * 2
		var dateSize = birthdateView.sizeThatFits(.zero)
		
		if availableHeight > dateSize.height && birthdateView.datePickerStyle != .wheels {
			birthdateView.preferredDatePickerStyle = .wheels
			dateSize = birthdateView.sizeThatFits(.zero)
		}
		
		if availableHeight < dateSize.height && birthdateView.datePickerStyle != .compact {
			birthdateView.preferredDatePickerStyle = .compact
			dateSize = birthdateView.sizeThatFits(.zero)
		}
		
		let arrangeWidth = box.width - Layout.margin * 2
		let sizes = [nameSize.with(width:arrangeWidth), captionSize.with(width:arrangeWidth), dateSize]
		let arrageHeight = sizes.reduce(Layout.spacing * 2) { $0 + $1.height }
		let limit = box.relative(x:0.5, y:0.2, size:CGSize(width:arrangeWidth, height:arrageHeight))
		let arranged = UIView.arrangeSizes(sizes, within:limit, spacing:Layout.spacing, axis:.vertical, alignment:.center, distribution:.fill)
		let confirmFrame = box.insetBy(dx:Layout.margin, dy:Layout.margin).relative(x:0.5, y:1, size:Layout.buttonSize)
		
		nameView.frame = arranged[0]
		birthdateLabel.frame = arranged[1].offsetBy(dx:0, dy:birthdateView.datePickerStyle == .wheels ? Layout.spacing : 0)
		birthdateView.frame = arranged[2]
		confirmButton.frame = confirmFrame
		createMemberView.frame = box.relative(x:1, y:0, size:Layout.createMemberSize)
	}
	
	func applyFurniture(_ furniture:Furniture) {
		nameView.placeholder = furniture.namePlaceholder
		birthdateLabel.text = furniture.birthdateCaption
		confirmButton.setTitle(furniture.confirmButton, for:.normal)
		birthdateView.maximumDate = birthdateView.calendar?.date(byAdding:.year, value:-furniture.minimumAgeInYears, to:Date())
	}
}
