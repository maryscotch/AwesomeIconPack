import UIKit
import StoreKit
import SwiftyStoreKit
import FSPagerView
import SDWebImage


class PurchaseViewController: UIViewController {
    let purchase = Purchase()
    var load = Load()
    var iconData: IconData?
    
    @IBOutlet var price: UILabel!
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        naviSet()
        setFSPagerView()
        setPrice()
        load(url: jsonURL.iconData)
    }
    
    // 画像ロード
    func load(url: String) {
        load.loadJson(fromURLString: url) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let iconData = self.load.parse(jsonData: data)
                    if iconData == nil {
                        self.displayAlert(title: "Failed to load", message: nil)
                        return
                    }
                    self.iconData = iconData
                    self.pagerView.reloadData()
                case .failure(let error):
                    self.displayAlert(title: "Failed to load", message: nil)
                    print(error)
                }
            }
        }
    }
    
    func naviSet() {
        // 戻るボタン
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        backBtn.setImage(UIImage(named:"NavigationIcon/close"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButton), for: UIControl.Event.touchUpInside)
        let backBarItem = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backBarItem
        // ナビゲーションバー
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
    }
    
    //　戻るボタン
    @objc func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 価格
    func setPrice() {
        purchase.getPriceInfo()
        purchase.priceHandler = {(price: String?) -> Void in
            if price != nil {
                self.price.text = "Just " + price!
            }
            if price == nil {
                self.price.text = "Price: Error"
            }
        }
    }

    // 購入ボタン
    @IBAction func purchaseProduct() {
        purchase.purchaseProduct()
        purchase.successHandler = {
            self.dismiss(animated: true, completion: nil)
        }
        purchase.errorHandler = {
            self.displayAlert(title: "Error", message: "Unable to purchase.")
        }
    }
    
    // リストア
    @IBAction func restoreProduct() {
        purchase.restore()
        purchase.successHandler = {
            let alert = UIAlertController(title: "Restore Successful", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) {_ in
                self.dismiss(animated: true, completion: nil)
            })
            self.present(alert, animated: true, completion: nil)
        }
        purchase.alreadyPurchasedHandler = {
            self.displayAlert(title: "Already purchased", message: nil)
        }
        purchase.notPurchasedYetHandler = {
            self.displayAlert(title: "Error", message: "Nothing to restore")
        }
        purchase.errorHandler = {
            self.displayAlert(title: "Eror", message: "Couldn't restore")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // プライバシーポリシー
    @IBAction func displayPrivacyPolicy() {
        let url = URL(string: "http://mrkozk.html.xdomain.jp/awesomeIconPackPrivacyPolicy.html")!
        if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
    }
}

// 課金コンテンツ画像
extension PurchaseViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func setFSPagerView() {
        pagerView.delegate = self
        pagerView.dataSource = self
        pagerView.isInfinite = true
        pagerView.decelerationDistance = 1
        pagerView.itemSize = CGSize(width: 140, height: 240)
        pagerView.transformer = FSPagerViewTransformer(type: .coverFlow)
    }
    
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return iconData?.premiumImage.count ?? 0
    }
    
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        
        if let premiumImageURL = URL(string: iconData?.premiumImage[index] ?? "") {
            cell.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView?.sd_setImage(with: premiumImageURL)
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        return false
    }
}
