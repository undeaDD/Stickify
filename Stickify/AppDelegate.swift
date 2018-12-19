import UIKit
import Sheeeeeeeeet
import APESuperHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var tintColor = getColor()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0

        APESuperHUD.appearance.backgroundBlurEffect = .none
        APESuperHUD.appearance.cancelableOnTouch = false

        APESuperHUD.appearance.iconWidth = 48
        APESuperHUD.appearance.iconHeight = 48
        APESuperHUD.appearance.cornerRadius = 15
        APESuperHUD.appearance.titleFontSize = 22
        APESuperHUD.appearance.animateInTime = 1.5
        APESuperHUD.appearance.messageFontSize = 14
        APESuperHUD.appearance.animateOutTime = 1.5
        APESuperHUD.appearance.defaultDurationTime = 2.25

        APESuperHUD.appearance.iconColor = tintColor
        APESuperHUD.appearance.textColor = tintColor
        APESuperHUD.appearance.backgroundColor = tintColor
        APESuperHUD.appearance.loadingActivityIndicatorColor = tintColor

        let appearance = ActionSheetAppearance.standard

        appearance.item.backgroundColor = .white
        appearance.item.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        appearance.item.textColor = tintColor
        appearance.item.tintColor = tintColor

        appearance.title.textColor = .black
        appearance.title.height = 50
        appearance.title.separatorInsets.right = 100_000_000
        appearance.title.font = UIFont.systemFont(ofSize: 12, weight: .regular)

        appearance.linkItem.linkIcon = UIImage(named: "ic_arrow_right")
        appearance.linkItem.tintColor = tintColor

        appearance.sectionTitle.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        appearance.sectionTitle.height = 18

        appearance.cancelButton.textColor = tintColor
        appearance.cancelButton.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        return true
    }

    private static func getColor() -> UIColor {
        let semaphore = DispatchSemaphore(value: 0)
        var color = #colorLiteral(red: 0.01194981113, green: 0.4769998789, blue: 0.9994105697, alpha: 1)

        if UserDefaults.standard.bool(forKey: "StickifyTheme") {
            if let url = URL(string: "https://deltasiege.eu/Stickify.color") {
                URLSession.shared.dataTask(with: url) {(data, _, _) in
                    if let data = data, let temp = String(data: data, encoding: .utf8) {
                        color = UIColor(hexString: temp)
                    }

                    semaphore.signal()
                }.resume()
            }

            semaphore.wait()
        }

        return color
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }

        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
