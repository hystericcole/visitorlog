//
//  GuestSignInViewController.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/13/20.
//

import UIKit

class GuestSignInViewController: BaseViewController {
	let visitorManager:VisitorManager
	
	init(manager:VisitorManager) {
		self.visitorManager = manager
		
		super.init(nibName:nil, bundle:nil)
		
		modalPresentationStyle = .formSheet
	}
	
	required init?(coder:NSCoder) { fatalError("init(coder:)") }
	
	override func loadView() {
		view = GuestSignInView()
	}
	
	override func viewDidLoad() {
		typealias Strings = DisplayStrings.SignIn
		
		super.viewDidLoad()
		
		guard let signInView = view as? GuestSignInView else { return }
		
		signInView.confirmButton.addTarget(self, action:#selector(confirmButtonTapped), for:.touchUpInside)
		
		signInView.applyFurniture(GuestSignInView.Furniture(
			namePlaceholder:Strings.namePlaceholder,
			birthdateCaption:Strings.birthdateCaption,
			confirmButton:Strings.confirmButton,
			minimumAgeInYears:21
		))
		
		let createMemberRecognizer = UILongPressGestureRecognizer(target:self, action:#selector(createMemberHeld))
		
		createMemberRecognizer.minimumPressDuration = 15
		signInView.createMemberView.addGestureRecognizer(createMemberRecognizer)
	}
	
	@objc
	func confirmButtonTapped() {
		guard let signInView = view as? GuestSignInView else { return }
		guard let name = signInView.nameView.text, !name.isEmpty else { return }
		
		let person = VisitorManager.Person(name:name, birthdate:signInView.birthdateView.date)
		visitorManager.signIn(person:person, isMember:false, date:Date())
		
		(presentingViewController as? LandingViewController)?.refreshVisitorState()
		presentingViewController?.dismiss(animated:true)
	}
	
	@objc
	func createMemberHeld(_ recognizer:UILongPressGestureRecognizer) {
		guard recognizer.state == .began else { return }
		guard let signInView = view as? GuestSignInView else { return }
		guard let name = signInView.nameView.text, !name.isEmpty else { return }
		
		let person = VisitorManager.Person(name:name, birthdate:signInView.birthdateView.date)
		visitorManager.createMember(person:person)
		
		(presentingViewController as? LandingViewController)?.refreshVisitorState()
		presentingViewController?.dismiss(animated:true)
	}
}
