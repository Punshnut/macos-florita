import SwiftUI
import Combine

class NotesViewModel: ObservableObject {
    @Published var notes: [String] = []
    
    func addNote(_ note: String) {
        notes.append(note)
    }
    
    func removeNote(at index: Int) {
        notes.remove(at: index)
    }
    
    func clearNotes() {
        notes.removeAll()
    }
}