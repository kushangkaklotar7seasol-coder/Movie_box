//
//  SettingScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI

struct SettingScreen: View {
    @StateObject var viewModel = SettingViewModel()
    @EnvironmentObject var localization: LocalizationManager
    
    var body: some View {
        ZStack {
            VStack {
                Text(Strings.setting)
                    .font(.system(size: 22, weight: .semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.settingItem, id: \.id) { item in
                            HStack {
                                Image(item.value)
                                    .resizable()
                                    .frame(width: 24, height: 24, alignment: .center)
                                
                                Text(item.name.localized())
                                
                                Spacer()
                            }
                            .padding()
                            .background(.backgroundColour)
                            .cornerRadius(30)
                            .overlay {
                                RoundedRectangle(cornerRadius: 30)
                                    .strokeBorder(.greenColour.opacity(0.2))
                            }
                            .onTapGesture {
                                viewModel.onSelect(item.id)
                            }
                        }
                    }
                    .padding(.top)
                }
                .id(localization.selectedLanguage)
                
            }
            .padding(.horizontal, 16)
        }
        .defaultPage(false)
        .id(localization.selectedLanguage)
    }
}

#Preview {
    SettingScreen()
}
