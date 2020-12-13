//
//  BaseViewController.swift
//  VisitorLog
//
//  Created by Eric Cole on 12/12/20.
//

import UIKit

class BaseViewController: UIViewController {
	override init(nibName nibNameOrNil:String?, bundle nibBundleOrNil:Bundle?) {
		super.init(nibName:nibNameOrNil, bundle:nibBundleOrNil)
		
		prepare()
	}
	
	required init?(coder:NSCoder) {
		super.init(coder:coder)
		
		prepare()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		(view as? BaseView)?.attachViewController(self)
	}
	
	func prepare() {}
}
