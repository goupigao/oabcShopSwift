//
//  GoodsViewController.swift
//  shop
//
//  Created by goupigao on 16/9/2.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class GoodsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //MARK: 属性
    @IBOutlet weak var collectionView: UICollectionView!
    
    var typeId:Int = 0
    var typeName = ""
    var loadingGoods = false
    var hasNextGoodsPage = true
    var pageOfGoods:Int = -1
    var goodArray = Array<Good>()
    var cartArray = Array<Cart>()
    
    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        cartArray = loadCartArray()
        if goodArray.count == 0 {
            loadGoods()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    //MARK: collectionView
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return goodArray.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let cols = floor((collectionView.frame.size.width-16+10)/(147+10))
        let width = (collectionView.frame.size.width-16+10)/cols-10
        return CGSizeMake(width, 276-(176-width))
        //16是collectionView左右Section Insets的和
        //10是collectionView的Min Spacing For Cells
        //147是希望UICollectionViewCell显示的最小宽度
        //276和176分别是storyboard中UICollectionViewCell绘制的高度和宽度
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("goodsGoodCell", forIndexPath: indexPath) as! GoodsGoodCell
        if cell.id == 0 {
            cell.layer.borderWidth = 1
            cell.layer.borderColor = MyColor.grey.CGColor
            cell.layer.cornerRadius = 4
            cell.addButton.addTarget(self, action: #selector(GoodsViewController.addGoodToCart(_:)), forControlEvents: .TouchUpInside)
        }
        cell.id = goodArray[indexPath.row].id ?? 0
        cell.addButton.tag = goodArray[indexPath.row].id ?? 0
        cell.name.text = goodArray[indexPath.row].name
        cell.price.attributedText = NSAttributedString(string: "\(goodArray[indexPath.row].price)" ,attributes: [NSStrikethroughStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue])
        cell.couponPrice.text = "\(goodArray[indexPath.row].couponPrice)"
        cell.goodImage.image = nil
        cell.imageTask?.cancel()
        cell.imageTask = cell.goodImage.kf_setImageWithURL(NSURL(string: goodArray[indexPath.row].image_url)!, placeholderImage: nil, optionsInfo: nil, progressBlock: nil) { (image, error, cacheType, imageURL) in
            cell.imageTask = nil
        }
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: NSURL(string: self.goodArray[indexPath.row].image_url)!)
            dispatch_async(dispatch_get_main_queue(), {
                if data != nil && cell.id == self.goodArray[indexPath.row].id! {
                    cell.goodImage.image = UIImage(data: data!)
                }
            })
        }
        */
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSizeMake(collectionView.frame.size.width, 60)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let footView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "footCell", forIndexPath: indexPath) as! FootCell
        footView.label.frame = CGRectMake(0,0,collectionView.frame.width,60)
        footView.indicator.frame = CGRectMake(0,0,collectionView.frame.width,60)
        if hasNextGoodsPage {
            footView.label.hidden = true
            footView.indicator.hidden = false
            footView.indicator.startAnimating()
        }else{
            footView.label.hidden = false
            footView.indicator.stopAnimating()
            footView.indicator.hidden = true
        }
        return footView
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let viewController = self.storyboard?.instantiateViewControllerWithIdentifier("Good") as! GoodViewController
        viewController.hidesBottomBarWhenPushed = true
        viewController.good = goodArray[indexPath.row]
        self.navigationController?.showViewController(viewController, sender: nil)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.frame.size.height > scrollView.contentSize.height * 0.8 {
            loadGoods()
        }
    }
    
    //MARK: 初始化视图
    func setView() {
        self.title = typeName
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FootCell.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "footCell")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
    }
    
    //MARK: Action & Network
    func loadGoods() {
        if loadingGoods || !hasNextGoodsPage {
            return
        }
        loadingGoods = true
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/mbcMain.aspx?typeId=\(typeId)&page=\(pageOfGoods+1)").responseString { (response) in
            guard let html = response.result.value else {
                self.loadingGoods = false
                return
            }
            if response.result.error != nil {
                self.loadingGoods = false
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let nsHtml = html as NSString
                let lastItem = self.goodArray.count
                var rangeStart = 0
                var regular = try! NSRegularExpression(pattern: "<div class=\"ps_pic.*?src='(\\S*?)'.*?supplyId=(\\d*?)'.*?>(.*?)</a>.*?价格：￥([\\s\\d\\.]*?)</div>.*?会员价： ￥([\\s\\d\\.]*?)</div>", options:.DotMatchesLineSeparators)
                var results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                if results.count>0 {
                    rangeStart = results[results.count-1].range.location + results[results.count-1].range.length
                }
                for result in results {
                    let good = Good()
                    good.image_url = "http://shop.oabc.cc:88/zgMBFrontShopV2/\(nsHtml.substringWithRange(result.rangeAtIndex(1)))"
                    good.id = (nsHtml.substringWithRange(result.rangeAtIndex(2)) as NSString).integerValue
                    good.name = nsHtml.substringWithRange(result.rangeAtIndex(3)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    good.name = String(htmlEncodedString:good.name)
                    good.price = (nsHtml.substringWithRange(result.rangeAtIndex(4)) as NSString).doubleValue
                    good.couponPrice = (nsHtml.substringWithRange(result.rangeAtIndex(5)) as NSString).doubleValue
                    self.goodArray.append(good)
                }
                regular = try! NSRegularExpression(pattern: "上一页.*?</span>\\|([\\s\\d]*?)/([\\s\\d]*?)\\|", options:.DotMatchesLineSeparators)
                results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(rangeStart, html.characters.count-rangeStart))
                if results.count > 0 {
                    self.pageOfGoods = (nsHtml.substringWithRange(results[0].rangeAtIndex(1)) as NSString).integerValue - 1
                    self.hasNextGoodsPage = (nsHtml.substringWithRange(results[0].rangeAtIndex(2)) as NSString).integerValue - 1 > self.pageOfGoods
                }
                dispatch_async(dispatch_get_main_queue(), {
                    if self.pageOfGoods >= 0 {
                        if self.hasNextGoodsPage {
                            self.collectionView.insertItemsAtIndexPaths((lastItem..<self.goodArray.count).map { NSIndexPath(forItem: $0, inSection: 0) })
                        }else{
                            self.collectionView.reloadData()
                        }
                    }
                })
                self.loadingGoods = false
            }
        }
    }
    
    func addGoodToCart(sender: UIButton) {
        var uiview = sender as UIView
        while (!uiview.isKindOfClass(GoodsGoodCell)) {
            uiview = uiview.superview!
        }
        let cell = uiview as! GoodsGoodCell
        var edited = false
        for i in 0..<cartArray.count {
            if cartArray[i].goodId == cell.id {
                cartArray[i].count += 1
                edited = true
                break
            }
        }
        if !edited {
            cartArray.append(Cart(goodId: cell.id, name: cell.name.text!, count: 1, couponPrice: (cell.couponPrice.text! as NSString).doubleValue))
        }
        let plusOne = UIImageView(frame: CGRectMake(cell.addButton.frame.origin.x+5,cell.addButton.frame.origin.y-20,20,20))
        plusOne.image = UIImage(named: "plusOne")
        cell.addSubview(plusOne)
        UIView.animateWithDuration(0.6, delay: 0, options: [.CurveEaseInOut], animations: {
            plusOne.frame.origin.y = 0
            plusOne.alpha = 0
        }) { (true) in
            plusOne.removeFromSuperview()
        }
        saveCartArray()
    }
    
    func saveCartArray() {
        NSKeyedArchiver.archiveRootObject(cartArray, toFile: Cart.ArchiveURL.path!)
    }
    
    func loadCartArray() -> [Cart] {
        if let cartArray = NSKeyedUnarchiver.unarchiveObjectWithFile(Cart.ArchiveURL.path!) as? [Cart] {
            return cartArray
        }else{
            return Array<Cart>()
        }
    }
}

//MARK: collectionView
class FootCell: UICollectionReusableView {
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    let label = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        indicator.stopAnimating()
        indicator.hidden = true
        indicator.color = MyColor.greenDark
        addSubview(indicator)
        label.numberOfLines = 0
        label.textAlignment = .Center
        label.hidden = true
        label.text = "没有更多商品了"
        addSubview(label)
    }
}