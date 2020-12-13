//
//  LandingPrimaryView.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class LandingPrimaryView: BaseView {
	struct Furniture {
		let banner: String
		let signIn: String
		let signOut: String
	}
	
	struct Layout {
		static let margin:CGFloat = 20
		static let spacing:CGFloat = 10
		static let bannerStyle = Style(font: .title, size: 72, color: Theme.common.primaryText, alignment: .center)
		static let buttonStyle = Style(font: .title, size: 36, color: Theme.common.primaryText, alignment: .center)
		static let numberStyle = Style(font: .number, size: 18, color: Theme.common.primaryText, alignment: .center)
	}
	
	let banner = BaseLabel()
	let visitorCount = BaseLabel()
	let signInButton = LandingButton()
	let signOutButton = LandingButton()
	var alignment: UIControl.ContentHorizontalAlignment = .center
	
	override func prepareContent() {
		super.prepareContent()
		
		banner.applyStyle(Layout.bannerStyle, minimumScale: 0.5, maximumLines: 2)
		signInButton.applyStyle(Layout.buttonStyle, minimumScale: 0.5, maximumLines: 2)
		signInButton.showsTouchWhenHighlighted = true
		signInButton.setTitleColor(Theme.common.buttonDisabled, for:.disabled)
		signOutButton.applyStyle(Layout.buttonStyle, minimumScale: 0.5, maximumLines: 2)
		signOutButton.showsTouchWhenHighlighted = true
		signOutButton.setTitleColor(Theme.common.buttonDisabled, for:.disabled)
		visitorCount.applyStyle(Layout.numberStyle, minimumScale: 0.5, maximumLines: 1)
	}
	
	override func prepareHierarchy() {
		super.prepareHierarchy()
		
		addSubviews(banner, visitorCount, signInButton, signOutButton)
	}
	
	override func sizeChanged() {
		super.sizeChanged()
		
		let box = zeroBounds.insetBy(dx:Layout.margin, dy:Layout.margin)
		let bannerSize = banner.intrinsicContentSize
		let buttonSize = min(box.height - bannerSize.height, box.size.minimum / 2)
		let centerBox = box.relative(x:0.5, y:0.4, size:CGSize(width:buttonSize * 2, height:buttonSize + bannerSize.height))
		let (upper, lower) = centerBox.divided(atDistance:bannerSize.height, from:.minYEdge)
		
		visitorCount.frame = box.relative(x:1, y:0, size:visitorCount.intrinsicContentSize)
		banner.frame = upper
		signInButton.frame = lower.cell(column:0, of:2, row:0, of:1).insetBy(dx:Layout.spacing, dy:Layout.spacing)
		signOutButton.frame = lower.cell(column:1, of:2, row:0, of:1).insetBy(dx:Layout.spacing, dy:Layout.spacing)
	}
	
	func applyFurniture(_ furniture: Furniture) {
		banner.text = furniture.banner
		signInButton.setTitle(furniture.signIn, for: .normal)
		signOutButton.setTitle(furniture.signOut, for: .normal)
	}
}
