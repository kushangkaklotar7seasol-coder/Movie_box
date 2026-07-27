//
//  LocalizationManager.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
internal import Combine
import SwiftUI

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @AppStorage("selectedLanguage") var selectedLanguage: String = (UserdefaultManager.shared.getLanguage()?.code ?? "en") {
        didSet {
            Bundle.setLanguage(selectedLanguage)
        }
    }
    
    init() {
        Bundle.setLanguage(selectedLanguage) // set bundle correctly on cold launch too
    }
    
    func changeLanguage(languageCode: String){
        Bundle.setLanguage(languageCode)
        selectedLanguage = languageCode
    }
}

extension Bundle {
    static var localizedBundle: Bundle = Bundle.main
    
    static func setLanguage(_ language: String) {
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        localizedBundle = path.flatMap { Bundle(path: $0) } ?? Bundle.main
    }
}
