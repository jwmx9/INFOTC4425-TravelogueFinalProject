//
//  NewEntryViewController.swift
//  TravelogueFinal
//
//  Created by John Williams III on 7/26/19.
//  Copyright © 2019 John Williams III. All rights reserved.
//

import UIKit

class AddEntryViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var entryDatePicker: UIDatePicker!
    
    var entry: Entry?
    var trip: Trip?
    var image: UIImage?
    var date: Date?
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = ""
        
        contentTextView.layer.borderWidth = 1.0
        contentTextView.layer.borderColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0).cgColor
        contentTextView.layer.cornerRadius = 6.0
        
        if let entry = entry {
            let name = entry.title
            titleTextField.text = name
            contentTextView.text = entry.content
            title = name
            entryDatePicker.date = entry.modifiedDate!
            image = entry.imageModified
            entryImageView.image = image
        } else {
            titleTextField.text = ""
            contentTextView.text = ""
            entryImageView.image = nil
        }
        
        date = entryDatePicker.date
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectImage() {
        let alert = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            (alertAction) in
            self.useCamera()
        }))
        alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: {
            (alertAction) in
            self.useLibrary()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func useCamera() {
        if (!UIImagePickerController.isSourceTypeAvailable(.camera)) {
            alertNotifyUser(message: "No camera detected.")
            return
        }
        
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func useLibrary() {
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        defer {
            imagePickerController.dismiss(animated: true, completion: nil)
        }
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        image = selectedImage
        entryImageView.image = image
        if let entry = entry {
            entry.imageModified = selectedImage
        }
    }
    
    func alertNotifyUser(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let name = titleTextField.text else {
            alertNotifyUser(message: "Entry not accessible.")
            return
        }
        
        let entryName = name.trimmingCharacters(in: .whitespaces)
        if (entryName == "") {
            alertNotifyUser(message: "Name is required.")
            return
        }
        
        let content = contentTextView.text
        
        if entry == nil {
            if let trip = trip {
                entry = Entry(title: entryName, content: content, date: date ?? Date(timeIntervalSinceNow: 0), image: image, trip: trip)
            }
        } else {
            if let trip = trip {
                entry?.update(title: entryName, content: content, date: date!, image: image, trip: trip)
            }
        }
        
        if let entry = entry {
            do {
                let managedContext = entry.managedObjectContext
                try managedContext?.save()
            } catch {
                alertNotifyUser(message: "Error occured saving context.")
            }
        } else {
            alertNotifyUser(message: "Error! Entity could not be created.")
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        title = titleTextField.text
    }
    
    @IBAction func selectImage(_ sender: Any) {
        selectImage()
    }
    
    @IBAction func dateChanged(_ sender: Any) {
        date = entryDatePicker.date
    }
    
}
