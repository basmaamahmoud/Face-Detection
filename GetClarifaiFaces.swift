//
//  GetClarifaiFaces.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/28/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//


import Foundation
import UIKit

class GetClarifaiFaces{
    
    // Singleton instance of GetClarifaiFaces
    static let shared = GetClarifaiFaces()
    
    func createSession(image: UIImage, handler:@escaping (_ error: String?) -> Void){
        
        var request = URLRequest(url: URL(string: "https://api.clarifai.com/v2/models/a403429f2ddf4b49b307e318f00e528b/outputs")!)
        
        let imageData: Data = UIImagePNGRepresentation(image)!
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        let requestParams = [
            "inputs": [
                [
                    "data": [
                        "image": [
                            "base64": strBase64
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpMethod = "POST"
        request.addValue("Key 4fc656a810924aae83efc188db9f3d00", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONSerialization.data(withJSONObject: requestParams, options: .prettyPrinted)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
            if error != nil {
                // handel error
                handler("Connection error")
                return
            }
            
            let parsedResult: [String: AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject]
                
            } catch {
                print("Error loading data")
                return
            }
            
            guard let outputs = parsedResult["outputs"] as? [[String: AnyObject]]  else {
                handler("Error loading data")
                return
            }
            
            guard let outputs1 = outputs[0]["data"] as? [String: AnyObject] else {
                handler("Error loading data")
                return
            }
            print(outputs1)
            
            guard let outputs2 = outputs1["regions"] as? [AnyObject] else {
                handler("There is no faces in the image")
                return
            }
            
            for i in 0...outputs2.count-1{
                guard let outputs3 = outputs2[i]["region_info"] as? [String: AnyObject] else {
                    handler("Error loading data")
                    return
                }
                guard let bounding = outputs3["bounding_box"] as? [String: Double] else {
                    handler("Error loading data")
                    return
                }
                Bounding.shared.boundingBox.append(bounding)
            }
            handler(nil)
        }
        task.resume()
    }
    
}
