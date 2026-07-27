//
//  String+Entension.swift
//  Korvani
//
//  Created by Kushang kaklotar on 10/07/26.
//

import Foundation

extension String {
    func localized() -> String {
        let loc = UserdefaultManager.shared.getLanguage()?.code ?? "en"
        let path = Bundle.main.path(forResource: loc, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }

    func localizedLan(loc: String) -> String {
        let path = Bundle.main.path(forResource: "en", ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

class Strings {
    // MARK: - Language screen -
    static var chooseLanguage: String { "CHOOSE_LANGUAGE".localized() }
    static var done: String { "DONE".localized() }
    
    // MARK: -  Intro Screen -
    static var page1Title: String { "PAGE1_TITLE".localized() }
    static var page1Info: String { "PAGE1_INFO".localized() }
    static var page2Title: String { "PAGE2_TITLE".localized() }
    static var page2Info: String { "PAGE2_INFO".localized() }
    static var page3Title: String { "PAGE3_TITLE".localized() }
    static var page3Info: String { "PAGE3_INFO".localized() }
    static var next: String { "NEXT".localized() }
    static var getStated: String { "GET_STATED".localized() }
}
