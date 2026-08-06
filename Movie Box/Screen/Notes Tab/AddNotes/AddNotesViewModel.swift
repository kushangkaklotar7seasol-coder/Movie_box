//
//  AddNotesViewModel.swift
//  Movie Box
//
//  Created by Kushang kaklotar on 29/07/26.
//

import Foundation
import Combine

class AddNotesViewModel: ObservableObject {
    @Published var nameTextField: String = ""
    @Published var notesTextEditor: String = ""
    
    private let manager = NotesManager.shared
    
    @Published var oldNote: Notes?
    @Published var isEdit: Bool = false
    
    init(oldNote: Notes? = nil) {
        self.oldNote = oldNote
        self.isEdit = oldNote != nil
        self.nameTextField = oldNote?.name ?? ""
        self.notesTextEditor = oldNote?.notes ?? ""
    }
    
    func onSaveButton() {
        if self.nameTextField != "" || self.notesTextEditor != "" {
            if self.isEdit {
                self.editNote()
            } else {
                self.addNote()
            }
        }
    }
    
    func addNote() {
        let newNote = Notes(
            createdDate: Date(),
            editDate: Date(),
            name: self.nameTextField,
            notes: self.notesTextEditor,
            isPined: false
        )
        manager.addNote(newNote)
        Toast.shared.show(message: "Notes Added successfully!", type: .success)
        Router.shared.pop()
    }
    
    func editNote(){
        let editNotes = Notes(
            id: self.oldNote?.id ?? UUID(),
            createdDate: oldNote?.createdDate ?? Date(),
            editDate: Date(),
            name: self.nameTextField,
            notes: self.notesTextEditor,
            isPined: self.oldNote?.isPined ?? false
        )
        
        manager.updateNote(editNotes)
        Toast.shared.show(message: "Notes Update successfully!", type: .success)
        Router.shared.pop()
    }
    
}
