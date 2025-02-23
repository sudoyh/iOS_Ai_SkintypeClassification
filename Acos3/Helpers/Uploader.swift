//
//  Uploader.swift
//  Acos3
//
//  Created by Nasrullah Khan on 02/07/2021.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Uploader {
    static let storage = Storage.storage().reference()
    
    static func uploadImage(image : UIImage, path : String,completion : @escaping (_ url: String?) -> Void){
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            UIApplication.showError(message: "Select Image")
            completion(nil)
            return
        }
        let ref = storage.child(path)
        
        let _ = ref.putData(data, metadata: nil) { (metadata, error) in
          guard let _ = metadata else {
            completion(nil)
            UIApplication.showError(message: error!.localizedDescription)
            return
          }
          
          ref.downloadURL { (url, error) in
            guard let downloadURL = url else {
                completion(nil)
                UIApplication.showError(message: error!.localizedDescription)
                return
            }
            completion(downloadURL.absoluteString)
          }
            
        }
    }
}
