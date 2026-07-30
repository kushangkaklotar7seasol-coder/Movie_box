//
//  SearchScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 28/07/26.
//

import SwiftUI

struct SearchScreen: View {
    @StateObject var viewModel = SearchViewModel()
    @FocusState var isTextFieldFocused: Bool
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        Router.shared.pop()
                    } label: {
                        Image("ic_back")
                            .resizable()
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                    
                    Spacer()
                }
                
                SearchDesign.SearchBar(viewModel: viewModel, isTextFieldFocused: _isTextFieldFocused)
                
                CustomSegmentedControl(preselectedIndex: $viewModel.selectedIndex, options: [Strings.movie, Strings.tvShow]) { index in
                    viewModel.manageAPICalls(index: index)
                }
                
                
                let array = viewModel.selectedIndex == 0 ? viewModel.movies : viewModel.series
                
                if !array.isEmpty {
                    VStack {
                        if viewModel.selectedIndex == 0 {
                            ScrollView(showsIndicators: false) {
                                LazyVGrid(columns: columns) {
                                    ForEach(array.indices, id: \.self) { index in
                                        DefaultDesign.MovieCard(movies: array[index])
                                            .onTapGesture {
                                                Utility.closeKeyboard()
                                                viewModel.selectedMovie = array[index]
                                                viewModel.isShowmovieDetail = true
                                            }
                                            .onAppear() {
                                                self.loadMoreIfNeeded(currentItem: index)
                                            }
                                    }
                                }
                                .padding(.vertical, 20)
                            }
                            .scrollDismissesKeyboard(.immediately)
                        } else {
                            ScrollView(showsIndicators: false) {
                                
                                LazyVGrid(columns: columns) {
                                    ForEach(array.indices, id: \.self) { index in
                                        DefaultDesign.MovieCard(movies: array[index])
                                            .onTapGesture {
                                                Utility.closeKeyboard()
                                                viewModel.selectedMovie = array[index]
                                                viewModel.isShowmovieDetail = true
                                            }
                                            .onAppear() {
                                                self.loadMoreIfNeeded(currentItem: index)
                                            }
                                    }
                                }
                                .padding(.vertical, 20)
                                
                            }
                            .scrollDismissesKeyboard(.immediately)
                            
                        }
                    }
                    
                } else {
                    VStack {
                        VStack(spacing: 16) {
                            if viewModel.searchTextField.isEmpty {
                                Image("ic_search_empty_background")
                                    .resizable()
                                    .frame(width: 93, height: 120, alignment: .center)
                                
                                Text(Strings.searchMoviePlaceholder)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.whiteColour)
                                    .multilineTextAlignment(.center)
                                
                                Text(Strings.newSearchPlaceholder)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.grayColour)
                                    .multilineTextAlignment(.center)
                                
                            } else {
                                Image("ic_search_empty_background")
                                    .resizable()
                                    .frame(width: 93, height: 120, alignment: .center)
                                
                                Text(Strings.noSearchData)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.whiteColour)
                                    .multilineTextAlignment(.center)
                                
                                Text("\(Strings.noSearchDataFor) \(viewModel.searchTextField)")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.grayColour)
                                    .multilineTextAlignment(.center)
                            }
                            
                        }
                        .opacity(0.4)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(y: -viewModel.keyboardHeight / 3 - 64)
                    }
                    .frame(maxWidth: .infinity)
                }

                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .edgesIgnoringSafeArea(.bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture {
            isTextFieldFocused = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                    if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                        withAnimation(.easeOut(duration: 0.25)) {
                            viewModel.keyboardHeight = keyboardFrame.height
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation(.easeOut(duration: 0.25)) {
                        viewModel.keyboardHeight = 0
                    }
                }
    }
    
    func loadMoreIfNeeded(currentItem: Int) {
        if viewModel.selectedIndex == 0 {
            guard !viewModel.isLoading, currentItem == viewModel.movies.count - 5 else { return }
            viewModel.moviesSearchAPI(text: viewModel.searchTextField, isFromPagination: true)
        } else {
            guard !viewModel.isLoading, currentItem == viewModel.series.count - 5 else { return }
            viewModel.searchSeriesAPI(text: viewModel.searchTextField, isFromPagination: true)
        }
    }
}

#Preview {
    SearchScreen()
}

class SearchDesign {
    
    struct SearchBar: View {
        @StateObject var viewModel: SearchViewModel
        @FocusState var isTextFieldFocused: Bool
        
        var body: some View {
            HStack {
                Image("ic_search_empty")
                    .resizable()
                    .frame(width: 16, height: 16, alignment: .center)
                    .padding(.leading, 18)
                
                TextField(
                    "",
                    text: $viewModel.searchTextField,
                    prompt: Text(Strings.searchMoviePlaceholder)
                        .foregroundStyle(.whiteColour.opacity(0.7))
                        .font(.subheadline)
                )
                .frame(height: 50)
                .focused($isTextFieldFocused)
                .overlay(
                    HStack {
                        Spacer()
                        if !viewModel.searchTextField.isEmpty {
                            Button(action: {
                                self.viewModel.searchTextField = ""
                                viewModel.movies = []
                                viewModel.series = []
                                viewModel.moviesResponse = nil
                                viewModel.seriesResponse = nil
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
            }
            .frame(maxWidth: .infinity)
            .background(.backgroundColour)
            .cornerRadius(25)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.whiteColour.opacity(0.5), lineWidth: 0.5)
            )

        }
    }
}
