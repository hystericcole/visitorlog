//
//  SignInOutCell.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class SignInOutCell: BaseCollectionViewCell, CollectionManagerSimpleCell {
	class PersonItem: CollectionManagerSimpleItem {
		typealias Cell = SignInOutCell
		
		let person:VisitorManager.Person
		var model:Cell.Model { return Cell.Model(name:person.name, date:nil) }
		var isSelectable:Bool { return true }
		
		init(_ member:VisitorManager.Person) {
			self.person = member
		}
		
		func cell(collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell {
			return cell(with:model, collectionView:collectionView, indexPath:indexPath)
		}
		
		func size(for size:CGSize) -> CGSize {
			return self.size(with:model, size:size)
		}
		
		func selected() {}
		func displaying(isDisplaying: Bool, cell: UICollectionViewCell) {}
		func sizeCategoryChanged(to category: UIContentSizeCategory) {}
	}
	
	class VisitorItem: CollectionManagerSimpleItem {
		typealias Cell = SignInOutCell
		
		let visitor:VisitorManager.Visitor
		var dateString:String { return DateFormatter.signIn.string(from:visitor.signIn) }
		var model:Cell.Model { return Cell.Model(name:visitor.person.name, date:dateString) }
		var isSelectable:Bool { return true }
		
		init(_ member:VisitorManager.Visitor) {
			self.visitor = member
		}
		
		func cell(collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell {
			return cell(with:model, collectionView:collectionView, indexPath:indexPath)
		}
		
		func size(for size:CGSize) -> CGSize {
			return self.size(with:model, size:size)
		}
		
		func selected() {}
		func displaying(isDisplaying: Bool, cell: UICollectionViewCell) {}
		func sizeCategoryChanged(to category: UIContentSizeCategory) {}
	}
	
	struct Model {
		let name:String
		let date:String?
	}
	
	struct Layout {
		static let height:CGFloat = 120
		static let margin:CGFloat = 40
		static let spacing:CGFloat = 10
		static let nameStyle = Style(font:.title, size:36, color:Theme.common.primaryText, alignment:.natural)
		static let dateStyle = Style(font:.date, size:14, color:Theme.common.primaryText, alignment:.natural)
	}
	
	let nameLabel = BaseLabel()
	let dateLabel = BaseLabel()
	
	override func prepareContent() {
		super.prepareContent()
		
		backgroundColor = Theme.common.primaryBackground
		nameLabel.applyStyle(Layout.nameStyle, minimumScale:0.5, maximumLines:2)
		dateLabel.applyStyle(Layout.dateStyle, minimumScale:0.5, maximumLines:1)
	}
	
	override func prepareHierarchy() {
		super.prepareHierarchy()
		
		contentView.addSubviews(nameLabel, dateLabel)
	}
	
	override func prepareForReuse() {
		super.prepareForReuse()
		
		nameLabel.text = nil
		dateLabel.text = nil
	}
	
	override func sizeChanged() {
		super.sizeChanged()
		
		let box = zeroBounds
		let dateSize = dateLabel.intrinsicContentSize
		
		nameLabel.frame = box.insetBy(dx:Layout.margin, dy:Layout.spacing + dateSize.height)
		dateLabel.frame = box.insetBy(dx:Layout.margin, dy:Layout.spacing).relative(x:0, y:1, size:dateSize)
	}
	
	static func size(for model:Model, size:CGSize) -> CGSize {
		return CGSize(width:size.width, height:Layout.height)
	}
	
	func apply(model:Model) {
		nameLabel.text = model.name
		dateLabel.text = model.date
	}
}
