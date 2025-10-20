import SwiftUI

struct ContentView: View {
    @State private var noteText: String = ""

    var body: some View {
        VStack {
            Text("MacNotes")
                .font(.largeTitle)
                .padding()
            TextEditor(text: $noteText)
                .border(Color.gray, width: 1)
                .padding()
        }
        .padding()
    }
}