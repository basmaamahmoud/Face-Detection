//
//  FaceTagViewController.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/23/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit

class FaceTagViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet var viewImage: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var saveButtnOutlet: UIBarButtonItem!
    
    //Array to store deleted frames, that the user didnt tag it
    var frametoDelete = [CGRect]()
    // Variable for tagged image
    var faceImage: UIImage!
    var imagePicker = UIImagePickerController()
    // This array to store the boundries for each detected face
    var faceArray = [[Double]]()
    //This array to store the x,y,width and height for each face's frame in the image
    var cropedFaceArr = [CGRect]()
    var bounds: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    // Array to store all Images user saved before
    var imageeWthFace:[ImageWthFaces]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // fetch saved Images with faces and text tags from Core Data
        imageeWthFace = DataController.fetchimagWthFaces()
        
        // Here i check if this is the first time for launching the app or not, and if the device has a camera or not
        launchAppAndCamera()
        
        // Save button will be disabled until the facaces are determined on the image
        saveButtnOutlet.isEnabled = false
        
        // Get the view bounds
        bounds = view.bounds
        
        imagePicker.delegate = self
    }
    
    func launchAppAndCamera(){
        // Here i check if this is the first time for launching the app or not
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            //This line means that this is not the first time to launch the app, so saved faces view controller will open
            performSegue(withIdentifier: "SavedImages", sender: nil)
        } else {
            //This line means that this is the first time to launch the app, so camera will open or photo gallery
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            
            // check if the device has camera or not
            cameraCheck()
        }
        
    }
    // check if the device support camera or not
    func cameraCheck(){
        if UIImagePickerController.availableCaptureModes(for: .rear) == nil{
            // a gallery will appear instead of camera
            alertTheUserWithAction(title: "Warning", message: "The camera on your device is not supported, the photo gallery will be opened instead")
            //presentImagePickerWith(imagePick: imagePicker, sourceType: .photoLibrary, animated: false)
        }else{
            // camera will be activated to take photos
            presentImagePickerWith(imagePick: imagePicker, sourceType: .camera, animated: true)
        }
    }
    
    // Costumize tag here textfields
    func configure(textField: UITextField, withText text: String) -> UITextField{
        
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.textAlignment = .center
        // Here you can change the tag text color
        textField.textColor = UIColor.white
        textField.borderStyle = UITextBorderStyle.none
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.keyboardType = UIKeyboardType.default
        textField.returnKeyType = UIReturnKeyType.done
        textField.clearButtonMode = UITextFieldViewMode.whileEditing
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        // Here you can change the color of place holder text
        textField.attributedPlaceholder = NSAttributedString(string: text,
                                                             attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        return textField
    }
    
    // This function to let keyboard dissappear when we press return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // This function to move the view up according to the keyboard
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        configure(textField: textField, withText: " ")
    }
    
    // This function to return back the view down according to the keyboard were dismissed
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
    }
    
    // Image Picker Function
    func presentImagePickerWith(imagePick: UIImagePickerController, sourceType: UIImagePickerControllerSourceType, animated: Bool) {
        
        imagePick.sourceType = sourceType
        imagePick.allowsEditing = animated
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.contentMode = .scaleAspectFill
            imageView.image = pickedImage
        }
        // To start search for faces in the image
        let faceImagesent = viewImage.FaceImageSent
        Activity.shared.startActivityIndicator(view: view)
        
        // Fetch Clarifai's Face Detection
        GetClarifaiFaces.shared.createSession(image: faceImagesent!){ (error: String?) in
            DispatchQueue.main.async {
                
                guard error == nil else {
                    if error == "Error loading data"{
                        Activity.shared.stopActivityIndicator()
                        self.alertTheUser(title: "Error loading data", message: "message")
                    }else if error == "There is no faces in the image"{
                        Activity.shared.stopActivityIndicator()
                        self.alertTheUser(title: "There is no faces in the image", message: "message")
                    }else{
                        Activity.shared.stopActivityIndicator()
                        self.alertTheUser(title: "Connection Error", message: "Please check your connection")
                    }
                    return
                }
                self.recognizeImage(image: faceImagesent!)
                Activity.shared.stopActivityIndicator()
                
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // This function to recognize faces from the whole picture/image
    func recognizeImage(image: UIImage){
        // Loop through predicted faces, and save them to faceArray
        let faces = NSMutableArray()
        for face in Bounding.shared.boundingBox {
            let boundingBox = String(format:"Left: %f Right: %f, Top: %f, Bottom: %f", face["left_col"]!, face["right_col"]!, face["top_row"]!, face["bottom_row"]!)
            faces.add(boundingBox)
            // Here i add the face boundries to an array
            self.faceArray.append([face["left_col"]!, face["right_col"]!, face["top_row"]!, face["bottom_row"]!])
        }
        
        // Here i draw a frame around each face from the response boundries
        DispatchQueue.main.async {
            for i in self.faceArray{
                
                // Subview for face frame
                let redView = UIView()
                redView.layer.borderWidth = 2
                // Here you can change the color of the frame, may be you want to show it to user  so change the color
                redView.layer.borderColor = UIColor.clear.cgColor
                
                // Here i convert the boundries came from clarifai to x,y,width and height on the screen image
                let x = self.view.frame.width * CGFloat(i[0])
                let y  = self.view.frame.height * CGFloat(i[2])
                let width  = (CGFloat(i[1]) * self.view.frame.width) - (CGFloat(i[0]) * self.view.frame.width)
                let height = (CGFloat(i[3]) * self.view.frame.height) - (CGFloat(i[2]) * self.view.frame.height)
                
                redView.frame = CGRect(x: x, y: y, width: width, height: height)
                self.view.addSubview(redView)
                
                // This array to store all frames CGRect(x,y,width and height) to use it when i want to delete any frame
                self.cropedFaceArr.append(redView.frame)
                
                // Here i add a frame to text field for tag here
                let textTagToShow = self.tagText(frame: CGRect(x: x, y: y, width: width, height: height))
                self.view.addSubview(textTagToShow )
            }
            // Here i stopped activity action
            Activity.shared.stopActivityIndicator()
            // Enable save button to save the faces with tags
            self.saveButtnOutlet.isEnabled = true
        }
    }
    
    // This function for tag here text field
    func tagText(frame: CGRect) -> UITextField{
        let text = "tag here"
        let tagTextField =  UITextField(frame: frame)
        let textToReturn = configure(textField: tagTextField, withText: text)
        return textToReturn
    }
    
    func removeAllData() -> Bool{
        // Remove all previous stored frames in frame array
        frametoDelete.removeAll()
        faceArray.removeAll()
        cropedFaceArr.removeAll()
        Bounding.shared.boundingBox.removeAll()
        if frametoDelete.isEmpty && faceArray.isEmpty && cropedFaceArr.isEmpty && Bounding.shared.boundingBox.isEmpty == true{
            return true
        }else{
            return false
        }
    }
    
    // This function used for alert message
    func alertTheUser(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // This function used for alert message with action
    func alertTheUserWithAction(title: String, message: String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler:{(action)in
                //Enable photo gallery if the user pressed ok button
                self.presentImagePickerWith(imagePick: self.imagePicker, sourceType: .photoLibrary, animated: false)
            } ))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler:{(action)in
                alert.dismiss(animated: true, completion: nil)
            } ))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // This button to open camera to take pictures
    @IBAction func cameraButtn(_ sender: Any) {
        
        // Remove all previous stored frames in frame array
        removeAllData()
        
        // Here i remove all frames and tags, to be able to take another picture from camera
        for view in viewImage.subviews{
            if view != imageView{
                view.removeFromSuperview()
            }
        }
        // check if the device has camera or not, it will disable the camera button
        cameraCheck()
    }
    
    // This button to save faces croped from image to collection view
    @IBAction func saveFacesButtn(_ sender: Any) {
        
        // Here i check if the user didnt tag a name to any one from frames, and store unselected frames CGRect to an array to use it to delete unwanted frames
        for subView in view.subviews {
            
            if subView is UITextField {
                let textField = subView as! UITextField
                if textField.text == ""
                {
                    frametoDelete.append(textField.frame)
                }
            }
        }
        // Here i will remove unwanted frames from picture that the user didnt enter a tag to it.
        for view in viewImage.subviews{
            for x in frametoDelete{
                if x == view.frame{
                    view.removeFromSuperview()
                }
            }
        }
        
        // create NSData from UIImage
        guard let imageWithFacesTaged = UIImageJPEGRepresentation(viewImage.FaceImageSent!, 1) else {
            // handle failed conversion
            print("jpg error")
            return
        }
        
        // Here i save Image with framed taged faces to core data
        let y = DataController.saveImagesWithFacesTag(imageWithFacesTaged: imageWithFacesTaged)
        imageeWthFace?.append(y as! ImageWthFaces)
        
        var imageIndex = 0
        if imageeWthFace?.count != 1{
            imageIndex = (imageeWthFace?.count)!-1
        }else{
            imageIndex = 0
        }
        
        // Check if there are frames in cropedArray or not
        if cropedFaceArr.isEmpty == false{
            var  checKK = true
            for i in cropedFaceArr{
                // Here i check if any of the faces's frames is not taged and then i will not crop it
                // here i check for each frame if it is in the frametoDelete array to not crop it
                if frametoDelete.contains(i){
                    
                }else{
                    // Here i start croping frames with tags
                    let croppedCGImage = viewImage.FaceImageSent?.cgImage?.cropping(to: i)
                    let croppedImage = UIImage(cgImage: croppedCGImage!)
                    faceImage = croppedImage
                    
                    // create NSData from UIImage
                    guard let faceTagedImageData = UIImageJPEGRepresentation(faceImage, 1) else {
                        // handle failed conversion
                        print("jpg error")
                        return
                    }
                    
                    // Save faces images to core data
                    let x = DataController.saveFaceImages(faceTagedImage:faceTagedImageData)
                    // relationship between main image and faces
                    if checKK == true{
                        imageeWthFace![imageIndex].setValue(NSSet(object: x), forKey: "facesR")
                        try? imageeWthFace![imageIndex].managedObjectContext?.save()
                        checKK = false
                    }else{
                        let images = imageeWthFace![imageIndex].mutableSetValue(forKey: "facesR")
                        images.add(x)
                    }
                }
            }
        }
        performSegue(withIdentifier: "SavedImages", sender: nil)
    }
}
extension UIView {
    
    var FaceImageSent: UIImage?  {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 1.0);
        if let _ = UIGraphicsGetCurrentContext() {
            drawHierarchy(in: bounds, afterScreenUpdates: true)
            let FaceImageSent = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return FaceImageSent
        }
        return nil
    }
}
