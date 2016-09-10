//
//  EditAddressViewController.swift
//  shop
//
//  Created by goupigao on 16/9/5.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire
import ToastSwiftFramework

class EditAddressViewController: UIViewController,UITextFieldDelegate,UITextViewDelegate,GDropDownMenuDelegate {
    //MARK: 属性
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var province: UIButton!
    @IBOutlet weak var city: UIButton!
    @IBOutlet weak var cityZone: UIButton!
    @IBOutlet weak var address: UITextView!
    @IBOutlet weak var mobile: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var newAndSaveAddress: UIButton!
    var gDropDownMenu = GDropDownMenu()

    var purchaseForm = PurchaseForm()

    //MARK: 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.purchaseForm = purchaseForm
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    //MARK: 输入
    func keyboardWillShow(aNotification: NSNotification) {
        let keyboardRect = (aNotification.userInfo! as NSDictionary).objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue()
        if let height = keyboardRect?.size.height {
            self.scrollView.contentInset.bottom = height
            //self.scrollView.scrollIndicatorInsets.bottom = height
            if address.isFirstResponder() {
                let offset = height - (scrollView.frame.height - address.frame.origin.y - address.frame.height)
                if offset > 0 {
                    self.scrollView.setContentOffset(CGPointMake(0, offset), animated: true)
                }
            }
        }
    }
    
    func keyboardWillHide(aNotification: NSNotification) {
        self.scrollView.contentInset.bottom = 0
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === name {
            address.becomeFirstResponder()
        }else if textField === mobile {
            phone.becomeFirstResponder()
        }else if textField === phone {
            phone.resignFirstResponder()
        }
        return true
    }
    
    //MARK: 下拉菜单
    func gDropDownMenuDidSelect(tag: String, index: Int) {
        if tag == "province" && purchaseForm.provinceArray[index] != purchaseForm.province {
            purchaseForm.province = purchaseForm.provinceArray[index]
            province.setTitle(purchaseForm.province, forState: .Normal)
            purchaseForm.cityArray = Array<String>()
            purchaseForm.city = "请选择"
            city.setTitle("请选择", forState: .Normal)
            city.enabled = false
            purchaseForm.zoneArray = Array<String>()
            purchaseForm.zone = "请选择"
            cityZone.setTitle("请选择", forState: .Normal)
            cityZone.enabled = false
            Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/MyHandler.ashx",parameters: ["myCmmd":"getProvinceCity","province":purchaseForm.province]).responseString { (response) in
                guard let html = response.result.value else { return }
                if response.result.error != nil { return }
                dispatch_async(dispatch_get_main_queue(), {
                    if html.rangeOfString("OKOK") != nil {
                        self.purchaseForm.cityArray = html.componentsSeparatedByString("|")
                        self.purchaseForm.cityArray[0] = "请选择"
                        self.city.enabled = true
                    }
                })
            }
        }else if tag == "city" && purchaseForm.cityArray[index] != purchaseForm.city {
            purchaseForm.city = purchaseForm.cityArray[index]
            city.setTitle(purchaseForm.city, forState: .Normal)
            purchaseForm.zoneArray = Array<String>()
            purchaseForm.zone = "请选择"
            cityZone.setTitle("请选择", forState: .Normal)
            cityZone.enabled = false
            Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/MyHandler.ashx",parameters: ["myCmmd":"getCityZone2","province":purchaseForm.province,"city":purchaseForm.city]).responseString { (response) in
                guard let html = response.result.value else { return }
                if response.result.error != nil { return }
                dispatch_async(dispatch_get_main_queue(), {
                    if html.rangeOfString("OKOK") != nil {
                        self.purchaseForm.zoneArray = html.componentsSeparatedByString("|")
                        self.purchaseForm.zoneArray[0] = "请选择"
                        self.cityZone.enabled = true
                    }
                })
            }
        }else if tag == "zone" && purchaseForm.zoneArray[index] != purchaseForm.zone {
            purchaseForm.zone = purchaseForm.zoneArray[index]
            cityZone.setTitle(purchaseForm.zone, forState: .Normal)
        }
    }
    
    //MARK: 初始化视图
    func setView() {
        self.title = purchaseForm.name != "" ? "编辑地址" : "新增地址"
        name.text = purchaseForm.name
        name.delegate = self
        
        province.layer.borderWidth = 1
        province.layer.borderColor = MyColor.grey.CGColor
        province.layer.cornerRadius = 5
        province.tintColor = UIColor.blackColor()
        province.setTitle(purchaseForm.province, forState: .Normal)
        province.setImage(UIImage(named: "unfold"), forState: .Normal)
        var imageWidth = province.imageView!.bounds.size.width
        province.imageEdgeInsets = UIEdgeInsetsMake(0,province.frame.width-imageWidth-10, 0, 10+imageWidth-province.frame.width)
        province.titleEdgeInsets = UIEdgeInsetsMake(0, 10-imageWidth, 0, imageWidth)
        province.addTarget(self, action: #selector(dropDownMenu(_:)), forControlEvents: .TouchUpInside)
        
        city.layer.borderWidth = 1
        city.layer.borderColor = MyColor.grey.CGColor
        city.layer.cornerRadius = 5
        city.tintColor = UIColor.blackColor()
        city.setTitle(purchaseForm.city != "" ? purchaseForm.city : "请选择", forState: .Normal)
        city.setImage(UIImage(named: "unfold"), forState: .Normal)
        imageWidth = city.imageView!.bounds.size.width
        city.imageEdgeInsets = UIEdgeInsetsMake(0,city.frame.width-imageWidth-10, 0, 10+imageWidth-city.frame.width)
        city.titleEdgeInsets = UIEdgeInsetsMake(0, 10-imageWidth, 0, imageWidth)
        city.addTarget(self, action: #selector(dropDownMenu(_:)), forControlEvents: .TouchUpInside)
        
        cityZone.layer.borderWidth = 1
        cityZone.layer.borderColor = MyColor.grey.CGColor
        cityZone.layer.cornerRadius = 5
        cityZone.tintColor = UIColor.blackColor()
        cityZone.setTitle(purchaseForm.zone != "" ? purchaseForm.zone : "请选择", forState: .Normal)
        cityZone.setImage(UIImage(named: "unfold"), forState: .Normal)
        imageWidth = cityZone.imageView!.bounds.size.width
        cityZone.imageEdgeInsets = UIEdgeInsetsMake(0,cityZone.frame.width-imageWidth-10, 0, 10+imageWidth-cityZone.frame.width)
        cityZone.titleEdgeInsets = UIEdgeInsetsMake(0, 10-imageWidth, 0, imageWidth)
        cityZone.addTarget(self, action: #selector(dropDownMenu(_:)), forControlEvents: .TouchUpInside)
        
        gDropDownMenu.delegate = self
        
        address.text = purchaseForm.address
        address.layer.borderWidth = 1
        address.layer.borderColor = MyColor.grey.CGColor
        address.layer.cornerRadius = 5
        address.delegate = self
        
        mobile.text = purchaseForm.mobile
        mobile.delegate = self
        
        phone.text = purchaseForm.phone
        phone.delegate = self
        
        newAndSaveAddress.backgroundColor = MyColor.buttonBg
        newAndSaveAddress.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        newAndSaveAddress.addTarget(self, action: #selector(saveAddress), forControlEvents: .TouchUpInside)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    //MARK: Action & Network
    func dropDownMenu(sender: UIButton) {
        if sender === province {
            gDropDownMenu.items = purchaseForm.provinceArray
            gDropDownMenu.selectedString = purchaseForm.province
            gDropDownMenu.originTag = "province"
        }else if sender === city {
            gDropDownMenu.items = purchaseForm.cityArray
            gDropDownMenu.selectedString = purchaseForm.city
            gDropDownMenu.originTag = "city"
        }else if sender === cityZone {
            gDropDownMenu.items = purchaseForm.zoneArray
            gDropDownMenu.selectedString = purchaseForm.zone
            gDropDownMenu.originTag = "zone"
        }
        let x = scrollView.frame.origin.x + sender.frame.origin.x
        var y = scrollView.frame.origin.y + sender.frame.origin.y + sender.frame.height - scrollView.contentOffset.y
        let height = (CGFloat)(gDropDownMenu.items.count < 5 ? gDropDownMenu.items.count*44 : 200)
        let visibleHeight = scrollView.frame.height + scrollView.frame.origin.y
        if y + height > visibleHeight {
            y = visibleHeight - height
        }
        gDropDownMenu.origin = CGPointMake(x, y)
        gDropDownMenu.size = CGSizeMake(200, height)
        gDropDownMenu.showDropper()
        self.view.addSubview(gDropDownMenu)
    }
    
    func saveAddress() {
        let alert = UIAlertController(title: "请稍等", message: nil, preferredStyle: .Alert)
        self.presentViewController(alert, animated: true, completion: nil)
        var parameters = ["__VIEWSTATE":purchaseForm.viewState, "__EVENTVALIDATION":purchaseForm.eventValidation, "ctl00$ContentPlaceHolder1$TBN_SetAddress.x":"52", "ctl00$ContentPlaceHolder1$TBN_SetAddress.y":"29"]
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$TBX_Name"] = name.text ?? ""
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$pcz$DDL_Province"] = province.titleLabel?.text ?? ""
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$pcz$sel_city"] = city.titleLabel?.text ?? ""
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$pcz$sel_zone"] = cityZone.titleLabel?.text ?? ""
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$TBX_Address"] = address.text ?? ""
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$TBX_Mobile"] = mobile.text ?? ""
        parameters["ctl00$ContentPlaceHolder1$ucReceiverAddrEdit1$TBX_Phone"] = phone.text ?? ""
        if self.title == "新增地址" {
            parameters["ctl00$ContentPlaceHolder1$Chk_AddNewAddr"] = "on"
        }
        Alamofire.request(.POST, "http://shop.oabc.cc:88/zgMBFrontShopV2/ShoppingConfirm.aspx",parameters: parameters).responseString { (response) in
            guard let html = response.result.value else {
                alert.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            if response.result.error != nil {
                alert.dismissViewControllerAnimated(true, completion: nil)
                return
            }
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
                self.purchaseForm = OabcApi.parsePurchaseForm(html)
                alert.dismissViewControllerAnimated(true, completion: nil)
                //popViewControllerAnimated貌似和UIAlertController有冲突，放在同一个线程中，可能出现popViewControllerAnimated失效
                dispatch_async(dispatch_get_main_queue(), {
                    if self.purchaseForm.editAddressResult == "操作成功" {
                        if self.presentingViewController == nil {
                            self.navigationController?.popViewControllerAnimated(true)
                            //调用UINavigationController的popViewControllerAnimated方法退出
                        }else {
                            self.dismissViewControllerAnimated(true, completion: nil)
                            //调用dismissViewControllerAnimated方法退出；
                        }
                    }else{
                        self.view.makeToast(self.purchaseForm.editAddressResult)
                    }
                })
            })
        }
    }

}
