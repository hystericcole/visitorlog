//
//  LandingViewController.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/12/20.
//

import UIKit

class LandingViewController: BaseViewController {
	var manager = VisitorManager.shared
	var dismissTimer:Timer?
	
	override func loadView() {
		view = LandingView()
	}
	
	override func viewDidLoad() {
		typealias Strings = DisplayStrings.Landing
		
		super.viewDidLoad()
		
		guard let landingView = view as? LandingView else { return }
		
		landingView.memberView.signInButton.addTarget(self, action: #selector(memberSignIn), for: .touchUpInside)
		landingView.memberView.signOutButton.addTarget(self, action: #selector(memberSignOut), for: .touchUpInside)
		landingView.guestView.signInButton.addTarget(self, action: #selector(guestSignIn), for: .touchUpInside)
		landingView.guestView.signOutButton.addTarget(self, action: #selector(guestSignOut), for: .touchUpInside)
		
		landingView.applyFurniture(LandingView.Furniture(
			member:.init(banner: Strings.memberBannerTitle, signIn: Strings.memberSignInTitle, signOut: Strings.memberSignOutTitle),
			guest:.init(banner: Strings.guestBannerTitle, signIn: Strings.guestSignInTitle, signOut: Strings.guestSignOutTitle),
			caption:Strings.caption
		))
		
		refreshVisitorState()
	}
	
	func refreshVisitorState() {
		guard let landingView = viewIfLoaded as? LandingView else { return }
		
		let (members, guests) = manager.visitorCount
		
		landingView.memberView.signInButton.isEnabled = members < manager.knownMembers.count
		landingView.memberView.signOutButton.isEnabled = members > 0
		landingView.memberView.visitorCount.text = NumberFormatter.localizedString(from:members as NSNumber, number:.none)
		landingView.guestView.signOutButton.isEnabled = guests > 0
		landingView.guestView.visitorCount.text = NumberFormatter.localizedString(from:guests as NSNumber, number:.none)
	}
	
	func timePresent(_ viewController: UIViewController, dismissAfter:TimeInterval = 120) {
		present(viewController, animated:true)
		
		if let existing = dismissTimer, existing.isValid {
			existing.fireDate = Date(timeIntervalSinceNow:dismissAfter)
		} else {
			dismissTimer = Timer.scheduledTimer(timeInterval:dismissAfter, target:self, selector:#selector(dismissTimerFired), userInfo:nil, repeats:false)
		}
	}
	
	@objc
	func dismissTimerFired() {
		dismissTimer?.invalidate()
		dismissTimer = nil
		
		guard presentedViewController != nil else { return }
		
		dismiss(animated:true)
	}
	
	@objc
	func memberSignIn() {
		let viewController = SignInOutViewController(manager:manager, action:.memberSignIn)
		
		timePresent(viewController)
	}
	
	@objc
	func memberSignOut() {
		let viewController = SignInOutViewController(manager:manager, action:.memberSignOut)
		
		timePresent(viewController)
	}
	
	@objc
	func guestSignIn() {
		let viewController = GuestSignInViewController(manager:manager)
		
		timePresent(viewController, dismissAfter:300)
	}
	
	@objc
	func guestSignOut() {
		let viewController = SignInOutViewController(manager:manager, action:.guestSignOut)
		
		timePresent(viewController)
	}
}
