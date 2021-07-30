import UIKit
import BetterSegmentedControl
import FSPagerView
import  SDWebImage


enum SegmentedType {
    case ICON
    case WALLPAPER
}

class DownloadViewController: UIViewController {
    // データ受け取り
    var iconDetail: IconDetail!
    
    var categories = ["Utilities", "SNS", "Entertainment", "Shopping", "Work", "Money", "Others"]
    
    var collectionView : UICollectionView!
    var pagerView = FSPagerView()
    var selectedImage: UIImage? = nil
    var selectedImageIcon: UIImage? = nil
    var selectedImageWallpaper: UIImage? = nil
    var currentSegmented: SegmentedType = .ICON
    
    internal static func instantiate(with iconData: IconDetail) -> DownloadViewController {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "download") as! DownloadViewController
        vc.iconDetail = iconData
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        setSegmented()
        setCollectionView()
        setWallpapers()
        pagerView.isHidden = true
    }
    
    // セグメントセット
    func setSegmented() {
        let navigationSegmentedControl = BetterSegmentedControl(frame: CGRect(x: 0, y: 0, width: 200, height: 30),
                                             segments: LabelSegment.segments(withTitles: ["Icons", "Wallpapers"],
                                                                                         normalTextColor: .lightGray,
                                                                                         selectedTextColor: .black)
                                             )
        navigationSegmentedControl.addTarget(self, action: #selector(self.navigationSegmentedControlValueChanged(_:)), for: .valueChanged)
        navigationItem.titleView = navigationSegmentedControl
        view.addSubview(navigationSegmentedControl)
    }
    
        // セグメント
        @objc func navigationSegmentedControlValueChanged(_ sender: BetterSegmentedControl) {
            if sender.index == 0 { // icon
                collectionView.isHidden = false
                pagerView.isHidden = true
                currentSegmented = SegmentedType.ICON
            } else { // wallpaper
                collectionView.isHidden = true
                pagerView.isHidden = false
                currentSegmented = SegmentedType.WALLPAPER
            }
        }
    
    // ナビゲーションボタンセット
    func setNavigationBar() {
        self.navigationItem.hidesBackButton = true
        // 戻るボタン
        let backBtn = UIButton(type: .custom)
        backBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        backBtn.setImage(UIImage(named: "NavigationIcon/back"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButton), for: UIControl.Event.touchUpInside)
        let backButton = UIBarButtonItem(customView: backBtn)
        self.navigationItem.leftBarButtonItem = backButton
        // 保存ボタン
        let saveBtn = UIButton(type: .custom)
        saveBtn.frame = CGRect(x: 0.0, y: 0.0, width: 20, height: 20)
        saveBtn.setImage(UIImage(named:"NavigationIcon/save"), for: .normal)
        saveBtn.addTarget(self, action: #selector(imageSaveButton), for: UIControl.Event.touchUpInside)
        let saveBarItem = UIBarButtonItem(customView: saveBtn)
        self.navigationItem.rightBarButtonItem = saveBarItem
        self.navigationController?.navigationBar.isTranslucent = false
    }
    
    // 戻る
    @objc func backButton(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func imageSaveButton(_ sender: UIBarButtonItem) {
        // 購入済みか確認
        let isPurchase = UserDefaults.standard.bool(forKey: "isPurchase")
        let isPaid = iconDetail.isPaid
        if !isPurchase && isPaid == true && currentSegmented == SegmentedType.ICON{
            // 未購入
            guard let vc = storyboard?.instantiateViewController(identifier: "purchase") as? PurchaseViewController else { return }
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true, completion: nil)
            return
        }
        
        selectedImage = selectedImageIcon
        if currentSegmented == SegmentedType.WALLPAPER {
            selectedImage = selectedImageWallpaper
        }
        
        // ダウンロード失敗
        if selectedImage == nil {
            if currentSegmented == SegmentedType.ICON {
                self.displayAlert(title: "No icon selected", message: "Select the icon you want to download")
                return
            } else if currentSegmented == SegmentedType.WALLPAPER {
                self.displayAlert(title: "No wallpaper selected", message: "Select the wallpaper you want to download")
                return
            }
        }
        
        // カメラロールへ保存
        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: selectedImage!)
        imageSaver.successHandler = {
            self.displayAlert(title: "Downloaded successfully!", message: nil)
        }
        imageSaver.errorHandler = {
             print("Oops: \($0.localizedDescription)")
            self.displayAlert(title: "Error", message: "Failed to save image.")
        }
        
        // リロード
        if currentSegmented == SegmentedType.ICON {
            self.selectedImageIcon = nil
            self.collectionView.reloadData()
        }
    }
    
    func setCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.headerReferenceSize = CGSize(width:100, height: 70)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        layout.scrollDirection = .vertical
        
        var statusBarHeight: CGFloat = CGFloat()
        let naviHeight = (self.navigationController?.navigationBar.frame.size.height)!
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        collectionView = UICollectionView(frame:CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - naviHeight - statusBarHeight), collectionViewLayout: layout)
        collectionView.register(UINib(nibName: "IconCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "iconCell")
        collectionView.backgroundColor = UIColor.clear
        collectionView.automaticallyAdjustsScrollIndicatorInsets = true
        collectionView.delegate = self
        collectionView.dataSource = self
        self.view.addSubview(collectionView)
        collectionView?.register(SectionHeader.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.identifier)
    }
}

// アイコン
extension DownloadViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
       }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var icons = 0
        switch section {
        case 0:
            icons = iconDetail.icons.Utilities.count
        case 1:
            icons = iconDetail.icons.SNS.count
        case 2:
            icons = iconDetail.icons.Entertainment.count
        case 3:
            icons = iconDetail.icons.Shopping.count
        case 4:
            icons = iconDetail.icons.Money.count
        case 5:
            icons = iconDetail.icons.Work.count
        case 6:
            icons = iconDetail.icons.Others.count
        default:
            break
        }
            return icons
        }
    
    // cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "iconCell", for: indexPath) as? IconCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        if cell.isSelected {
            cell.alpha = 0.3
        } else {
            cell.alpha = 1
        }
        
        var iconURL = URL(string: "")
        switch indexPath.section {
        case 0:
            iconURL = URL(string: iconDetail.icons.Utilities[indexPath.row])
        case 1:
            iconURL = URL(string: iconDetail.icons.SNS[indexPath.row])
        case 2:
            iconURL = URL(string: iconDetail.icons.Entertainment[indexPath.row])
        case 3:
            iconURL = URL(string: iconDetail.icons.Shopping[indexPath.row])
        case 4:
            iconURL = URL(string: iconDetail.icons.Money[indexPath.row])
        case 5:
            iconURL = URL(string: iconDetail.icons.Work[indexPath.row])
        case 6:
            iconURL = URL(string: iconDetail.icons.Others[indexPath.row])
        default:
            break
        }
       
            cell.iconImageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.iconImageView?.sd_setImage(with: iconURL)
       return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader else {
                   fatalError("Could not find proper header")
               }

        if kind == UICollectionView.elementKindSectionHeader {
            header.sectionLabel.text = categories[indexPath.section]
                   return header
               }

               return UICollectionReusableView()
    }
    
     // セルがタップされた時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! IconCollectionViewCell
        selectedImageIcon = cell.iconImageView?.image
   }
}

extension DownloadViewController: UICollectionViewDelegateFlowLayout {
    // セルの大きさ
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace : CGFloat = 15
        let cellSize : CGFloat = self.view.bounds.width / 4 - horizontalSpace
        return CGSize(width: cellSize, height: cellSize)
    }
}

// 壁紙
extension DownloadViewController: FSPagerViewDataSource, FSPagerViewDelegate {
    func setWallpapers() {
        pagerView = FSPagerView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 560))
        pagerView.layer.position = CGPoint(x: self.view.frame.width/2, y: self.view.frame.height/2 - 60)
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        self.view.addSubview(pagerView)
        pagerView.itemSize = CGSize(width: 300, height: 540)
        pagerView.transformer = FSPagerViewTransformer(type: .linear)
    }
    
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return iconDetail.wallpapers.count
    }
    
    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        let cell = pagerView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
        if let themeImageURL = URL(string: iconDetail?.wallpapers[index] ?? "") {
            cell.imageView?.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView?.sd_setImage(with: themeImageURL)
        }
        return cell
    }
    
    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        let cell = pagerView.cellForItem(at: index)
        let wallpaper = cell?.imageView?.image
        selectedImageWallpaper = wallpaper
    }
}

