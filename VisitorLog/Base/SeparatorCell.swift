//
//  SeparatorCell.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class SeparatorCell: BaseCollectionViewCell, CollectionManagerSimpleCell {
	class Item: CollectionManagerSimpleItem {
		typealias Cell = SeparatorCell
		
		let model:Cell.Model
		var isSelectable:Bool { return false }
		
		init(_ model:Cell.Model = Cell.Model()) {
			self.model = model
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
		let height:CGFloat
		let color:UIColor
		
		init(color:UIColor = Theme.common.separator, height:CGFloat = 1 / UIScreen.main.scale) {
			self.height = height
			self.color = color
		}
	}
	
	static func interleave(model:Model, into items:[CollectionManagerItem]) -> [CollectionManagerItem] {
		var interleaved:[CollectionManagerItem] = []
		
		for item in items {
			interleaved.append(item)
			interleaved.append(Item(model))
		}
		
		return interleaved
	}
	
	static func size(for model:Model, size:CGSize) -> CGSize {
		return CGSize(width:size.width, height:model.height)
	}
	
	func apply(model:Model) {
		backgroundColor = model.color
	}
}
