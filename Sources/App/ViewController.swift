import UIKit
import WebKit

class ViewController: UIViewController {

    private var webView: WKWebView!
    private let session = URLSession.shared

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var prefersStatusBarHidden: Bool { false }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        setupWebView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
    }

    private func setupWebView() {
        let ucc = WKUserContentController()
        ucc.add(self, name: "nativeBridge")

        let cfg = WKWebViewConfiguration()
        cfg.userContentController = ucc
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []

        let wpp = WKWebpagePreferences()
        wpp.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = wpp

        webView = WKWebView(frame: view.bounds, configuration: cfg)
        webView.backgroundColor = UIColor.black
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        view.addSubview(webView)

        // Load HTML from bundle
        let candidates: [(String?, String)] = [
            ("web", "index"), (nil, "index")
        ]
        for (sub, name) in candidates {
            if let url = Bundle.main.url(forResource: name, withExtension: "html", subdirectory: sub) {
                webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
                return
            }
        }
    }
}

// MARK: - Navigation Delegate
extension ViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = action.request.url {
            if url.isFileURL || url.absoluteString == "about:blank" {
                decisionHandler(.allow); return
            }
            UIApplication.shared.open(url)
        }
        decisionHandler(.cancel)
    }
}

// MARK: - Native Bridge
extension ViewController: WKScriptMessageHandler {
    func userContentController(_ ucc: WKUserContentController,
                                didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any],
              let action = body["action"] as? String else { return }

        switch action {

        case "getHWID":
            let raw = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
            let hwid = "PQ-" + raw.replacingOccurrences(of: "-", with: "")
                                  .prefix(8).uppercased()
            DispatchQueue.main.async {
                self.eval("window.receiveNativeHWID('\(hwid)')")
            }

        case "httpGet":
            guard let urlStr = body["url"] as? String,
                  let cbId  = body["callbackId"] as? String,
                  let url   = URL(string: urlStr) else { return }

            var req = URLRequest(url: url, timeoutInterval: 15)
            req.setValue("application/json", forHTTPHeaderField: "Accept")

            session.dataTask(with: req) { [weak self] data, _, error in
                DispatchQueue.main.async {
                    if let data = data,
                       let str = String(data: data, encoding: .utf8) {
                        let safe = str
                            .replacingOccurrences(of: "\\", with: "\\\\")
                            .replacingOccurrences(of: "'",  with: "\\'")
                            .replacingOccurrences(of: "\n", with: "\\n")
                            .replacingOccurrences(of: "\r", with: "")
                        self?.eval("window.receiveAPIResponse('\(cbId)','\(safe)')")
                    } else {
                        let err = error?.localizedDescription ?? "Network error"
                        self?.eval("if(window['\(cbId)_e'])window['\(cbId)_e']('\(err)')")
                    }
                }
            }.resume()

        case "openURL":
            if let urlStr = body["url"] as? String,
               let url = URL(string: urlStr) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }

        case "launchApp":
            // Placeholder: handle in-app launch logic
            break

        default:
            break
        }
    }

    private func eval(_ js: String) {
        webView.evaluateJavaScript(js, completionHandler: nil)
    }
}
