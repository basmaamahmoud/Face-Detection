# Face-Detection
How to detect faces in images using Clarifai api
# Face Detect App

- This app allows users to take a life photo using a mobile camera, "tag here" text field will appear in the middle of each face in the picture where a user can enter the name for the face he wants to save. 
- All selected faces will be stored with the original image.

## Setup
- In this application i used HTTP request.
- Core Data was used to store taken images and selected faces.
- You need to get face detect clarifai api key from "https://clarifai.com/models/face-detection-image-recognition-model-a403429f2ddf4b49b307e318f00e528b-detection"

## Description
### The app will have three view controllers scenes.
- FaceTagView View Controller: It enables the user to take photos from camera or from photo gallery if the camera is not enabled on his device.
- SavedFaces View Controller: It saves all the tagged faces that have been selected by the user from FaceTagView.
- Detail View Controller: It shows the image of the selected faces with tag names on them.
#### 1) Face Tag View.
The Face Tag view has two buttons, one for camera and one for saving faces. Camera button It allows the user to take a photo from his mobile or from photo gallery if his mobile doesn't supports camera, an image will appear with a tag here text field on each face in the image. The user will be able to tag a name on any face he wants to save.

#### 2) Saved Faces View.
It stores all the faces that have been saved by user. If the user tapped on the face, the image will appear with the tagged faces.
It has a back button where the user can go back to face tag view to take another photo.

#### 3) Detail View.
It shows the user the image with tagged faces.

#### Notes:
- You can create a frame around each frame just by changing the colour of redview subview in FaceTagViewController.
- You can change the color of tag here text field in configure function.
- Please note that this model is currently in BETA testing and may update periodically, check their website for further change.
