import UIKit
import TLPhotoPicker
import Sheeeeeeeeet
import APESuperHUD
import AVFoundation
import SpriteKit
import Themeable
import TCMask

class ImagePickerView: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var toolbar: UIToolbar!
    private var observer: NSKeyValueObservation?
    private var selectedMenuIndex: Int = 0
    private var temp: [TLPHAsset] = []

    @IBAction func showMenu(_ sender: UIBarButtonItem) {
        let title = ActionSheetTitle(title: "Stickify  -  v1.0")
        
        let item0 = ActionSheetItem(title: "Send Feedback", image: UIImage(named: "feedback"))
        let item1 = ActionSheetItem(title: "Buy me a coffee", image: UIImage(named: "coffe"))
        let item2 = ActionSheetItem(title: "Rate Stickify", image: UIImage(named: "star"))
        
        let item3 = ActionSheetLinkItem(title: "Licenses", image: UIImage(named: "licenses"))
        let item4 = ActionSheetLinkItem(title: "SourceCode", image: UIImage(named: "source"))
        let item5 = ActionSheetLinkItem(title: "Data privacy", image: UIImage(named: "privacy"))
        let item6 = ActionSheetLinkItem(title: "Settings", image: UIImage(named: "settings"))
        
        let margin = ActionSheetSectionMargin()
        let button = ActionSheetCancelButton(title: "Cancel")

        let items = [title, item0, item1, item2, margin, item3, item4, item5, item6, button]
        ActionSheet(items: items) { sheet, item in
            let index = items.firstIndex(of: item) ?? -1
            
            switch index {
            case 1:
                let id = UIDevice.current.identifierForVendor!.uuidString
                UIApplication.shared.open(URL(string: "mailto:dominic.drees@live.de?subject=Stickify%20Feedback%20(\(id))&body=Hey%20Dominic,")!, options: [:], completionHandler: nil)
            case 2:
                UIApplication.shared.open(URL(string: "https://www.paypal.me/undeaDD")!, options: [:], completionHandler: nil)
            case 3:
                let appID = "1319886486"
                UIApplication.shared.open(URL(string: "https://itunes.apple.com/app/id" + appID + "?action=write-review")!, options: [:], completionHandler: nil)
            case 5,6,7:
                self.selectedMenuIndex = index
                self.performSegue(withIdentifier: "showWebView", sender: index)
            case 8:
                self.performSegue(withIdentifier: "showSettings", sender: index)
            default:
                break
            }
        }.present(in: self, from: self.view)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showWebView" {
            if let dest = segue.destination as? InAppWebView {
                dest.type = self.selectedMenuIndex
            }
        }
    }
    
    @IBAction func openPhotoLibrary(_ sender: UIBarButtonItem) {
        let picker = TLPhotosPickerViewController()
        picker.delegate = self
        picker.configure.singleSelectedMode = true
        picker.configure.allowedLivePhotos = false
        picker.configure.allowedAlbumCloudShared = false
        picker.configure.allowedVideo = false
        picker.configure.allowedVideoRecording = false
        picker.configure.usedCameraButton = false
        picker.configure.usedPrefetch = true
        
        present(picker, animated: true)
    }
    
    @IBAction func openCamera(_ sender: UIBarButtonItem) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = self
        picker.cameraCaptureMode = .photo
        
        present(picker, animated: true)
    }
    
    @IBAction func openUrl(_ sender: UIBarButtonItem) {
        let state: UIAlertController.AlertState = (title: "Download Image", message: "paste the direct image URL here.", normal: "Download & Edit", cancel: "Cancel", textField: true)
        UIAlertController.show(vc: self, state: state, completion: { (result) in
            if let string = result, let url = URL(string: string) {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    self.nextAction(image)
                    return
                }
            }

            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.error)
            
            let state: UIAlertController.AlertState = (title: "Error", message: "the provided url is invalid and cannot be processed further. the url needs to start with 'https://' and must point to an valid image source.", normal: nil, cancel: "Okay", textField: false)
            UIAlertController.show(vc: self, state: state, completion: { (result) in })
        })
    }
    
    private func nextAction(_ image: UIImage) {
        let maskView = TCMaskView(image: image)
        
        var color = #colorLiteral(red: 0.01194981113, green: 0.4769998789, blue: 0.9994105697, alpha: 1)
        if let c = (UIApplication.shared.delegate as? AppDelegate)?.tintColor {
            color = c
        }
        
        maskView.toolMenu.backgroundColor = .white
        maskView.toolMenu.tintColor = color
        maskView.bottomBar.tintColor = color
        maskView.topBar.tintColor = color
        maskView.settingView.tintColor = color
        
        maskView.delegate = self
        maskView.initialTool = .brush
        maskView.imageView.backgroundColor = .white
            
        UIView.animate(withDuration: 1.0, animations: {
            maskView.presentFrom(rootViewController: self, animated: true)
        }, completion: { finished in self.hideAds() })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let color = (UIApplication.shared.delegate as? AppDelegate)?.tintColor {
            self.view.backgroundColor = color
        }
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        self.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        guard let emitter = SKEmitterNode(fileNamed: "FireFliesParticle") else { return }
        emitter.position = CGPoint(x: self.view.center.x, y: self.view.center.y)
        if let texture = getParticle() {
            emitter.particleTexture = texture
        }
        emitter.zPosition = 0
        
        let skView = SKView(frame: self.view.frame)
        skView.allowsTransparency = true
        
        let skScene = SKScene(size: skView.frame.size);
        skScene.scaleMode = .aspectFill;
        skScene.backgroundColor = .clear
        skScene.addChild(emitter)
        
        skView.presentScene(skScene)
        skView.alpha = 0.2
        self.view.insertSubview(skView, at: 1)
    }
    
    private func getParticle() -> SKTexture? {
        if let url = URL(string: "https://deltasiege.eu/Stickify.particle.png") {
            if let data = try? Data(contentsOf: url), let theImage = UIImage(data: data) {
                return SKTexture(image: theImage)
            }
        }
        
        return nil
    }
    
}

extension ImagePickerView: TLPhotosPickerViewControllerDelegate {
    
    func dismissPhotoPicker(withTLPHAssets: [TLPHAsset]) {
        temp = withTLPHAssets
        APESuperHUD.removeHUD(animated: true, presentingView: self.view, completion: nil)
    }
    
    func dismissComplete() {
        if temp.count == 1 {
            if let image = temp.first?.fullResolutionImage {
                nextAction(image)
            }else {
                APESuperHUD.showOrUpdateHUD(loadingIndicator: .standard, message: "", presentingView: self.view)
                temp.first?.cloudImageDownload(progressBlock: { _ in }, completionBlock: { (image) in
                    APESuperHUD.removeHUD(animated: true, presentingView: self.view, completion: nil)
                    if let img = image {
                        self.nextAction(img)
                    }else {
                        let state: UIAlertController.AlertState = (title: "Error", message: "the image cannot be loaded. if this happens frequently be sure to contact the developer", normal: "Contact", cancel: "Ignore", textField: false)
                        UIAlertController.show(vc: self, state: state, completion: { (result) in
                            let line = #line; let function = #function
                            self.sendEmail(function + ":\(line):could not load TLPHAssetImage")
                        })
                    }
                })
            }
        }
    }
    
}

extension ImagePickerView: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.nextAction(image)
            }
        })
    }
    
}

extension ImagePickerView: TCMaskViewDelegate {
 
    func tcMaskViewDidComplete(mask: TCMask, image: UIImage) {
        observer?.invalidate()
        
        if let outputImage = mask.cutout(image: image, resize: true) {
            let optionalImage = outputImage.resizeImage()
            
            if let data = optionalImage?.pngData(), let saveImage = UIImage(data: data) {
                UIImageWriteToSavedPhotosAlbum(saveImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.success)
                
                let image = UIImage(named: "success")!
                APESuperHUD.showOrUpdateHUD(icon: image, message: "Saved Image", particleEffectFileName: "FireFliesParticle", presentingView: self.view, completion: {
                    switch UserDefaults.standard.integer(forKey: "StickifyActionAfterwards") {
                    case 1:
                        exit(0)
                    case 2:
                        if let url = URL(string: "tg://"), UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    default:
                        break;
                    }
                })
            } else {
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.error)
                
                let state: UIAlertController.AlertState = (title: "Error", message: "the image cannot be processed and saved. if this happens frequently be sure to contact the developer", normal: "Contact", cancel: "Ignore", textField: false)
                UIAlertController.show(vc: self, state: state, completion: { (result) in
                    let line = #line; let function = #function
                    self.sendEmail(function + ":\(line):could not resize pngImage")
                })
            }
        }
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator.notificationOccurred(.error)
            
            let state: UIAlertController.AlertState = (title: "Error", message: "the image cannot be saved. if this happens frequently be sure to contact the developer", normal: "Contact", cancel: "Ignore", textField: false)
            UIAlertController.show(vc: self, state: state, completion: { (result) in
                let line = #line; let function = #function
                self.sendEmail(function + ":\(line):" + error.localizedDescription)
            })
        }
    }
    
    private func sendEmail(_ error: String) {
        let id = UIDevice.current.identifierForVendor!.uuidString
        UIApplication.shared.open(URL(string: "mailto:dominic.drees@live.de?subject=Stickify%20Error%20(\(id))&body=Hey%20Dominic,%0D%0A%0D%0A\(error)")!)
    }
    
    private func hideAds() {
        if let vc = self.presentedViewController {
            let views = vc.view.subviews
            var height: CGFloat = 0.0
            
            for (index, v) in views.enumerated() {
                if index == 1 {
                    height = v.frame.height
                    v.isHidden = true
                    v.frame.size.height = 0.0
                    
                    observer = v.layer.observe(\.bounds) { object, _ in
                        self.observer?.invalidate()
                        self.observer = nil
                        self.hideAds()
                    }
                } else if index == 2 {
                    let y = v.frame.minY - height
                    let h = v.frame.height + height
                    v.frame = CGRect(x: 0, y: y, width: view.frame.width, height: h)
                    vc.view.setNeedsDisplay()
                    break
                }
            }
        }
    }

}


extension UIImage {

    func resizeImage() -> UIImage? {
        let height = UserDefaults.standard.integer(forKey: "StickifyHeight")
        let width = UserDefaults.standard.integer(forKey: "StickifyWidth")
        let targetSize = CGSize(width: width <= 0 ? 512 : width, height: height <= 0 ? 512 : height)
        
        let rect = AVMakeRect(aspectRatio: self.size, insideRect: CGRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height))

        UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage;
    }

}

extension UIAlertController {
    
    public typealias AlertState = (title: String, message: String, normal: String?, cancel: String?, textField: Bool)
    
    public class func show(vc: UIViewController, state: AlertState, completion: @escaping (String?) -> ()) {
        let alert = UIAlertController(title: state.title, message: state.message, preferredStyle: .alert)
        
        if state.textField {
            alert.addTextField(configurationHandler: { (field) in
                field.placeholder = "https://www.example.de/img.jpg"
            })
        }
        
        if let buttonA = state.normal {
            alert.addAction(UIAlertAction(title: buttonA, style: .default, handler: { (action) in
                if state.textField {
                    if let text = alert.textFields?.first?.text, text.hasPrefix("https://") {
                        completion(text)
                    }else {
                        completion(nil)
                    }
                } else {
                    completion(nil)
                }
            }))
        }
        
        if let buttonC = state.cancel {
            alert.addAction(UIAlertAction(title: buttonC, style: .cancel, handler: nil))
        }
        
        vc.present(alert, animated: true, completion: nil)
    }
    
}
