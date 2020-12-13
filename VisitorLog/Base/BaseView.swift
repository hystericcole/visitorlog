//
//  BaseView.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class BaseView: UIView {
	var priorSize:CGSize = .zero
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		
		prepare()
	}
	
	required init?(coder:NSCoder) {
		super.init(coder:coder)
		
		prepare()
	}
	
	func prepare() {
		prepareView()
		prepareContent()
		prepareHierarchy()
		prepareLayout()
	}
	
	func prepareView() {}
	func prepareContent() {}
	func prepareHierarchy() {}
	func prepareLayout() {}
	
	func attachViewController(_ viewController:UIViewController) {}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let size = bounds.size
		
		if size != priorSize {
			sizeChanged()
			priorSize = size
		}
	}
	
	func sizeChanged() {}
	func invalidateLayout() { priorSize = .zero }
}

class BaseLabel: UILabel {
	override init(frame:CGRect) {
		super.init(frame:frame)
		
		prepare()
	}
	
	required init?(coder:NSCoder) {
		super.init(coder:coder)
		
		prepare()
	}
	
	func prepare() {}
}

class BaseButton: UIButton {
	override init(frame:CGRect) {
		super.init(frame:frame)
		
		prepare()
	}
	
	required init?(coder:NSCoder) {
		super.init(coder:coder)
		
		prepare()
	}
	
	func prepare() {}
}

class BaseCollectionViewCell: UICollectionViewCell {
	class var reuseIdentifier: String { return "cell.\(self)" }
	
	var priorSize:CGSize = .zero
	
	override init(frame:CGRect) {
		super.init(frame:frame)
		
		prepare()
	}
	
	required init?(coder:NSCoder) {
		super.init(coder:coder)
		
		prepare()
	}
	
	func prepare() {
		prepareView()
		prepareContent()
		prepareHierarchy()
		prepareLayout()
	}
	
	func prepareView() {}
	func prepareContent() {}
	func prepareHierarchy() {}
	func prepareLayout() {}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let size = bounds.size
		
		if size != priorSize {
			sizeChanged()
			priorSize = size
		}
	}
	
	func sizeChanged() {}
	func invalidateLayout() { priorSize = .zero }
}
