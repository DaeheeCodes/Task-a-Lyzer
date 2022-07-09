//
//  ContentView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 5/30/22.
//

import SwiftUI
import Introspect
import WebKit

struct FavItem: Codable, Hashable, Identifiable {
    let id: Int
    let text: String
    var url: String

}

class ContentData: ObservableObject {
   @Published var inputURL: String = "https://"
   @Published var backDisabled: Bool = true
   @Published var forwardDisabled: Bool = true
}


struct ContentView: View {

    
    @ObservedObject var contentData = ContentData()
    var subWebView: SubWebView!
     
    init() {
       subWebView = SubWebView(inputURL: $contentData.inputURL, backDisabled: $contentData.backDisabled, forwardDisabled: $contentData.forwardDisabled)
    }
    
    @State var favItems: [FavItem] = {
        guard let data = UserDefaults.standard.data(forKey: "favorites") else { return [] }
        if let json = try? JSONDecoder().decode([FavItem].self, from: data) {
            return json
        }
        return []
    }()
    
    @State var favText: String = ""
    @State var favShowAlert = false
    @State var favItemToDelete: FavItem?
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty
    @State private var address = "google.com"
    @State private var showSafari: Bool = false

    
    
 //   @StateObject var favListVM = FavListView()

    var ratioSlider: UISlider!
    @State var size: Double = 0.6


   var body: some View {
       

       //GeometryReader for adaptive screen size for different devices. Hstack vs Vstack change to comeNSObject
       GeometryReader { gp in
           VStack {
               WebView.init( action: $action,
                       state: $state)
              .frame(width: gp.size.width, height: gp.size.height * CGFloat((size)))
          Slider(value: Binding(get: {
                     self.size
                 }, set: { (newVal) in
                     self.size = newVal
                 }))
          .accentColor(.black)
          .opacity(0.3)
          .introspectSlider { slider in
                          slider.setThumbImage(UIImage(systemName: "dot.viewfinder"), for: .normal)
                      }
    // everything is sized by global property for better scaleability.
          HStack {
                  Button(action: {
                      action = .goBack
                  }) {
                      Image(systemName: "chevron.left")
                          .imageScale(.large)
                  }
                  Button(action: {
                      action = .goForward
                  }) {
                  Image(systemName: "chevron.right")
                      .imageScale(.large)
                      
                  }

              TextField("Address", text: $address).disableAutocorrection(true)
              Menu {
                  Menu ("View Bookmark") {                          ForEach(favItems) { item in
                              Button("\(item.text)") {
                                  if let url = URL(string: item.url) {
                                      action = .load(URLRequest(url: url))
                                  }
                            }
                  }
                  }
                  Button("Add Bookmark", action: didTapAddFav
                  )
              } label: {
                  Image(systemName: "star")
              }
              Button(action: {
                  action = .reload
              }) {
                  Image(systemName: "arrow.counterclockwise")
                      .imageScale(.large)
              }
              //better user experience with https added in the address for them.
              Button("Go") {
                  if let url = URL(string: "https://" + address) {
                      action = .load(URLRequest(url: url))
                  }
            }
            .padding(.trailing, 7)
         }
         .frame(width: gp.size.width, height: gp.size.height * 0.045)
               
          NavigationView {
              VStack{
          HStack(spacing: 45.0) {
              NavigationLink(
                  destination: NoteNew(),
                  label: {
                      Image(systemName: "note.text.badge.plus")
                          .frame(width: gp.size.width * 0.12, height: gp.size.height * 0.06)
                  }).font(.system(size: 45.0))
                  .padding(.bottom, (gp.size.height > gp.size.width) ? 80 : 0)
              
              NavigationLink(
                  destination: NoteList(),
                  label: {
                      Image(systemName: "list.bullet.rectangle")
                          .frame(width: gp.size.width * 0.12, height: gp.size.height * 0.06)
                  }).font(.system(size: 45.0))
                  .padding(.bottom, (gp.size.height > gp.size.width) ? 80 : 0)
              NavigationLink(
                destination: FavListView,
                  label: {
                      Image(systemName: "bookmark.square")
                          .frame(width: gp.size.width * 0.12, height: gp.size.height * 0.06)
                  }).font(.system(size: 45.0))
                  .padding(.bottom, (gp.size.height > gp.size.width) ? 80 : 0)
              NavigationLink(
                destination: SubWebView(inputURL: $contentData.inputURL, backDisabled: $contentData.backDisabled, forwardDisabled: $contentData.forwardDisabled),
                  label: {
                      Image(systemName: "icloud")
                          .frame(width: gp.size.width * 0.12, height: gp.size.height * 0.06)
                  }).font(.system(size: 45.0))
                  .padding(.bottom, (gp.size.height > gp.size.width) ? 80 : 0)
          }
                  Link("@DaeheeCodes - Starry Fields Collective",
                        destination: URL(string: "https://StarryFields.com/")!)
                  Spacer()
          }
          }.navigationViewStyle(StackNavigationViewStyle())
      }
      .frame(width: gp.size.width, height: gp.size.height * 1)
   }
}
    func didTapAddFav() {
        //random id from .id
        let id = favItems.reduce(0) { max($0, $1.id) } + 1
        favItems.insert(FavItem(id: id, text: state.pageTitle ?? "error", url: state.pageURL ?? "error"), at: 0)
        favText = ""
        favSave()
    }
    func favSave() {
        guard let data = try? JSONEncoder().encode(favItems) else { return }
        UserDefaults.standard.set(data, forKey: "favorites")
    }
    
    func deleteFav() {
        guard let favItemToDelete = favItemToDelete else { return }
        favItems = favItems.filter { $0 != favItemToDelete }
        favSave()
    }
    
    var favAlert: Alert {
        Alert(title: Text("WARNING"),
              message: Text("Are you sure you want to delete this item?"),
              primaryButton: .destructive(Text("Delete"), action: deleteFav),
              secondaryButton: .cancel())
    }
    @State private var selection: String?
    var FavListView: some View {
        
        VStack {
            List(favItems, id: \.self, selection: $selection) { item in
                VStack(alignment: .leading) {
                    HStack {
                    Text(item.text).font(.headline).lineLimit(1)
                        Spacer()
                    Image(systemName: "delete.left")
                    }
                    Text(item.url).lineLimit(2).multilineTextAlignment(.leading)
                }
                .onTapGesture (count: 1) {
                    self.favItemToDelete = item
                    self.favShowAlert = true
                }
            }.alert(isPresented: $favShowAlert, content: {
                favAlert
            })
        }
    }
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.portrait)
    }
}

/*
 
 
 Slider(value: Binding(get: {
            self.size
        }, set: { (newVal) in
            self.size = newVal
        }))
 .accentColor(.black)
 .opacity(0.1)
 .frame(width: gp.size.width, height: gp.size.height * 0.01)
 Label {
     Text("Export")
         .foregroundColor(Color.black)
 } icon: {
     Image(systemName: "square.and.arrow.up.on.square")
         .foregroundColor(Color.blue)
 }
 
 struct CompactStack<Content>: View where Content: View {
   @Environment(\.horizontalSizeClass) var horizontalSizeClass
   let content: Content

   init(@ViewBuilder content: () -> Content) {
     self.content = content()
   }

   var body: some View {
       GeometryReader { geometry in
       if geometry.size.height > geometry.size.width {
       VStack { content }
     } else {
       HStack { content }
     }
   }
 }
 }
 */
