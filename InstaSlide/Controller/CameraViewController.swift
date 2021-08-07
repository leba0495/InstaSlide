//
//  CameraViewController.swift
//  InstaSlide
//
//  Created by Luis Brito on 8/6/21.
//

import UIKit
import AlamofireImage
import Parse

class CameraViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionTextField: UITextField! {
        didSet {
            captionTextField.layer.cornerRadius = 10
            captionTextField.becomeFirstResponder()
        }
    }
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.layer.cornerRadius = 10
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onSubmitButton(_ sender: Any) {
        let post = PFObject(className: "Posts")
        
        post["caption"] = captionTextField.text
        post["author"] = PFUser.current()!
        
        // Parse saves images as an url so PFObject won't support that
        let imageData = imageView.image!.pngData()
        let file = PFFileObject(name: "image.png", data: imageData!)
        post ["image"] = file
        
        post.saveInBackground { (success, error) in
            if success {
                print("Post has been saved!")
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error saving.")
            }
        }
    }
    
    @IBAction func onCamera(_ sender: Any) {
        //Quick approach to call the camera
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[.editedImage] as! UIImage
        
        //Resize the image becase of heroku upload speed
        let size = CGSize(width: 370, height: 375)
        let scaledImage = image.af.imageScaled(to: size)
        imageView.image = scaledImage
        
        //Dimiss camera view
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
