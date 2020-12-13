//
//  LandingView.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class LandingView: BaseView {
	struct Furniture {
		let member:LandingPrimaryView.Furniture
		let guest:LandingPrimaryView.Furniture
		let caption:String
	}
	
	struct Layout {
		static let captionStyle = Style(font: .title, size: 18, color: Theme.common.primaryText, alignment: .center)
	}
	
	let memberView = LandingPrimaryView()
	let guestView = LandingPrimaryView()
	let captionLabel = BaseLabel()
	
	override func prepareView() {
		super.prepareView()
		
		backgroundColor = Theme.common.primaryBackground
	}
	
	override func prepareContent() {
		super.prepareContent()
		
		memberView.backgroundColor = Theme.common.memberBackground
		guestView.backgroundColor = Theme.common.guestBackground
		
		captionLabel.applyStyle(Layout.captionStyle, minimumScale:0.5, maximumLines:2)
	}
	
	override func prepareHierarchy() {
		super.prepareHierarchy()
		
		addSubviews(memberView, guestView, captionLabel)
	}
	
	override func sizeChanged() {
		super.sizeChanged()
		
		let box = safeBounds
		let (column, row):(CGFloat, CGFloat) = box.size.width > box.size.height ? (1, 0) : (0, 1)
		
		memberView.frame = box.cell(column:0, of:1 + column, row:0, of:1 + row)
		guestView.frame = box.cell(column:0 + column, of:1 + column, row:0 + row, of:1 + row)
		captionLabel.frame = box.insetBy(dx:20, dy:20).relative(x:0.5, y:1, size:captionLabel.intrinsicContentSize)
	}
	
	func applyFurniture(_ furniture: Furniture) {
		memberView.applyFurniture(furniture.member)
		guestView.applyFurniture(furniture.guest)
		captionLabel.text = furniture.caption
	}
}
