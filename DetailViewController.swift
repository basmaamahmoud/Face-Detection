//
//  EditingViewController.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/23/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    // croped face received from saved view controller
    var image: FaceImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(data: (image.imageR?.imageFacesTag)!)
        
    }
}
