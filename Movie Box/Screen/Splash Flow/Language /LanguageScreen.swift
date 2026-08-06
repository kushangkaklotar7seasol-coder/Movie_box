//
//  LanguageScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI

struct LanguageScreen: View {
    @StateObject var viewModel: LanguageViewModel
    @EnvironmentObject var localization: LocalizationManager
    @Environment(\.dismiss) var dismiss
    let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    if viewModel.isShowBack {
                        Button {
                            self.dismiss()
                        } label: {
                            Image("ic_back")
                                .resizable()
                                .frame(width: 44, height: 44, alignment: .center)
                        }
                    }
                    
                    Text(Strings.chooseLanguage)
                        .font(.system(size: 22, weight: .semibold))
                    
                    Spacer()
                    
                    Button {
                        localization.changeLanguage(languageCode: viewModel.selectedLanguage?.code ?? "en")
                        viewModel.onDoneButtonClick()
                    } label: {
                        Text(Strings.done)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .font(.system(size: 14, weight: .semibold))
                            .background(
                                LinearGradient(colors: [.skyBlue, .greenColour], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(30)
                    }
                }
                .padding(.top, 1)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(viewModel.languages, id: \.id) { language in
                            
                            HStack(spacing: 10){
                                VStack(alignment: .leading) {
                                    Text("\(language.code)")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.greenColour)
                                        .textCase(.uppercase)
                                    
                                    Text(language.subTitle)
                                        .foregroundColor(.whiteColour)
                                    
                                    Text("\(language.title)")
                                        .foregroundColor(.grayColour)
                                        .font(.system(size: 12))
                                }
                                .padding(.leading, 14)
                                
                                Spacer()
                                
                                VStack {
                                    Spacer()
                                    
                                    Image(viewModel.selectedLanguage?.code == language.code ? "ic_check" : "ic_uncheck")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                .padding(6)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(
                                LinearGradient( colors: [viewModel.selectedLanguage?.code == language.code ? .skyBlue.opacity(0.2) : .backgroundColour, viewModel.selectedLanguage?.code == language.code ? .greenColour.opacity(0.2) : .backgroundColour],startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(10)
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(
                                        LinearGradient( colors: [viewModel.selectedLanguage?.code == language.code ? .skyBlue : .backgroundColour, viewModel.selectedLanguage?.code == language.code ? .greenColour : .backgroundColour],startPoint: .topLeading, endPoint: .bottomTrailing),
                                        lineWidth: 2
                                    )
                            }
                            .onTapGesture {
                                viewModel.selectedLanguage = language
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .defaultPage(viewModel.isShowBack)
        .onAppear {
            viewModel.selectedLanguage = UserdefaultManager.shared.getLanguage() ?? LanguageItem(code: "en")
        }
    }
}

#Preview {
    LanguageScreen(viewModel: LanguageViewModel())
}
