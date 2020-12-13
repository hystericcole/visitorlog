//
//  UIViewExtensions.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

extension UIView {
	var zeroBounds: CGRect { return CGRect(origin:.zero, size:bounds.size) }
	var safeBounds: CGRect { return CGRect(origin:.zero, size:bounds.size).inset(by:safeAreaInsets) }
	
	func addSubviews(_ views:UIView...) {
		for view in views {
			addSubview(view)
		}
	}
}

extension UICollectionView {
	func dequeueReusableCell<T:BaseCollectionViewCell>(_ indexPath:IndexPath) -> T {
		return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for:indexPath) as! T
	}
}

extension UIScrollView {
	public var safeContentInset:UIEdgeInsets {
		if #available(iOS 11.0, *) {
			return adjustedContentInset
		} else {
			return contentInset
		}
	}
}

extension UIEdgeInsets {
	init(uniform:CGFloat) {
		self.init(top:uniform, left:uniform, bottom:uniform, right:uniform)
	}
	
	init(vertical:CGFloat, horizontal:CGFloat) {
		self.init(top:vertical, left:horizontal, bottom:vertical, right:horizontal)
	}
}
