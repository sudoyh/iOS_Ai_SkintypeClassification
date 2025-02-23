//
//  User.swift
//  Acos3
//
//  Created by Nasrullah Khan on 04/07/2021.
//

import FirebaseFirestore
import CodableFirebase

struct User: Codable {
   
    var uid: String
    var email: String
    var firstname: String
    var lastname: String
    var average: Average?
    
    static var shared: User? = nil
}

struct Average: Codable {
    var sensitivity: Double
    var pore: Double
    var oil: Double
    var dry: Double
    var pigment: Double
    var latestImageURL: String
}
