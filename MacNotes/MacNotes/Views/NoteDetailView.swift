import SwiftUI

struct NoteDetailView: View {
    var note: String

    var body: some View {
        VStack {
            Text("Note Detail")
                .font(.title)
                .padding()
            Text(note)
                .padding()
        }
        .padding()
    }
}