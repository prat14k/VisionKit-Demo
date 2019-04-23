//
//  ViewController.swift
//  FaceFeatureApp
//
//  Created by Prateek Sharma on 3/7/19.
//  Copyright © 2019 Prateek Sharma. All rights reserved.
//

import UIKit
import YUGPUImageHighPassSkinSmoothing

class ViewController: UIViewController {

    @IBOutlet weak private var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filter  = YUGPUImageHighPassSkinSmoothingFilter()
        filter.amount = 0.7
        let processedImage = filter.image(byFilteringImage: UIImage(named: "mark"))
        imgView.image = processedImage
    }


}

