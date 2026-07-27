//
//  LanguageViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import Foundation
internal import Combine

class LanguageViewModel: ObservableObject {
    @Published var isShowBack: Bool
    @Published var languages: [LanguageItem] = [LanguageItem(code: "en"),
                                                LanguageItem(code: "hi"),
                                                LanguageItem(code: "pt-PT"),
                                                LanguageItem(code: "it"),
                                                LanguageItem(code: "es"),
                                                LanguageItem(code: "da"),
                                                LanguageItem(code: "tr"),
                                                LanguageItem(code: "fr"),
                                                LanguageItem(code: "ja"),
                                                LanguageItem(code: "nl"),
                                                LanguageItem(code: "ko"),
                                                LanguageItem(code: "zh-Hans"),
                                                LanguageItem(code: "ru")]
    @Published var selectedLanguage: LanguageItem?
    
    init(isShowBack: Bool = true){
        self.isShowBack = isShowBack
    }
    
    // MARK: - Button Click Action -
    func onDoneButtonClick(){
        UserdefaultManager.shared.saveLanguage(self.selectedLanguage ?? LanguageItem(code: "en"))
        Router.shared.push(.intro)
    }
}
