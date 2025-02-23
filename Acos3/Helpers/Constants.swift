//
//  Constants.swift
//  app8signIn
//
//  Created by mac on 2021/04/29.
//

import Foundation

struct Constants {
    
    struct Storyboard {
        
        static let homeViewController = "HomeVC"
    }
    
    struct Storyboard2 {
        static let tabBarController = "TabC"
    }
    
    struct Storyboard3 {
        static let OnboardController = "Onboard"
    }
    
    static let UserUpdated = "UserUpdated"
}


enum AnalysisPoint: String {
    case sensitivity = "sensitivity"
    case pore = "pore"
    case oil = "oil"
    case dry = "dry"
    case pigment = "pigment"
}
