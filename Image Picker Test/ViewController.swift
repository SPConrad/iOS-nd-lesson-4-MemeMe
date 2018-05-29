//
//  ViewController.swift
//  Image Picker Test
//
//  Created by Sean Conrad on 5/20/18.
//  Copyright © 2018 Sean Conrad. All rights reserved.
//

import UIKit
import AVKit
import Photos
import NotificationCenter

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    
    var textFields = [UITextField]()
    
    let memeTextFieldDelegate = MemeTextFieldDelegate()
    
    let memeTextAttributes:[String: Any] = [
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.font.rawValue: UIFont(name: "Impact", size: 50)!,
        NSAttributedStringKey.strokeWidth.rawValue: -8]
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupTextFields() {
        textFields.append(self.topText)
        textFields.append(self.bottomText)
        
        for textfield in textFields {
            textfield.delegate = memeTextFieldDelegate
            textfield.defaultTextAttributes = memeTextAttributes
            textfield.text = textfield.placeholder
            textfield.textAlignment = .center
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.isEnabled = false
        // Do any additional setup after loading the view, typically from a nib.
        
        setupTextFields()
        
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        subscribeToKeyboardNotifications()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification){
        if bottomText.isFirstResponder {
            self.view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification){
        if bottomText.isFirstResponder {
            view.frame.origin.y = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showAlert(alertString: String, message: String){
        let ac = UIAlertController(title: alertString, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func showImagePicker(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickImageFromAlbum(_ sender: Any) {
        showImagePicker(sourceType: .photoLibrary)
    }
    
    @IBAction func pickImageFromCamera(_sender: Any){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if !response {
                // camera is not enabled, tell the user to enable access
                self.showAlert(alertString: "Unable to access camera", message: "Please enable access to the camera in your settings")
            } else {
                self.showImagePicker(sourceType: .camera)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if UIDevice.current.orientation.isLandscape {
            imageView.contentMode = .scaleAspectFill
        } else {
            imageView.contentMode = .scaleAspectFit
        }
    }
    
    @IBAction func saveImage(_sender: Any){
        save()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            saveButton.isEnabled = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    func save() {
        // Create the meme
        if let originalImage = imageView.image {
            let memedImage = generateMemedImage()
            
            let imageToShare = [ memedImage ]
            
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            // exclude some activity types from the list (optional)
            activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook ]
            
            // present the view controller
            self.present(activityViewController, animated: true, completion: nil)
            
            activityViewController.completionWithItemsHandler = { activity, success, items, error in

                if success {
                    if activity?.rawValue == "com.apple.UIKit.activity.SaveToCameraRoll" {
                        let meme = Meme(topText: self.topText.text!, bottomText: self.bottomText.text!, originalImage: originalImage, finalImage: memedImage)
                        
                        self.imageView.image = nil
                        self.saveButton.isEnabled = false
                        self.topText.text = self.topText.placeholder
                        self.bottomText.text = self.bottomText.placeholder
                    }
                }
            }
        }
    }
    
    struct Meme {
        var topText: String
        var bottomText: String
        var originalImage: UIImage
        var finalImage: UIImage
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar while saving image
        toolbar.isHidden = true
        navigationController?.isToolbarHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.safeAreaLayoutGuide.layoutFrame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // TODO: Show toolbar and navbar
        toolbar.isHidden = false
        navigationController?.isToolbarHidden = false
        
        return memedImage
    }
    override func viewWillDisappear(_ animated: Bool) {
        unsubscribeFromKeyboardNotifications()
        super.viewWillDisappear(animated)
    }
    
}

