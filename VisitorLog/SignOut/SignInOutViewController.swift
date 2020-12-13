//
//  SignInOutViewController.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class SignInOutViewController: CollectionViewController, CollectionManagerDelegate {
	enum Action {
		case memberSignIn, memberSignOut, guestSignOut
	}
	
	let visitorManager:VisitorManager
	let action:Action
	
	init(manager:VisitorManager, action:Action) {
		self.visitorManager = manager
		self.action = action
		
		let items:[CollectionManagerItem]
		
		switch action {
		case .memberSignIn:
			let members = manager.membersToSignIn().sorted { $0.name.caseInsensitiveCompare($1.name).rawValue < 0 }
			items = members.map(SignInOutCell.PersonItem.init)
		case .memberSignOut:
			let members = manager.membersToSignOut().sorted { $0.person.name.caseInsensitiveCompare($1.person.name).rawValue < 0 }
			items = members.map(SignInOutCell.VisitorItem.init)
		case .guestSignOut:
			let guests = manager.guestsToSignOut().sorted { $0.person.name.caseInsensitiveCompare($1.person.name).rawValue < 0 }
			items = guests.map(SignInOutCell.VisitorItem.init)
		}
		
		let section = CollectionManager.Section(items:SeparatorCell.interleave(model:SeparatorCell.Model(), into:items))
		let collectionManager = CollectionManager([section])
		
		super.init(content:collectionManager)
		
		collectionManager.delegate = self
	}
	
	required init?(coder:NSCoder) { fatalError("init(coder:)") }
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		guard let collectionView = view as? UICollectionView else { return }
		
		collectionView.backgroundColor = Theme.common.primaryBackground
	}
	
	func collectionView(_ collectionView:UICollectionView, selected item:CollectionManagerItem, at indexPath:IndexPath) {
		switch item {
		case let item as SignInOutCell.PersonItem:
			visitorManager.signIn(person:item.person, isMember:true, date:Date())
		case let item as SignInOutCell.VisitorItem:
			visitorManager.signOut(visitor:item.visitor, date:Date())
		default:
			break
		}
		
		(presentingViewController as? LandingViewController)?.refreshVisitorState()
		presentingViewController?.dismiss(animated:true)
	}
}
