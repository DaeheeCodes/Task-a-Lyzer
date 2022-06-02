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
         HStack {
             Button(action: {
                self.webView.goBack()
             }, label: {
                 Image(systemName: "arrow.left.circle")
                     .padding(.leading, 8)
                   .font(.title)
             }).disabled(self.contentData.backDisabled)
             Button(action: {
                self.webView.goForward()
             }, label: {
                Image(systemName: "arrow.right.circle")
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


         Spacer()
      }
   }
}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

