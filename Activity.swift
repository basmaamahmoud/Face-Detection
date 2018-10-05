//
//  Activity.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/25/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import Foundation
import UIKit

var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

class Activity {
    
    static let shared = Activity()
    
    func startActivityIndicator(view: UIView){
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.white
        activityIndicator.startAnimating()
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopActivityIndicator(){
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
}
