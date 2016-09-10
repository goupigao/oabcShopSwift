//
//  LoginViewController.swift
//  shop
//
//  Created by goupigao on 16/8/31.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit
import Alamofire
import ToastSwiftFramework

class LoginViewController: UIViewController,UITextFieldDelegate {
    //MARK: 属性
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var cardNo: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var getCode: UITextField!
    @IBOutlet weak var codeButton: UIButton!
    
    var viewState:String?
    var eventValidation:String?
    var getCodeOp:NSOperation?
    var opQueue:NSOperationQueue?
    var loginRuquest:Alamofire.Request?
    var msg:String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setView()
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
    
    //MARK: 输入
    func keyboardWillShow(aNotification: NSNotification) {
        let keyboardRect = (aNotification.userInfo! as NSDictionary).objectForKey(UIKeyboardFrameEndUserInfoKey)?.CGRectValue()
        if let height = keyboardRect?.size.height {
            UIView.animateWithDuration(0.5, animations: {
                self.scrollView.contentInset.bottom = height
                //storyboard中srcrollView的容器子view（即这里的Box View）的约束必须设置为leading，trailing，不能设置为equal width，否则会出现键盘弹出时，无法自动定位到当前输入框的问题（tell me why~~~）
                }, completion: nil)
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField === cardNo {
            password.becomeFirstResponder()
        }else if textField === password {
            getCode.becomeFirstResponder()
        }else if textField === getCode {
            getCode.resignFirstResponder()
            login()
        }
        return true
    }
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        UIView.animateWithDuration(0.5, animations: {
            self.scrollView.contentInset.bottom = 0
            }, completion: nil)
        return true
    }
    
    //MARK: 初始化视图
    func setView(){
        boxView.layer.borderWidth = 1
        boxView.layer.borderColor = MyColor.grey.CGColor
        boxView.layer.cornerRadius = 8
        loginButton.backgroundColor = MyColor.buttonBg
        loginButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        cardNo.returnKeyType = .Next
        password.returnKeyType = .Next
        getCode.returnKeyType = .Done
        cardNo.delegate = self
        password.delegate = self
        getCode.delegate = self
        loginButton.addTarget(self, action: #selector(login), forControlEvents: .TouchUpInside)
        codeButton.addTarget(self, action: #selector(loadCode), forControlEvents: .TouchUpInside)
        
        opQueue = NSOperationQueue()
        
        let centerDefault = NSNotificationCenter.defaultCenter()
        centerDefault.addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        
        Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/zgcMBLogin.aspx").responseString { (response) in
            guard let html = response.result.value else { return }
            if response.result.error != nil { return }
            let regular = try! NSRegularExpression(pattern: "__VIEWSTATE\" value=\"(.*?)\".*?__EVENTVALIDATION\" value=\"(.*?)\"", options:.DotMatchesLineSeparators)
            let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
            if results.count > 0 {
                self.viewState = (html as NSString).substringWithRange(results[0].rangeAtIndex(1))
                self.eventValidation = (html as NSString).substringWithRange(results[0].rangeAtIndex(2))
            }
            self.loadCode()
        }
    }
    
    func loadCode(){
        if getCodeOp != nil {
            getCodeOp?.cancel()
        }
        getCodeOp = NSBlockOperation(block: { 
            let data = NSData(contentsOfURL: NSURL(string: "http://shop.oabc.cc:88/zgMBFrontShopV2/VerifyImage.aspx?t=\(random())")!)
            dispatch_async(dispatch_get_main_queue(), {
                guard let data = data else {return}
                self.codeButton.setBackgroundImage(UIImage(data: data), forState: .Normal)
            })
        })
        opQueue?.addOperation(getCodeOp!)
    }
    
    func login(){
        loginRuquest?.cancel()
        loginRuquest = Alamofire.request(.GET, "http://shop.oabc.cc:88/zgMBFrontShopV2/zgcMBLogin.aspx",parameters: ["ucMBLogin1$UserName":cardNo.text ?? "","ucMBLogin1$Password":password.text ?? "","ucMBLogin1$GetCode":getCode.text ?? "","ucMBLogin1$LoginButton.x":"51","ucMBLogin1$LoginButton.y":"16","__VIEWSTATE":viewState!,"__EVENTVALIDATION":eventValidation!]).responseString { (response) in
            guard let html = response.result.value else { return }
            if response.result.error != nil { return }
            let regular = try! NSRegularExpression(pattern: "colspan=\"2\"  style=\"color: red\">(.*?)</td>", options:.DotMatchesLineSeparators)
            let results = regular.matchesInString(html, options: .ReportProgress , range: NSMakeRange(0, html.characters.count))
            if results.count > 0 {
                let msg = (html as NSString).substringWithRange(results[0].rangeAtIndex(1)).stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                if msg == "" {
                    AppDelegate.logged = true
                    if self.presentingViewController == nil {
                        self.navigationController?.popViewControllerAnimated(true)
                        //调用UINavigationController的popViewControllerAnimated方法退出
                    }else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                        //调用dismissViewControllerAnimated方法退出；
                    }
                }else{
                    self.view.makeToast(msg)
                }
            }
        }
    }

}
