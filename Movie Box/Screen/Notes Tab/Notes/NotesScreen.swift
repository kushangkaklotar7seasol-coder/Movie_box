//
//  NotesScreen.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 24/07/26.
//

import SwiftUI

struct NotesScreen: View {
    @StateObject var viewModel = NotesViewModel()
    @EnvironmentObject var localization: LocalizationManager
    let columns = [
       GridItem(.flexible()),
       GridItem(.flexible())
   ]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text(Strings.notes)
                        .font(.system(size: 22, weight: .semibold))
                    Spacer()
                    
                    Button {
                        Router.shared.push(.liked)
                    } label: {
                        DefaultDesign.SmallButton(image: "ic_pin", onClick: {
                            Router.shared.push(.pinedNotes)
                        })
                    }
                }
                .padding(.horizontal, 16)
                
                NotesGridView(viewModel: viewModel)
                    .id(localization.selectedLanguage)
                
                Spacer()
            }
            .id(localization.selectedLanguage)
            
            
            VStack {
                Spacer()
                
                Button {
                    Router.shared.push(.addNote(notes: nil))
                } label: {
                    HStack {
                        Image("ic_add")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                        
                        Text(Strings.addNotes)
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [.cyanColour, .greenColour], startPoint: .top, endPoint: .bottom)
                    )
                    .cornerRadius(14)
                }
            }
            .padding(.bottom, 110)
            
            if viewModel.allNotes.isEmpty {
                VStack(spacing: 10) {
                    Image("ic_nonotes")
                    
                    Text(Strings.noNotes)
                    
                    Text(Strings.noNotesInfo)
                        .padding(.horizontal, 20)
                        .foregroundColor(.grayColour)
                }
                .multilineTextAlignment(.center)
            }
            
        }
        .defaultPage(false)
        .id(localization.selectedLanguage)
        .edgesIgnoringSafeArea(.bottom)
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
    NotesScreen()
}

struct NotesGridView: View {
 
    @ObservedObject var viewModel: NotesViewModel
 
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
                            Utility.addHaptics()
                            
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
                            Utility.addHaptics()
                            
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
                    .frame(maxHeight: screenHeight/2)
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
