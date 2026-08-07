//
//  AddNotesScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import SwiftUI

struct AddNotesScreen: View {
    @StateObject var viewModel: AddNotesViewModel
    @FocusState private var isNotesFocused: Bool
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                HStack {
                    
                    Button {
                        Router.shared.pop()
                    } label: {
                        Image("ic_back")
                            .resizable()
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.isEdit ? Strings.editNotes : Strings.addNotes)
                        .font(.system(size: 18, weight: .semibold))
                    
                    Spacer()
                    
                    if viewModel.nameTextField != "" || viewModel.notesTextEditor != "" {
                        
                        if viewModel.keyboardHeight != 0 {
                            Button {
                                isNotesFocused = false
                                Utility.closeKeyboard()
                                viewModel.onSaveButton()
                            } label: {
                                Image("ic_right")
                                    .resizable()
                                    .frame(width: 44, height: 44, alignment: .center)
                            }
                        } else {
                            Image("ic_right")
                                .resizable()
                                .frame(width: 44, height: 44, alignment: .center)
                        }
                    } else {
                        Image("")
                            .resizable()
                            .frame(width: 44, height: 44, alignment: .center)
                    }
                }
                
                TextField(
                    "",
                    text: $viewModel.nameTextField,
                    prompt: Text(Strings.noteTitle)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.whiteColour.opacity(0.2))
                        .font(.subheadline)
                )
                .font(.system(size: 30, weight: .bold))
                .focused($isNotesFocused)
                
                ZStack(alignment: .topLeading) {
                    if viewModel.notesTextEditor.isEmpty {
                        Text(Strings.startTyping)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.whiteColour.opacity(0.4))
                            .padding(.top, 10)
                    }
                    
                    TextEditor(text: $viewModel.notesTextEditor)
                        .scrollContentBackground(.hidden)
                        .focused($isNotesFocused)
                }
                
//                ZStack {
//                    Color.clear
//                }
//                .frame(maxHeight: viewModel.keyboardHeight)
                
                if viewModel.nameTextField != "" || viewModel.notesTextEditor != "" {
                    if !isNotesFocused {
                        DefaultDesign.FullScreenButton(name: viewModel.isEdit ? Strings.updateNote : Strings.saveNote, onClick: {
                            viewModel.onSaveButton()
                        })
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, viewModel.keyboardHeight)
        }
        .defaultPage()
        .contentShape(Rectangle())
        .onTapGesture {
            Utility.closeKeyboard()
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
//        .toolbar {
//            ToolbarItemGroup(placement: .keyboard) {
//                Spacer()
//                
//            }
//        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

#Preview {
    AddNotesScreen(viewModel: AddNotesViewModel())
}
