import UIKit
import WebKit

class InAppWebView: UIViewController {

    @IBOutlet weak var wkWebView: WKWebView!
    public var type: Int = -1

    override func viewDidLoad() {
        super.viewDidLoad()

        if let color = (UIApplication.shared.delegate as? AppDelegate)?.tintColor {
            self.view.backgroundColor = color
        }

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.wkWebView.scrollView.backgroundColor = .clear

        switch type {
        case 5:
            let file = #fileLiteral(resourceName: "Licenses.html")
            self.navigationItem.title = "Licenses"
            if let tempString = try? String(contentsOfFile: file.path, encoding: .utf8) {
                self.wkWebView.loadHTMLString(tempString, baseURL: nil)
                return
            }
        case 6:
            self.navigationItem.title = "SourceCode"
            self.wkWebView.scrollView.backgroundColor = .white
            self.wkWebView.load(URLRequest(url: URL(string: "https://github.com/undeaDD/Stickify")!))
            return
        case 7:
            self.navigationItem.title = "Data privacy (in 🇩🇪)"
            let file = #fileLiteral(resourceName: "DataPrivacy.html")
            if let tempString = try? String(contentsOfFile: file.path, encoding: .utf8) {
                self.wkWebView.loadHTMLString(tempString, baseURL: nil)
                return
            }
        default: break
        }

        self.navigationItem.title = ""
        self.dismiss(animated: true, completion: nil)
    }
}
