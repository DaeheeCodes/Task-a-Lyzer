//
//  WebView.swift
//  Task-a-Lyzer
//
//  Created by DHC on 6/2/22.
//


import SwiftUI
import Introspect
import WebKit

 public enum WebViewAction {
   case idle, // idle is always needed as actions need an empty state
      load(URLRequest),
      reload,
      goBack,
      goForward
 }

 public struct WebViewState {
   public internal(set) var isLoading: Bool
   public internal(set) var pageTitle: String?
   public internal(set) var pageURL: String?
   public internal(set) var error: Error?
   public internal(set) var canGoBack: Bool
   public internal(set) var canGoForward: Bool

   public static let empty = WebViewState(isLoading: false,
                                          pageTitle: nil,
                                          pageURL: nil,
                                          error: nil,
                                          canGoBack: false,
                                          canGoForward: false)
 }

public class WebViewCoordinator: NSObject {
  private let webView: WebView

  init(webView: WebView) {
    self.webView = webView
  }

  // Convenience method, used later
  func setLoading(_ isLoading: Bool, error: Error? = nil) {
    var newState =  webView.state
    newState.isLoading = isLoading
    if let error = error {
      newState.error = error
    }
    webView.state = newState
  }
}

extension WebViewCoordinator: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    setLoading(false)

      webView.evaluateJavaScript("document.title") { (response, error) in
          if let title = response as? String {
              var newState = self.webView.state
              newState.pageTitle = title
              self.webView.state = newState
          }
      }
      
      webView.evaluateJavaScript("document.URL.toString()") { (response, error) in
          if let url = response as? String {
              var newState = self.webView.state
              newState.pageURL = url
              self.webView.state = newState
          }
      }
  }
    
    


  public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
    setLoading(false)
  }

  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    setLoading(false, error: error)
  }

  public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
    setLoading(true)
  }

  public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    var newState = self.webView.state
    newState.isLoading = true
    newState.canGoBack = webView.canGoBack
    newState.canGoForward = webView.canGoForward
    self.webView.state = newState
  }
}

public struct WebView: UIViewRepresentable {
  @Binding var action: WebViewAction
  @Binding var state: WebViewState

  public init(action: Binding<WebViewAction>,
              state: Binding<WebViewState>) {
    _action = action
    _state = state
  }

  public func makeCoordinator() -> WebViewCoordinator {
    WebViewCoordinator(webView: self)
  }

  public func makeUIView(context: Context) -> WKWebView {
    let preferences = WKPreferences()
    preferences.javaScriptEnabled = true

    let configuration = WKWebViewConfiguration()
    configuration.preferences = preferences
      configuration.allowsInlineMediaPlayback = true
    let webView = WKWebView(frame: CGRect.zero, configuration: configuration)
    webView.navigationDelegate = context.coordinator
    webView.allowsBackForwardNavigationGestures = true
    webView.scrollView.isScrollEnabled = true
      let request = URLRequest(url: URL(string: "https://www.google.com")!)
      webView.load(request)
    return webView
  }

  public func updateUIView(_ uiView: WKWebView, context: Context) {
    switch action {
    case .idle:
      break
    case .load(let request):
      uiView.load(request)
    case .reload:
      uiView.reload()
    case .goBack:
      uiView.goBack()
    case .goForward:
      uiView.goForward()
    }
    action = .idle // this is important to prevent never-ending refreshes
  }
}
