//
//  Product.swift
//  Acos3
//
//  Created by Nasrullah Khan on 02/07/2021.
//

import FirebaseFirestore
import CodableFirebase

struct Product: Codable {
    
    var productId: String
    var createdBy: String
    var name: String
    var type: String
    var usingPeriod: String
    var createdAt: Timestamp
    
    static var shared: [Product] = [Product].init()

    static func data(id: String, userId: String, name: String, type: String, usingPeriod: String) -> [String:Any]{
        return [
            "productId" : id,
            "createdBy" : userId,
            "name" : name,
            "type" : type,
            "usingPeriod" : usingPeriod,
            "createdAt" : FieldValue.serverTimestamp(),
            ] as [String : Any]
    }

}
