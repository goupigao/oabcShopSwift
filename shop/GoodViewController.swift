//
//  GoodViewController.swift
//  shop
//
//  Created by goupigao on 16/9/7.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire

class GoodViewController: UIViewController {
    @IBOutlet weak var imageBox: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var guige: UILabel!
    @IBOutlet weak var couponPrice: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var bottomBorder: UIView!
    @IBOutlet weak var bottom: UIView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var count: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    
    var good = Good()
    var cartArray = Array<Cart>()

    override func viewDidLoad() {
        super.viewDidLoad()

        cartArray = loadCartArray()
        setView()
        loadGood()
        setAddButtonView()
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
    
    func setView() {
        self.title = good.name
        
        imageBox.layer.borderWidth = 1
        imageBox.layer.borderColor = MyColor.grey.CGColor
        imageBox.layer.cornerRadius = 8
        
        imageView.kf_setImageWithURL(NSURL(string: good.image_url)!)
        imageView.contentMode = .ScaleAspectFit
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let data = NSData(contentsOfURL: NSURL(string: self.good.image_url)!)
            dispatch_async(dispatch_get_main_queue(), {
                if let image = UIImage(data: data!) {
                    self.imageView.image = image
                    self.imageView.contentMode = .ScaleAspectFit
                }
            })
        }
        */
        
        tips.layer.borderWidth = 1
        tips.layer.borderColor = MyColor.grey.CGColor
        
        name.text = good.name
        couponPrice.text = "会员价：\(good.couponPrice)"
        
        bottomBorder.backgroundColor = MyColor.green
        bottom.backgroundColor = MyColor.greenDark
        addButton.backgroundColor = MyColor.green
        stepper.tintColor = UIColor.whiteColor()
        
    }
    
    func setAddButtonView() {
        var exist = false
        for cart in cartArray {
            if good.id! == cart.goodId {
                stepper.value = (Double)(cart.count)
                count.text = "数量：\(cart.count)"
                exist = true
            }
        }
        count.hidden = !exist
        stepper.hidden = !exist
        addButton.hidden = exist
        addButton.addTarget(self, action: #selector(addToCart), forControlEvents: .TouchUpInside)
        stepper.addTarget(self, action: #selector(modifyCart(_:)), forControlEvents: .ValueChanged)
    }
    
    func loadGood() {
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/mbcSupplyDetail.aspx",parameters: ["supplyId":"\(good.id!)"]).responseString { (response) in
            guard let html = response.result.value else { return }
            if response.result.error != nil { return }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                let nsHtml = html as NSString
                let regular = try! NSRegularExpression(pattern: "class=\"spec\">(.*?)</div>.*?cp_details_intro_text\">(.*?)</div>\\s*?<div class=\"tip2\">", options:.DotMatchesLineSeparators)
                let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
                if results.count>0 {
                    self.good.guige = nsHtml.substringWithRange(results[0].rangeAtIndex(1))
                    self.good.detail = nsHtml.substringWithRange(results[0].rangeAtIndex(2))
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.guige.text = self.good.guige
                    do{
                        let attrStr = try NSAttributedString(data: (self.good.detail.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!),
                            options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                        self.detail.attributedText = attrStr
                    }catch let error as NSError {
                        print(error.localizedDescription)
                        self.detail.text = self.good.detail.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                    }
                })
            }
        }
    }
    
    func addToCart() {
        cartArray.append(Cart(goodId: good.id! , name: good.name, count: 1 , couponPrice: good.couponPrice))
        saveCartArray()
        count.text = "数量：1"
        setAddButtonView()
    }
    
    func getCartIndexById(id: Int) -> Int? {
        var index:Int?
        for i in 0..<cartArray.count {
            if cartArray[i].goodId == good.id! {
                index = i
                break;
            }
        }
        return index
    }
    
    func modifyCart(stepper: UIStepper) {
        if let index = getCartIndexById(good.id!) {
            if stepper.value > 0 {
                cartArray[index].count = (Int)(stepper.value)
                count.text = "数量：\((Int)(stepper.value))"
                saveCartArray()
            }else{
                deleteFromCart(index)
            }
        }
    }
    
    func deleteFromCart(index:Int){
        cartArray.removeAtIndex(index)
        setAddButtonView()
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
