//
//  CollectionManager.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/12/20.
//

import UIKit

protocol CollectionManagerItem: AnyObject {
	static func registerCells(with collectionView:UICollectionView)
	
	var isSelectable:Bool { get }
	
	func cell(collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell
	func size(for size:CGSize) -> CGSize
	func selected()
	func displaying(isDisplaying:Bool, cell:UICollectionViewCell)
	func sizeCategoryChanged(to category:UIContentSizeCategory)
}

// MARK: -

protocol CollectionManagerSource: AnyObject {
	func generateSources() -> [CollectionManager.Source]
	func registerItemsWithCollectionView(_ collectionView:UICollectionView)
}

// MARK: -

protocol CollectionManagerDelegate: AnyObject {
	func collectionView(_ collectionView:UICollectionView, selected item:CollectionManagerItem, at indexPath:IndexPath)
	func collectionView(_ collectionView:UICollectionView, created cell:UICollectionViewCell, for item:CollectionManagerItem, at indexPath:IndexPath)
	func collectionView(_ collectionView:UICollectionView, displaying cell:UICollectionViewCell, for item:CollectionManagerItem, at indexPath:IndexPath)
}

extension CollectionManagerDelegate {
	func collectionView(_ collectionView:UICollectionView, selected item:CollectionManagerItem, at indexPath:IndexPath) {}
	func collectionView(_ collectionView:UICollectionView, created cell:UICollectionViewCell, for item:CollectionManagerItem, at indexPath:IndexPath) {}
	func collectionView(_ collectionView:UICollectionView, displaying cell:UICollectionViewCell, for item:CollectionManagerItem, at indexPath:IndexPath) {}
}

// MARK: -

protocol CollectionPresenter: AnyObject, UIScrollViewDelegate {
	var collectionView:UICollectionView! { get }
	var viewController:UIViewController! { get }
}

// MARK: -

protocol CollectionContent: AnyObject {
    func attachToPresenter(_ presenter:CollectionPresenter)
    func detachFromPresenter(_ presenter:CollectionPresenter)
}

// MARK: -

protocol CollectionManagerSimpleCell: AnyObject {
	associatedtype Model
	
	static var reuseIdentifier:String { get }
	
	static func size(for model:Model, size:CGSize) -> CGSize
	
	func apply(model:Model)
}

// MARK: -

protocol CollectionManagerSimpleItem: CollectionManagerItem {
	associatedtype Cell:CollectionManagerSimpleCell
	
	var model:Cell.Model { get }
}

// MARK: -

class CollectionManager: NSObject, CollectionContent, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	var sections:[Section]
	var isCounted:Bool
	weak var delegate:CollectionManagerDelegate?
	
	init(_ sections:[Section] = []) {
		self.isCounted = false
		self.sections = sections
	}
	
	func itemAt(section sectionIndex:Int, index itemIndex:Int) -> CollectionManagerItem? {
		guard sectionIndex < sections.count else { return nil }
		
		let section = sections[sectionIndex]
		
		guard itemIndex < section.items.count else { return nil }
		
		return section.items[itemIndex]
	}
	
	func itemAt(_ indexPath:IndexPath) -> CollectionManagerItem? {
		return itemAt(section:indexPath.section, index:indexPath.item)
	}
	
	// MARK: Lifecycle
	
	static func registerItems(_ items:[CollectionManagerItem.Type], with collectionView:UICollectionView) {
		for item in items { item.registerCells(with:collectionView) }
	}
	
	static func regiaterItems(in sections:[CollectionManager.Section], with collectionView:UICollectionView) {
		var seen:[CollectionManagerItem.Type] = []
		
		for section in sections {
			for item in section.items {
				let itemType = type(of:item)
				
				guard !seen.contains(where: { $0 === itemType }) else { continue }
				
				itemType.registerCells(with:collectionView)
				seen.append(itemType)
			}
		}
	}
	
	func applySections(from source:CollectionManagerSource) {
		sections = source.generateSources().flatMap { $0.sections() }
	}
	
	func attach(to collectionView:UICollectionView, source:CollectionManagerSource?) {
		if let source = source {
			source.registerItemsWithCollectionView(collectionView)
		} else {
			CollectionManager.regiaterItems(in:sections, with:collectionView)
		}
		
		if collectionView.dataSource !== self {
			isCounted = false
			collectionView.dataSource = self
		}
		
		collectionView.delegate = self
	}
	
	// MARK: Modify
	
	func insert(section:Section, at index:Int, collectionView:UICollectionView?) {
		sections.insert(section, at:index)
		
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.insertSections(IndexSet(integer:index))
	}
	
	func replace(sectionAt index:Int, with section:Section, collectionView:UICollectionView?) {
		sections[index] = section
		
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.reloadSections(IndexSet(integer:index))
	}
	
	func reload(sectionAt index:Int, collectionView:UICollectionView?) {
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.reloadSections(IndexSet(integer:index))
	}
	
	func delete(sectionAt index:Int, collectionView:UICollectionView?) {
		sections.remove(at:index)
		
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.deleteSections(IndexSet(integer:index))
	}
	
	func insert(item:Item, at index:Int, in section:Int, collectionView:UICollectionView?) {
		if sections.isEmpty && index == 0 && section == 0 {
			insert(section:Section(items:[item]), at:section, collectionView:collectionView)
			return
		}
		
		sections[section].items.insert(item, at:index)
		
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.insertItems(at:[IndexPath(item:index, section:section)])
	}
	
	func replace(itemAt index:Int, in section:Int, with item:Item, collectionView:UICollectionView?) {
		sections[section].items[index] = item
		
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.reloadItems(at:[IndexPath(item:index, section:section)])
	}
	
	func reload(itemAt index:Int, in section:Int, collectionView:UICollectionView?) {
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.reloadItems(at:[IndexPath(item:index, section:section)])
	}
	
	func delete(itemAt index:Int, in section:Int, collectionView:UICollectionView?) {
		sections[section].items.remove(at:index)
		
		guard isCounted, let collectionView = collectionView else { return }
		
		collectionView.deleteItems(at:[IndexPath(item:index, section:section)])
	}
	
	// MARK: CollectionContent
	
	func attachToPresenter(_ presenter: CollectionPresenter) {
		guard let collectionView = presenter.collectionView else { return }
		
		attach(to:collectionView, source:nil)
	}
	
	func detachFromPresenter(_ presenter: CollectionPresenter) {
		guard let collectionView = presenter.collectionView else { return }
		
		if collectionView.dataSource === self {
			collectionView.dataSource = nil
			isCounted = false
		}
		
		if collectionView.delegate === self {
			collectionView.delegate = nil
		}
	}
	
	// MARK: UICollectionViewDataSource
	
	func numberOfSections(in collectionView:UICollectionView) -> Int {
		isCounted = true
		
		return sections.count
	}
	
	func collectionView(_ collectionView:UICollectionView, numberOfItemsInSection section:Int) -> Int {
		isCounted = true
		
		return sections[section].items.count
	}
	
	func collectionView(_ collectionView:UICollectionView, cellForItemAt indexPath:IndexPath) -> UICollectionViewCell {
		let item = sections[indexPath.section].items[indexPath.item]
		let cell = item.cell(collectionView:collectionView, indexPath:indexPath)
		
		delegate?.collectionView(collectionView, created:cell, for:item, at:indexPath)
		
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	
	func collectionView(_ collectionView:UICollectionView, shouldSelectItemAt indexPath:IndexPath) -> Bool {
		guard let item = itemAt(indexPath) else { return false }
		
		return item.isSelectable
	}
	
	func collectionView(_ collectionView:UICollectionView, didSelectItemAt indexPath:IndexPath) {
		guard let item = itemAt(indexPath) else { return }
		
		item.selected()
		
		delegate?.collectionView(collectionView, selected:item, at:indexPath)
	}
	
	func collectionView(_ collectionView:UICollectionView, willDisplay cell:UICollectionViewCell, forItemAt indexPath:IndexPath) {
		guard let item = itemAt(indexPath) else { return }
		
		item.displaying(isDisplaying:true, cell:cell)
		
		delegate?.collectionView(collectionView, displaying:cell, for:item, at:indexPath)
	}
	
	func collectionView(_ collectionView:UICollectionView, didEndDisplaying cell:UICollectionViewCell, forItemAt indexPath:IndexPath) {
		guard let item = itemAt(indexPath) else { return }
		
		item.displaying(isDisplaying:false, cell:cell)
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, sizeForItemAt indexPath:IndexPath) -> CGSize {
		guard itemAt(indexPath) != nil else { return .zero }
		
		return sections[indexPath.section].itemSize(collectionView:collectionView, indexPath:indexPath)
	}
	
	func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, insetForSectionAt section:Int) -> UIEdgeInsets {
		return sections[section].inset
	}
	
	func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, minimumInteritemSpacingForSectionAt section:Int) -> CGFloat {
		return sections[section].itemSpacing ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumInteritemSpacing ?? 0
	}
	
	func collectionView(_ collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout, minimumLineSpacingForSectionAt section:Int) -> CGFloat {
		return sections[section].lineSpacing ?? (collectionViewLayout as? UICollectionViewFlowLayout)?.minimumLineSpacing ?? 0
	}
	
	// MARK: UIScrollViewDelegate
	
	func scrollViewDidScroll(_ scrollView:UIScrollView) {
		guard let delegate = delegate as? UIScrollViewDelegate else { return }
		
		delegate.scrollViewDidScroll?(scrollView)
	}
	
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate:Bool) {
		guard let delegate = delegate as? UIScrollViewDelegate else { return }
		
		delegate.scrollViewDidEndDragging?(scrollView, willDecelerate:decelerate)
	}
	
	func scrollViewWillEndDragging(_ scrollView:UIScrollView, withVelocity velocity:CGPoint, targetContentOffset:UnsafeMutablePointer<CGPoint>) {
		guard let delegate = delegate as? UIScrollViewDelegate else { return }
		
		delegate.scrollViewWillEndDragging?(scrollView, withVelocity:velocity, targetContentOffset:targetContentOffset)
	}
	
	@available(iOS 11.0, *)
	func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
		guard let delegate = delegate as? UIScrollViewDelegate else { return }

		delegate.scrollViewDidChangeAdjustedContentInset?(scrollView)
	}
}

// MARK: -

extension CollectionManager {
	class Item: CollectionManagerItem {
		static var placeholder:String { return "-" }
		
		class func registerCells(with collectionView:UICollectionView) {
			collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier:placeholder)
		}
		
		var isSelectable:Bool { return false }
		
		func cell(collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier:Item.placeholder, for:indexPath)
			
			let sectionCount = CGFloat(collectionView.numberOfSections)
			let itemCount = CGFloat(collectionView.numberOfItems(inSection:indexPath.section))
			let sectionFraction = CGFloat(indexPath.section) + CGFloat(indexPath.item) / itemCount
			let hue = sectionFraction / sectionCount
			cell.backgroundColor = UIColor(hue:hue, saturation:0.75, brightness:0.75, alpha:1)
			
			return cell
		}
		
		func size(for size:CGSize) -> CGSize {
			return CGSize(width:size.width, height:100)
		}
		
		func selected() {}
		func displaying(isDisplaying:Bool, cell:UICollectionViewCell) {}
		func sizeCategoryChanged(to category:UIContentSizeCategory) {}
	}
	
	class Source {
		func items() -> [CollectionManagerItem] { return [] }
		func section() -> Section { return Section(items:items(), source:self) }
		func sections() -> [Section] { return [section()] }
	}
	
	class Section {
		var items:[CollectionManagerItem]
		var source:Source?
		var inset:UIEdgeInsets
		var itemSpacing:CGFloat?
		var lineSpacing:CGFloat?
		
		init(items:[CollectionManagerItem], source:Source? = nil, itemSpacing:CGFloat? = nil, lineSpacing:CGFloat? = nil) {
			self.items = items
			self.source = source
			self.inset = .zero
		}
		
		func itemSize(collectionView:UICollectionView, indexPath:IndexPath) -> CGSize {
			let size = collectionView.bounds.size.inset(by:inset)
			let innerSize = size.inset(by:collectionView.safeContentInset)
			
			return items[indexPath.item].size(for:innerSize)
		}
	}
}

// MARK: -

extension CollectionManagerSimpleItem {
	static func registerCells(with collectionView:UICollectionView) {
		collectionView.register(Cell.self, forCellWithReuseIdentifier:Cell.reuseIdentifier)
	}
	
	func cell(with model:Cell.Model, collectionView:UICollectionView, indexPath:IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier:Cell.reuseIdentifier, for:indexPath)
		
		(cell as? Cell)?.apply(model:model)
		
		return cell
	}
	
	func size(with model:Cell.Model, size:CGSize) -> CGSize {
		return Cell.size(for:model, size:size)
	}
}
