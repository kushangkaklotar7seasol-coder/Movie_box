//
//  AddNotesScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import SwiftUI

struct AddNotesScreen: View {
    @StateObject var viewModel: AddNotesViewModel
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                DefaultDesign.Header(name: viewModel.isEdit ? Strings.editNotes : Strings.addNotes)
                
                TextField(
                    "",
                    text: $viewModel.nameTextField,
                    prompt: Text(Strings.noteTitle)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.whiteColour.opacity(0.2))
                        .font(.subheadline)
                )
                .font(.system(size: 30, weight: .bold))
                
                ZStack(alignment: .topLeading) {
                    if viewModel.notesTextEditor.isEmpty {
                        Text(Strings.startTyping)
                            .font(.system(size: 16, weight: .regular))
                            .foregroundStyle(.whiteColour.opacity(0.4))
                            .padding(.top, 10)
                    }
                    
                    TextEditor(text: $viewModel.notesTextEditor)
                        .scrollContentBackground(.hidden)
                }
                
                DefaultDesign.FullScreenButton(name: viewModel.isEdit ? Strings.updateNote : Strings.saveNote, onClick: {
                    if viewModel.nameTextField != "" || viewModel.notesTextEditor != "" {
                        if viewModel.isEdit {
                            viewModel.editNote()
                        } else {
                            viewModel.addNote()
                        }
                    }
                })
            }
            .padding(.horizontal, 16)
        }
        .defaultPage()
        .contentShape(Rectangle())
        .onTapGesture {
            Utility.closeKeyboard()
        }
    }
}

#Preview {
    AddNotesScreen(viewModel: AddNotesViewModel())
}
