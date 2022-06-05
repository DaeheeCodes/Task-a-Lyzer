//
//  ContentView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 5/30/22.
//

import SwiftUI
import Introspect
import WebKit
import SwiftUIWebView

//observableobject vs observed, in swift we do not have to declare on change though. 
class ContentData: ObservableObject {
   @Published var inputURL: String = ""
   @Published var backDisabled: Bool = true
   @Published var forwardDisabled: Bool = true
    
    
}


struct ContentView: View {

    // use states like react
    @State private var action = WebViewAction.idle
    @State private var state = WebViewState.empty
    @State private var address = "https://www.google.com"
    
    var ratioSlider: UISlider!
    @State var size: Double = 0.7


   var body: some View {
       
       
       //GeometryReader for adaptive screen size for different devices. Hstack vs Vstack change to comeNSObject
       GeometryReader { gp in
           VStack {
               WebView.init(config: WebViewConfig.init(allowsInlineMediaPlayback:true), action: $action,
                       state: $state,
                       restrictedPages: [])
              .frame(width: gp.size.width, height: gp.size.height * CGFloat((size)))
          Slider(value: Binding(get: {
                     self.size
                 }, set: { (newVal) in
                     self.size = newVal
                 }))
          .accentColor(.black)
          .opacity(0.3)
          .introspectSlider { slider in
                          slider.setThumbImage(UIImage(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"), for: .normal)
                      }
    // everything is sized by global property for better scaleability.
          HStack {
              if state.canGoBack {
                  Button(action: {
                      action = .goBack
                  }) {
                      Image(systemName: "chevron.left")
                          .imageScale(.large)
                  }
              }
              if state.canGoForward {
                  Button(action: {
                      action = .goForward
                  }) {
                  Image(systemName: "chevron.right")
                      .imageScale(.large)
                      
                  }
              }
              TextField("Address", text: $address).disableAutocorrection(true)
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
          HStack(spacing: 100.0) {
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
          }
          }
      }
      .frame(width: gp.size.width, height: gp.size.height * 1)
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
