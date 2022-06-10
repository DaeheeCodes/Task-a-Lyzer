//
//  NoteList.swift
//  Task-a-Lyzer
//
//  Created by DHC on 6/4/22.
//

import SwiftUI
import UniformTypeIdentifiers

struct MessageDocument: FileDocument {
    
    static var readableContentTypes: [UTType] { [.plainText] }

    var message: String

    init(message: String) {
        self.message = message
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: .utf8)!)
    }
    
}

struct NoteList : View {
    @State private var isShowingPopover: Bool = false

    
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
    
    var alert: Alert {
        Alert(title: Text("WARNING"),
              message: Text("Are you sure you want to delete this item?"),
              primaryButton: .destructive(Text("Delete"), action: deleteNote),
              secondaryButton: .cancel())
    }
    @State private var document: MessageDocument = MessageDocument(message: "Error")
    @State  var fullText: String = ""

    @State  var showExporter: Bool = false
    var body: some View {
        VStack {
            List(items) { item in
                VStack(alignment: .leading) {
                    HStack {
                    Text(item.dateText).font(.headline)
                        Spacer()
                    Image(systemName: "delete.left").foregroundColor(.red)
                            .onTapGesture (count: 1) {
                                self.itemToDelete = item
                                self.showAlert = true
                            }
                    }
                    Text(item.text).lineLimit(2).multilineTextAlignment(.leading)
                    HStack {
                        Text("View More").font(.headline).foregroundColor(.blue).onTapGesture (count: 1) {
                            self.fullText = item.text
                        self.isShowingPopover = true
                    }
                        Spacer()
                        Button(action: {
                        self.document.message = item.text
                        self.showExporter = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .imageScale(.large)
                    }}.sheet(isPresented: self.$isShowingPopover) {
                    HStack {
                    Text(fullText)
                    }
                }
            }
                
            }
            .alert(isPresented: $showAlert, content: {
                alert
            })
        }.fileExporter(
            isPresented: $showExporter,
            document: document,
            contentType: .plainText,
            defaultFilename: "Message"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
    }
    

    
    func didTapAddTask() {
        let id = items.reduce(0) { max($0, $1.id) } + 1
        items.insert(NoteItem(id: id, text: taskText), at: 0)
        taskText = ""
        save()
    }
    
    func deleteNote() {
        guard let itemToDelete = itemToDelete else { return }
        items = items.filter { $0 != itemToDelete }
        save()
    }
    
    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        UserDefaults.standard.set(data, forKey: "notes")
    }
    
    func didTapEditTask() {
        //random id from .id
        let id = items.reduce(0) { max($0, $1.id) } + 1
        items.insert(NoteItem(id: id, text: taskText), at: 0)
        taskText = ""
        save()
    }
}
