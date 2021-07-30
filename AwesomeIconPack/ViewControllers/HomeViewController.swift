import UIKit
import FSPagerView
import StoreKit
import SDWebImage


class HomeViewController: UIViewController {
    @IBOutlet var displayNextPage: UIButton!
    @IBOutlet var pageControl: UIPageControl!
    
    var load = Load()
    var iconJson: IconData?
    
    @IBOutlet weak var pagerView: FSPagerView! {
        didSet {
            self.pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavi()
        setSliderView()
        pageControl.isHidden = true
        rateAppOnceIn10Times()
        load(url: jsonURL.iconData)
    }
    
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
        }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(true)
        setNavi()
        pagerView.reloadData()
    }
    
    // アイコンテーマ画像ロード
    func load(url: String) {
        load.loadJson(fromURLString: url) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    let iconData = self.load.parse(jsonData: data)
                    if iconData == nil {
                        self.displayAlert(title: "Failed to load", message: nil)
                        self.displayNextPage.isEnabled = false
                        return
                    }
                    self.iconJson = iconData
                    self.pageControl.isHidden = false
                    self.pageControl.numberOfPages = self.iconJson?.theme.count ?? 0
                    self.pagerView.reloadData()
                case .failure(let error):
                    self.displayAlert(title: "Failed to load", message: nil)
                    self.displayNextPage.isEnabled = false
                    print(error)
                }
            }
        }
    }
    
    // アプリ開いた回数をリセット
    func rateAppOnceIn10Times() {
        let appOpenCount = UserDefaults.standard.integer(forKey: "appOpenCount")
        if appOpenCount  %  10 == 0 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    // ナビゲーションバー
    private func setNavi() {
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        // 設定ボタン
        let settingBtn = UIButton(type: .custom)
        settingBtn.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        settingBtn.setImage(UIImage(named: "NavigationIcon/setting"), for: .normal)
        settingBtn.addTarget(self, action: #selector(settingButton), for: UIControl.Event.touchUpInside)
        let settingButtonItem = UIBarButtonItem(customView: settingBtn)
        // チュートリアルボタン
        let howToBtn = UIButton(type: .custom)
        howToBtn.frame = CGRect(x: 0.0, y: 0.0, width: 30, height: 30)
        howToBtn.setImage(UIImage(named: "NavigationIcon/howto_home"), for: .normal)
        howToBtn.addTarget(self, action: #selector(howToButton), for: UIControl.Event.touchUpInside)
        let howToButton = UIBarButtonItem(customView: howToBtn)
        self.navigationItem.rightBarButtonItems = [settingButtonItem, howToButton]
    }
    
    // 設定ボタン
    @objc func settingButton(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "setting") as? SettingViewController else { return }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // チュートリアルボタン
    @objc func howToButton(_ sender: UIBarButtonItem) {
        guard let vc = storyboard?.instantiateViewController(identifier: "tutorial") as? TutorialViewController else { return }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // アイコンテーマ画像セット
    private func setSliderView() {
           pagerView.delegate = self
           pagerView.dataSource = self
           pagerView.isInfinite = true
           pagerView.itemSize = CGSize(width: view.bounds.width - 80, height: self.view.bounds.height - 300)
           pagerView.transformer = FSPagerViewTransformer(type: .overlap)
       }
    
    // 次のページへ遷移
    @IBAction func nextButton() {
       let currentPage = pageControl.currentPage
        if let iconData = self.iconJson?.theme[currentPage] {
                  let downloadViewController = DownloadViewController.instantiate(with: iconData)
                  navigationController?.pushViewController(downloadViewController, animated: true)
              } else {
                  let title = "Thema does not exist"
                  let message = "The selected theme does not exist, sorry!"
                  displayAlert(title: title, message: message)
              }
    }
}

// アイコンテーマ
extension HomeViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    public func numberOfItems(in pagerView: FSPagerView) -> Int {
        return iconJson?.theme.count ?? 0
    }
        
    public func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if let themeImageURL = URL(string: iconJson?.theme[index].themeImage ?? "") {
            cell.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView?.sd_setImage(with: themeImageURL,  placeholderImage: UIImage(named: "placeholderImage"))
        }
        return cell
    }
    
    // テーマ画像がタップされた時
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if let iconData = self.iconJson?.theme[index] {
                  let downloadViewController = DownloadViewController.instantiate(with: iconData)
                  navigationController?.pushViewController(downloadViewController, animated: true)
              } else {
                  let title = "Thema does not exist"
                  let message = "The selected theme does not exist, sorry!"
                  displayAlert(title: title, message: message)
              }
    }
    
    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
    }
}

