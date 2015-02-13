//
//  HeaderCollectionViewController.swift
//  Scholarship
//
//  Created by Laurin Brandner on 13/02/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import Cartography
import ReactiveCocoa

class HeaderCollectionViewController: UICollectionViewController {

    var headerImage: UIImage?
    var defaultHeaderHeight: CGFloat = 100.0
    
    private lazy var headerView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .Center
        label.font = UIFont.systemFontOfSize(24.0)
        label.textColor = UIColor.whiteColor()
        
        return label
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton.buttonWithType(.System) as UIButton
        button.setTitle(NSLocalizedString("Back", comment: "Back"), forState: .Normal)
        
        return button
    }()
    
    // MARK: - View Lifecycle
    
    override func loadView() {
        super.loadView()
        
        self.headerView.image = self.headerImage
        self.view.addSubview(self.headerView)
        
        self.headerView.addSubview(self.titleLabel)
        // Swift bug
        constrain(self.headerView, self.titleLabel) { headerView, titleLabel in
            titleLabel.edges == headerView.edges; return
        }
        
        self.view.addSubview(self.dismissButton)
        constrain(self.view, self.headerView, self.dismissButton) { view, headerView, dismissButton in
            dismissButton.right == view.right-30
            dismissButton.top == headerView.bottom+20
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let collectionView = self.collectionView {
            collectionView.backgroundColor = UIColor.whiteColor()
            collectionView.registerClass(TopicParagraphCell.self, forCellWithReuseIdentifier: "ParagraphCell")
            collectionView.registerClass(TopicImageCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ImageCell")
            
            collectionView.contentInset = UIEdgeInsets(top: 200, left: 0.0, bottom: 0.0, right: 0.0)
            
            collectionView.rac_valuesForKeyPath("contentOffset", observer: self).subscribeNext { _ in
                let offset = collectionView.contentOffset.y
                if offset <= 0.0 {
                    let collectionViewFrame = collectionView.frame
                    self.headerView.frame = CGRect(x: 0.0, y: 0.0, width: collectionViewFrame.width, height: -offset)
                }
            }
        }
        
        self.rac_valuesForKeyPath("title", observer: self).subscribeNext { _ in
            self.titleLabel.text = self.title
        }
        
        // Swift bug
        self.dismissButton.rac_signalForControlEvents(.TouchUpInside).subscribeNext { _ in
            self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil); return
        }
    }
    
    // MARK: - Status Bar Style
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: -

}
