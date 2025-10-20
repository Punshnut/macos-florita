import SwiftUI

struct NoteListView: View {
    var body: some View {
        List {
            Text("Note 1")
            Text("Note 2")
            Text("Note 3")
        }
        .navigationTitle("Notes")
    }
}