//
//  bounding.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/28/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import Foundation

class Bounding {
    var boundingBox = [[String: Double]]()
    
    //Return the singleton instance of Storage
    class var shared: Bounding {
        struct Static {
            static let instance: Bounding = Bounding()
        }
        return Static.instance
    }
}
