//
//  ContentView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 5/30/22.
//

import SwiftUI
import Introspect
import WebKit



class ContentData: ObservableObject {
   @Published var inputURL: String = ""
   @Published var backDisabled: Bool = true
   @Published var forwardDisabled: Bool = true
    
    
}


struct ContentView: View {


    
    var ratioSlider: UISlider!
    @State var size: Double = 0.7
   @ObservedObject var contentData = ContentData()
   var webView: WebView!

   init() {
       webView = WebView(inputURL: $contentData.inputURL, backDisabled: $contentData.backDisabled, forwardDisabled: $contentData.forwardDisabled )
   }

   var body: some View {
       
       
       //GeometryReader for adaptive screen size for different devices. Hstack vs Vstack change to comeNSObject
       GeometryReader { gp in
           VStack {
          webView
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
    
          HStack {
             Button(action: {
                self.webView.goBack()
             }, label: {
                 Image(systemName: "arrow.backward")
                     .padding(.leading, 8)
                   .font(.title)
             }).disabled(self.contentData.backDisabled)
             Button(action: {
                self.webView.goForward()
             }, label: {
                Image(systemName: "arrow.forward")
                   .font(.title)
             }).disabled(self.contentData.forwardDisabled)
            TextField("google.com", text: $contentData.inputURL)
             Button(action: {
                self.webView.refresh()
             }, label: {
                Image(systemName: "arrow.clockwise.circle")
                   .font(.title)
             })
            Button("Go") {
               let text = self.contentData.inputURL.trimmingCharacters(in: .whitespaces)
               if !text.isEmpty {
                  self.webView.loadWeb(loadWeb:"https://" + text) //More user friendly to allow non https inputs
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
