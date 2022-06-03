//
//  ContentView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 5/30/22.
//

import SwiftUI

class ContentData: ObservableObject {
   @Published var inputURL: String = ""
   @Published var backDisabled: Bool = true
   @Published var forwardDisabled: Bool = true
}

let apsect1 = false;
let aspect2 = false;
let aspect3 = false;


struct ContentView: View {
   @ObservedObject var contentData = ContentData()
   var webView: WebView!
    
   init() {
      webView = WebView(inputURL: $contentData.inputURL, backDisabled: $contentData.backDisabled, forwardDisabled: $contentData.forwardDisabled)
   }
   var body: some View {
       //GeometryReader for adaptive screen size for different devices. Hstack vs Vstack change to come
       GeometryReader { gp in
      VStack {
          webView
              .frame(width: gp.size.width, height: gp.size.height * 0.7)
          Divider()
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
            .padding(.trailing, 10)
         }
         .frame(width: gp.size.width, height: gp.size.height * 0.045)
          Spacer()
          HStack(spacing: 50.0) {
              Image(systemName: "video.circle")
                  .resizable(resizingMode: .tile)
                  .frame(width: gp.size.width * 0.15, height: gp.size.height * 0.08)
          Image(systemName: "note.text.badge.plus")
                  .resizable(resizingMode: .tile)
                  .frame(width: gp.size.width * 0.15, height: gp.size.height * 0.08)
              Image(systemName: "list.dash")
                  .resizable(resizingMode: .tile)
                  .frame(width: gp.size.width * 0.15, height: gp.size.height * 0.08)
          }
         Spacer()
      }
      .frame(width: gp.size.width, height: gp.size.height * 1)
   }
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

