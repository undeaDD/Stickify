import UIKit

class SettingsView: UITableViewController {

    @IBOutlet weak var widthField: UITextField!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var actionField: UISegmentedControl!
    @IBOutlet weak var themeField: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        if let color = (UIApplication.shared.delegate as? AppDelegate)?.tintColor {
            self.view.backgroundColor = color
        }

        self.tableView.tableFooterView = UIView()

        widthField.addTarget(self, action: #selector(updateWidth), for: .editingChanged)
        heightField.addTarget(self, action: #selector(updateHeight), for: .editingChanged)
        actionField.addTarget(self, action: #selector(updateAction), for: .valueChanged)

        let width = UserDefaults.standard.integer(forKey: "StickifyWidth")
        widthField.text = width <= 0 ? "512" : "\(width)"

        let height = UserDefaults.standard.integer(forKey: "StickifyHeight")
        heightField.text = height <= 0 ? "512" : "\(height)"

        let index = UserDefaults.standard.integer(forKey: "StickifyActionAfterwards")
        actionField.selectedSegmentIndex = index

        let saved = UserDefaults.standard.bool(forKey: "StickifyTheme")
        themeField.setOn(saved, animated: false)
        themeField.addTarget(self, action: #selector(updateTheme), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            view.textLabel?.textColor = .white
        }
    }

    @objc
    func updateWidth() {
        if let number = Int(widthField.text ?? "512") {
            UserDefaults.standard.set(number, forKey: "StickifyWidth")
        }
    }

    @objc
    func updateHeight() {
        if let number = Int(heightField.text ?? "512") {
            UserDefaults.standard.set(number, forKey: "StickifyHeight")
        }
    }

    @objc
    func updateAction() {
        let index = actionField.selectedSegmentIndex
        UserDefaults.standard.set(index, forKey: "StickifyActionAfterwards")
    }

    @objc
    func updateTheme() {
        let isOn = themeField.isOn
        UserDefaults.standard.set(isOn, forKey: "StickifyTheme")
    }

}
