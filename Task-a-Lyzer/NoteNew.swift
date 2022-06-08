//
//  Notes.swift
//  Task-a-Lyzer
//
//  Created by DHC on 6/4/22.
//

import SwiftUI
import UniformTypeIdentifiers


let dateFormatter = DateFormatter()

// Codable, Hashable, Indentifable just means its chacter arrays with multi-capability. its a swift thing.
struct NoteItem: Codable, Hashable, Identifiable {
    let id: Int
    let text: String
    var date = Date()
    var dateText: String {
        dateFormatter.dateFormat = "MMM d yyyy, h:mm a"
        return dateFormatter.string(from: date)
    }
}
//using json for now between systems. might have to update to utf for export support. or make a converter function.
struct NoteNew : View {
    @State var items: [NoteItem] = {
        guard let data = UserDefaults.standard.data(forKey: "notes") else { return [] }
        if let json = try? JSONDecoder().decode([NoteItem].self, from: data) {
            return json
        }
        return []
    }()
    
    @State var taskText: String = ""
    
    @State var showAlert = false
    
    @State var itemToDelete: NoteItem?
    
    var inputView: some View {
        VStack {
            TextEditor(text: $taskText)
            Spacer()
            Button(action: didTapAddTask, label: { Text("Add") })
        }
    }
    
    var body: some View {
            inputView
    }
    
    func didTapAddTask() {
        //random id from .id
        let id = items.reduce(0) { max($0, $1.id) } + 1
        items.insert(NoteItem(id: id, text: taskText), at: 0)
        taskText = ""
        save()
    }
    
    
    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: "notes")
    }
    
    
}
