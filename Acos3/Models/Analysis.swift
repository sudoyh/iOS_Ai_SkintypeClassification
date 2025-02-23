//
//  Analysis.swift
//  Acos3
//
//  Created by Nasrullah Khan on 02/07/2021.
//

import Foundation

import FirebaseFirestore
import CodableFirebase

struct Analysis: Codable {
    
    var id: String
    var createdBy: String
    var imageURL: String
    var sensitivity: Double
    var pore: Double
    var oil: Double
    var dry: Double
    var pigment: Double
    var createdAt: Timestamp
    var date: String? = nil
    
    static var shared: [Analysis] = [Analysis].init()
    
    init(sensitivity: Double, oil: Double, dry: Double, pore: Double, pigment: Double) {
        self.sensitivity = sensitivity
        self.oil = oil
        self.dry = dry
        self.pore = pore
        self.pigment = pigment
        self.id = ""
        self.createdBy = ""
        self.imageURL = ""
        self.createdAt = Timestamp.init(date: Date.init())
    }
    
    static func data(id: String, createdBy: String, imageURL: String, sensitivity: Double, pore: Double, oil: Double, dry: Double, pigment: Double) -> [String:Any]{
        return [
            "id" : id,
            "createdBy" : createdBy,
            "imageURL" : imageURL,
            "sensitivity" : sensitivity,
            "pore" : pore,
            "oil" : oil,
            "dry" : dry,
            "pigment" : pigment,
            "createdAt" : FieldValue.serverTimestamp(),
            ] as [String : Any]
    }

}
