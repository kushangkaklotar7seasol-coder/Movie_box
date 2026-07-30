//
//  PinedNotesScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import SwiftUI

struct PinedNotesScreen: View {
    @StateObject var viewModel = PinedNotesViewModel()
    
    var body: some View {
        ZStack {
            VStack {
                DefaultDesign.Header(name: Strings.pinnedNotes)
                    .padding(.horizontal, 16)
                
                PinedNotesDesign.NotesGridView(viewModel: viewModel)
            }
        }
        .defaultPage()
        .onAppear() {
            viewModel.loadNotes()
        }
        .alert(Strings.deleteNotes, isPresented: $viewModel.isShowDeleteAlert) {
            Button(Strings.no, role: .cancel) { }
            
            Button(Strings.delete) {
                viewModel.deleteNote(viewModel.deletableNotesId)
            }
        } message: {
            Text(Strings.deleteInfo)
        }
    }
}

#Preview {
    PinedNotesScreen()
}

class PinedNotesDesign {
    struct NotesGridView: View {
     
        @ObservedObject var viewModel: PinedNotesViewModel
     
        var body: some View {
            ScrollView(showsIndicators: false) {
                MasonryVGrid(
                    data: viewModel.allNotes,
                    columns: 2,
                    spacing: 16,
                    estimatedHeight: estimatedCardHeight
                ) { note in
                    noteCard(for: note)
                        .onTapGesture {
                            Router.shared.push(.addNote(notes: note))
                        }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 170)
            }
        }
     
        // MARK: - Card
        private func noteCard(for notes: Notes) -> some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(notes.createdDate.formatted(.dateTime.day().month()))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.greenColour)
                    
                    Spacer()
                    
                    if notes.isPined {
                        Image("ic_pin_fill")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .center)
                    }
                    
                    
                    Menu {
                        if notes.isPined {
                            Button {
                                viewModel.editNote(Notes(id: notes.id,
                                                         createdDate: notes.createdDate,
                                                         editDate: notes.editDate,
                                                         name: notes.name,
                                                         notes: notes.notes,
                                                         isPined: false))
                            } label: {
                                HStack {
                                    Image("ic_unpin")
                                        .resizable()
                                        .frame(width: 10, height: 10, alignment: .center)
                                    
                                    Text(Strings.unPin)
                                }
                            }
                        } else {
                            Button {
                                viewModel.editNote(Notes(id: notes.id,
                                                         createdDate: notes.createdDate,
                                                         editDate: notes.editDate,
                                                         name: notes.name,
                                                         notes: notes.notes,
                                                         isPined: true))
                            } label: {
                                HStack {
                                    Image("ic_pin")
                                        .resizable()
                                        .frame(width: 10, height: 10, alignment: .center)
                                    
                                    Text(Strings.pin)
                                }
                            }
                        }
                        
                        Button {
                            Utility.shareText(viewModel.shareText(notes))
                        } label: {
                            HStack {
                                Image("ic_share_clear")
                                    .resizable()
                                    .frame(width: 10, height: 10, alignment: .center)
                                
                                Text(Strings.share)
                            }
                        }
                        
                        Button {
                            viewModel.deletableNotesId = notes.id
                            viewModel.isShowDeleteAlert = true
                        } label: {
                            HStack {
                                Image("ic_delete")
                                    .resizable()
                                    .frame(width: 10, height: 10, alignment: .center)
                                
                                Text(Strings.delete)
                            }
                        }
                        
                    } label: {
                        Image("ic_more")
                            .resizable()
                            .frame(width: 25, height: 25, alignment: .center)
                    }
                }
                
                if notes.name != "" {
                    Text(notes.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.whiteColour)
                    .padding(.top, 6)
                }
                
                if notes.notes != "" {
                    Text(notes.notes)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.grayColour)
                        .padding(.top, 6)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.backgroundColour.opacity(0.5))
            .cornerRadius(24)
            .overlay {
                RoundedRectangle(cornerRadius: 24)
                    .strokeBorder(.greenColour.opacity(0.2))
            }
        }
     
        // MARK: - Height estimate
     
        /// Rough character-count-based height guess, used only until the real
        /// height is measured. This just reduces the visible "reflow" on first
        /// appearance — it does not need to be precise.
        private func estimatedCardHeight(for notes: Notes) -> CGFloat {
            let baseHeight: CGFloat = 90          // date line + title + padding
            let charsPerLine: CGFloat = 28        // rough fit for font size 17 in a half-width column
            let lineHeight: CGFloat = 22
     
            let lineCount = ceil(CGFloat(notes.notes.count) / charsPerLine)
            return baseHeight + max(lineCount, 1) * lineHeight
        }
    }
}
