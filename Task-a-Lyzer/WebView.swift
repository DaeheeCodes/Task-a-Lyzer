//
//  WebView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 6/2/22.
//

import Foundation
import SwiftUI
import WebKit

 

struct WebView : UIViewRepresentable {
   @Binding var inputURL: String
   @Binding var backDisabled: Bool
   @Binding var forwardDisabled: Bool
    
    
    
    
   var view: WKWebView = WKWebView()

    
   func makeUIView(context: Context) -> WKWebView  {
       let webconfig = WKWebViewConfiguration()
       webconfig.allowsInlineMediaPlayback = true
       
      view.navigationDelegate = context.coordinator
      let request = URLRequest(url: URL(string: "https://www.udemy.com/course/js-algorithms-and-data-structures-masterclass/learn/lecture/8344044?start=435#overview?playsinline=1")!)
       self.view.load(request)
       self.view.frame = self.view.frame
       self.view.configuration.allowsInlineMediaPlayback = true
      return view
   }
   func updateUIView(_ uiView: WKWebView, context: Context) {
   }

   func loadWeb(loadWeb: String) {
      let dataURL = loadWeb.data(using: String.Encoding.utf8, allowLossyConversion: false)
      if let webURL = URL(dataRepresentation: dataURL!, relativeTo: nil, isAbsolute: true) {

         let request = URLRequest(url: webURL)

         view.load(request)
      }
   }
   func goBack(){
      view.goBack()
   }
   func goForward(){
      view.goForward()
   }
   func refresh(){
      view.reload()
   }
   func makeCoordinator() -> CoordinatorWebView {
      return CoordinatorWebView(input: $inputURL, back: $backDisabled, forward: $forwardDisabled)
   }
}
class CoordinatorWebView: NSObject, WKNavigationDelegate {
   var inputURL: Binding<String>
   var backDisabled: Binding<Bool>
   var forwardDisabled: Binding<Bool>

   init(input: Binding<String>, back: Binding<Bool>, forward: Binding<Bool>) {
      self.inputURL = input
      self.backDisabled = back
      self.forwardDisabled = forward
   }
   func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
      if let webURL = webView.url {
         self.inputURL.wrappedValue = webURL.absoluteString
         self.backDisabled.wrappedValue = !webView.canGoBack
         self.forwardDisabled.wrappedValue = !webView.canGoForward
      }
   }
}
