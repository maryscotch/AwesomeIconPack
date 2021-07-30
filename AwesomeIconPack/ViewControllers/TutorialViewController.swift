import UIKit
import SDWebImage

class TutorialViewController: UIViewController {
    let load = Load()
    var tutorialJson: IconData?
    
    @IBOutlet var tutorialImage1: UIImageView!
    @IBOutlet var tutorialImage2: UIImageView!
    @IBOutlet var tutorialImage3: UIImageView!
    @IBOutlet var tutorialImage4: UIImageView!
    @IBOutlet var tutorialImage5: UIImageView!
    @IBOutlet var tutorialImage6: UIImageView!
    @IBOutlet var tutorialImage7: UIImageView!
    @IBOutlet var tutorialImage8: UIImageView!
    @IBOutlet var tutorialImage9: UIImageView!
    @IBOutlet var tutorialImage10: UIImageView!
    @IBOutlet var tutorialImage11: UIImageView!
    @IBOutlet var tutorialImage12: UIImageView!
    @IBOutlet var tutorialImage13: UIImageView!
    @IBOutlet var tutorialImage14: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        load(url: jsonURL.iconData)
    }
    
    func load(url: String) {
        load.loadJson(fromURLString: url) { (result) in
            DispatchQueue.main.async { [self] in
                switch result {
                case .success(let data):
                    let iconData = self.load.parse(jsonData: data)
                    if iconData == nil {
                        self.displayAlert(title: "Failed to load tutorial images...", message: nil)
                        return
                    }
                    self.tutorialJson = iconData
                    for i in 0..<14 {
                        let tutorialImageURL = URL(string:  tutorialJson?.tutorial[i] ?? "")
                        if let tutorialImage :UIImageView = self.view.viewWithTag(i + 1) as? UIImageView {
                            tutorialImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
                            tutorialImage.sd_setImage(with: tutorialImageURL)
                        }
                    }
                case .failure(let error):
                    self.displayAlert(title: "Failed to load", message: nil)
                    print(error)
                }
            }
        }
    }
    
    func setNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.title = "Tutorial"
        // 戻るボタン
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        backBtn.setImage(UIImage(named: "NavigationIcon/back"), for: .normal)
        backBtn.addTarget(self , action: #selector(backButton), for: UIControl.Event.touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func backButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
}
