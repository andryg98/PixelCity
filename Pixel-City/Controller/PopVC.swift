//
//  PopVC.swift
//  Pixel-City
//
//  Created by Andrea Garau on 27/10/2017.
//  Copyright © 2017 Andrea Garau. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var popImageView: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    
    var passedImage = UIImage()
    var titleImage = String()
    
    func initData(forImage image: UIImage, title: String) {
        self.passedImage = image
        self.titleImage = title
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        addDoubleTap()
        popImageView.image = passedImage
        titleLbl.text = titleImage
        
    }
    
    func addDoubleTap() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(screenWasDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        view.addGestureRecognizer(doubleTap)
    }

    
    @objc func screenWasDoubleTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
