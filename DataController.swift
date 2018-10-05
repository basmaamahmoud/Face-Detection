//
//  DataController.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/23/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
    
    class func getContext() -> NSManagedObjectContext{
        let appleDelegate = UIApplication.shared.delegate as? AppDelegate
        return (appleDelegate?.persistentContainer.viewContext)!
    }
    
    // save face images to core data
    class func saveFaceImages(faceTagedImage: Data) -> NSManagedObject{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "FaceImage",in: context)
        let faceImage = NSManagedObject(entity: entity!, insertInto: context)
        faceImage.setValue(Date(), forKey: "date")
        
        faceImage.setValue(faceTagedImage,forKey: "faceTagedImage")
        
        try? context.save()
        return faceImage
    }
    
    // save image with faces taged to core data
    class func saveImagesWithFacesTag(imageWithFacesTaged: Data) -> NSManagedObject{
        
        let context = getContext()
        let entity = NSEntityDescription.entity(forEntityName: "ImageWthFaces",in: context)
        let imageFacesTag = NSManagedObject(entity: entity!, insertInto: context)
        
        imageFacesTag.setValue(imageWithFacesTaged, forKey: "imageFacesTag")
        
        try? context.save()
        return imageFacesTag
    }
    
    // fetch face images stored in Core Data
    class func fetchFaceImages() -> [FaceImage]?{
        
        let context = getContext()
        var faceImage:[FaceImage]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FaceImage")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        do{
            faceImage = try context.fetch(fetchRequest) as? [FaceImage]
            return faceImage
        }catch{
            return faceImage
        }
    }
    
    // fetch Image with faces taged stored in Core Data
    class func fetchimagWthFaces() -> [ImageWthFaces]?{
        
        let context = getContext()
        var imageFacesWthTag:[ImageWthFaces]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ImageWthFaces")
        do{
            imageFacesWthTag = try context.fetch(fetchRequest) as? [ImageWthFaces]
            return imageFacesWthTag
        }catch{
            return imageFacesWthTag
        }
    }
    
    //delete all face images stored in core data
    class func deleteAllFacesData() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: FaceImage.fetchRequest())
        do{
            try context.execute(delete)
            return true
        }catch{
            return false
        }
    }
    //delete all images with taged faces stored in core data
    class func deleteAllImagesData() -> Bool{
        let context = getContext()
        let delete = NSBatchDeleteRequest(fetchRequest: ImageWthFaces.fetchRequest())
        do{
            try context.execute(delete)
            return true
        }catch{
            return false
        }
    }
    
    
}
