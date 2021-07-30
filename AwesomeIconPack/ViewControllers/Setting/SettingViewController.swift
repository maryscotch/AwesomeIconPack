import UIKit
import StoreKit
import MessageUI

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let settingsModel = SettingsModel.init()
    let purchase = Purchase()

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationbar()
        tableSet()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableSet() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SettingTableViewCell", bundle: nil), forCellReuseIdentifier: "settingCell")
        tableView.rowHeight = 60
    }
    
    func setNavigationbar() {
        self.navigationItem.title = "Settings"
        self.navigationItem.hidesBackButton = true
        // 戻るボタン
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        backBtn.setImage(UIImage(named: "NavigationIcon/back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButton), for: UIControl.Event.touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    // 戻るボタン
    @objc func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

// 設定
extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsModel.getAll().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell") as? SettingTableViewCell {
            let setting = settingsModel.getAll()[indexPath.row]
            cell.settingsLabel.text = setting.settingItem
            cell.settingsIcon.image = UIImage(named: setting.itemImagePath)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableViewr: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 0:
            howToSetIconImage()
        case 1:
            getPuremium()
        case 2:
            restore()
        case 3:
            shareApp()
        case 4:
            rateThisApp()
        case 5:
            contactToDev()
        case 6:
            privacyPolicy()
        default:
            break
        }
    }
    
    // チュートリアル（0）
    func howToSetIconImage() {
        guard let vc = storyboard?.instantiateViewController(identifier: "tutorial") as? TutorialViewController else { return }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // 購入（1）
    func getPuremium() {
        let isPurchase = UserDefaults.standard.bool(forKey: "isPurchase")
        if !isPurchase {
            // 未購入
            guard let vc = storyboard?.instantiateViewController(identifier: "purchase") as? PurchaseViewController else { return }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
        } else {
            // 購入済み
            displayAlert(title: "Already purchased", message: nil)
        }
    }
    
    // リストア（2）
    func restore() {
        purchase.restore()
        purchase.successHandler = {
            self.displayAlert(title: "Restore successful", message: nil)
        }
        purchase.alreadyPurchasedHandler = {
            self.displayAlert(title: "Already purchased", message: nil)
        }
        purchase.notPurchasedYetHandler = {
            self.displayAlert(title: "Error", message: "Nothing to restore.")
        }
        purchase.errorHandler = {
            self.displayAlert(title: "Error", message: "Couldn't restore" )
        }
    }
    
    // アプリをシェア（3）
    func shareApp() {
        if let name = URL(string: "https://itunes.apple.com/us/app/myapp/id1574067049?ls=1&mt=8"), !name.absoluteString.isEmpty {
          let objectsToShare = [name]
          let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
          self.present(activityVC, animated: true, completion: nil)
        } else {
          displayAlert(title: "Failed to share", message: nil)
        }
    }
    
    // アプリをレビュー（4）
    func rateThisApp() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    // 開発者へ連絡（5）
    func contactToDev() {
        if !MFMailComposeViewController.canSendMail() {
            displayAlert(title: "Mail services are not available", message: nil)
            return
        }
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        composeVC.setToRecipients(["mrydev.08@gmail.com"])
        self.present(composeVC, animated: true, completion: nil)
    }
    
    // メールを閉じる
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
            switch result {
            case .sent:
                displayAlert(title: "Email sent to developers.", message: nil)
                break
            case .failed:
                displayAlert(title: "Failed to send Email.", message: nil)
                break
            default:
                break
            }
        }
    
    // プライバシーポリシー（6）
    func privacyPolicy() {
        let url = URL(string: "http://mrkozk.html.xdomain.jp/awesomeIconPackPrivacyPolicy.html")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}
