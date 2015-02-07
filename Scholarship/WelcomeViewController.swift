//
//  ViewController.swift
//  Scholarship
//
//  Created by Laurin Brandner on 06/02/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import Cartography
import ReactiveCocoa

class WelcomeViewController: UIViewController {

    lazy var avatarButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.redColor()
        
        button.rac_signalForControlEvents(.TouchDown).subscribeNext { _ in
            button.backgroundColor = UIColor.greenColor()
        }
        button.rac_signalForControlEvents(.TouchUpInside).subscribeNext { _ in
            button.backgroundColor = UIColor.redColor()
        }
        
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.view.addSubview(self.avatarButton)
        constrain(self.view, self.avatarButton) { view, avatarButton in
            avatarButton.width  == 100
            avatarButton.height == 100
            avatarButton.centerX == view.centerX
            avatarButton.top == view.top+50
        }
    }
    
    
    
    // MARK: -


}

