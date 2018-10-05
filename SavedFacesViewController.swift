//
//  savedFacesViewController.swift
//  Raye7Project
//
//  Created by Basma Ahmed Mohamed Mahmoud on 9/23/18.
//  Copyright © 2018 Basma Ahmed Mohamed Mahmoud. All rights reserved.
//

import UIKit

class SavedFacesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var savedImagesCollectionView: UICollectionView!
    
    // this array contains all face images detect from Clarifai
    var faceImages:[FaceImage]? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // fetch all saved Face Images with text tags from Core Data
        faceImages = DataController.fetchFaceImages()
        
        // To remove spacing between images's cells
        removeCellSpacing()
        reloadFaceImages()
    }
    
    // This function is used to remove spacinf between cells on the collection view
    func removeCellSpacing(){
        
        let itemsize = UIScreen.main.bounds.width/5 - 1
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(10, 0, 10, 0)
        layout.itemSize = CGSize(width: itemsize, height: itemsize)
        layout.minimumInteritemSpacing = 1
        layout.minimumLineSpacing = 1
        
        savedImagesCollectionView.collectionViewLayout = layout
        savedImagesCollectionView.delegate = self
        savedImagesCollectionView.dataSource = self
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "faceCell", for: indexPath) as! ImageCellCollectionViewCell
        
        if let imageData = faceImages![indexPath.row].faceTagedImage{
            cell.imageCell.image = UIImage(data: imageData)
        }
        
        savedImagesCollectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowFaceIm", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFaceIm" {
            let indexPath = savedImagesCollectionView.indexPathsForSelectedItems?[0]
            let dvc = segue.destination as! DetailViewController
            dvc.image = faceImages![(indexPath?.row)!]
        }
    }
    
}

extension SavedFacesViewController {
    func reloadFaceImages() {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        savedImagesCollectionView?.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faceImages?.count ?? 0
    }
    
}
