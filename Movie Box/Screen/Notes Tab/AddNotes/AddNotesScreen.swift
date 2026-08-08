//
//  AddNotesScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import SwiftUI

struct AddNotesScreen: View {
    @StateObject var viewModel: AddNotesViewModel
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title
        case notes
    }
    
    var body: some View {
        ZStack {
            // MARK: - 1. Fixed Background (ઝીરો મુવમેન્ટ)
            GeometryReader { geometry in
                Image("img_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            .contentShape(Rectangle())
            .onTapGesture {
                // Sirf background par tap thay tyare j keyboard dismiss thashe
                focusedField = nil
                Utility.closeKeyboard()
            }
            
            // MARK: - 2. Foreground Content
            VStack(spacing: 0) {
                // Header (Top Bar)
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
                    
                    if !viewModel.nameTextField.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                        !viewModel.notesTextEditor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        
                        Button {
                            focusedField = nil
                            Utility.closeKeyboard()
                            viewModel.onSaveButton()
                        } label: {
                            Image("ic_right")
                                .resizable()
                                .frame(width: 44, height: 44, alignment: .center)
                        }
                    } else {
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                }
                .padding(.bottom, 10)
                
                // Title Input
                TextField(
                    "",
                    text: $viewModel.nameTextField,
                    prompt: Text(Strings.noteTitle)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.whiteColour.opacity(0.2))
                )
                .font(.system(size: 30, weight: .bold))
                .focused($focusedField, equals: .title)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            TextField(
                                "",
                                text: $viewModel.notesTextEditor,
                                prompt: Text(Strings.startTyping)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundStyle(.whiteColour.opacity(0.4)),
                                axis: .vertical
                            )
                            .font(.system(size: 16, weight: .regular))
                            .focused($focusedField, equals: .notes)
                            Color.clear
                                .frame(height: 20)
                                .id("BOTTOM_MARKER")
                        }
                    }
                    .scrollDismissesKeyboard(.interactively)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        focusedField = .notes
                    }
                    .onChange(of: viewModel.notesTextEditor) { _ in
                        withAnimation(.easeOut(duration: 0.1)) {
                            proxy.scrollTo("BOTTOM_MARKER", anchor: .bottom)
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                // Bottom Action Button
                if (!viewModel.nameTextField.isEmpty || !viewModel.notesTextEditor.isEmpty) && focusedField == nil {
                    DefaultDesign.FullScreenButton(
                        name: viewModel.isEdit ? Strings.updateNote : Strings.saveNote,
                        onClick: {
                            viewModel.onSaveButton()
                        }
                    )
                    .padding(.vertical, 8)
                }
            }
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
        .foregroundColor(.whiteColour)
    }
}

#Preview {
    AddNotesScreen(viewModel: AddNotesViewModel())
}
