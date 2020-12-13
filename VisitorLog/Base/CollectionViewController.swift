//
//  CollectionViewController.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class CollectionViewController: BaseViewController, CollectionPresenter {
	let content:CollectionContent
	
	var viewController:UIViewController! { return self }
	var collectionView:UICollectionView! { return view as? UICollectionView }
	
	init(content:CollectionContent) {
		self.content = content
		super.init(nibName:nil, bundle:nil)
	}
	
	convenience init(sections:[CollectionManager.Section]) {
		self.init(content:CollectionManager(sections))
	}
	
	required init?(coder:NSCoder) { fatalError("init(coder:)") }
	
	override func loadView() {
		let layout = UICollectionViewFlowLayout()
		
		layout.sectionHeadersPinToVisibleBounds = true
		layout.minimumInteritemSpacing = 0
		layout.minimumLineSpacing = 0
		
		let collectionView = UICollectionView(frame:.zero, collectionViewLayout:layout)
		
		view = collectionView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		content.attachToPresenter(self)
	}
}
