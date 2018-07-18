//
//  PhotoViewController.swift
//  Danger_Zone
//
//  Created by Arun Ram on 7/17/18.
//  Copyright © 2018 Arun Ram. All rights reserved.

import UIKit

class PhotoViewController: UIViewController {
    
    var takenPhoto:UIImage?
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let availableImage = takenPhoto {
            imageView.image = availableImage
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
