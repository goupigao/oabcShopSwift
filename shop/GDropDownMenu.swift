//
//  GDropDownMenu.swift
//  shop
//
//  Created by goupigao on 16/9/4.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

protocol GDropDownMenuDelegate {
    func gDropDownMenuDidSelect(tag:String, index:Int)
}

class GDropDownMenu: UIView,UITableViewDelegate,UITableViewDataSource {

    var items = Array<String>()
    var selectedIndex = -1
    var originTag = ""
    var selectedString:String?
    var origin = CGPointZero
    var size = CGSizeZero
    var boxView = UIView()
    var tableView = UITableView()
    var delegate:GDropDownMenuDelegate?
    
    init() {
        super.init(frame: UIScreen.mainScreen().bounds)
        //boxView.frame = frame
        boxView.layer.shadowColor = UIColor.grayColor().CGColor
        boxView.layer.shadowOffset = CGSizeMake(1,1)
        boxView.layer.shadowOpacity = 1
        boxView.layer.borderWidth = 1
        boxView.layer.borderColor = UIColor.blackColor().CGColor
        boxView.layer.cornerRadius = 5
        self.addSubview(boxView)
        //tableView.frame = CGRectMake(0,0,frame.width,frame.height)
        //items = ["a","b","c","d","a","b","c","d"]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 5
        boxView.addSubview(tableView)
        //解决UITableView的分割线不能全屏，靠左的问题
        //设置separatorInset(iOS7之后)
        if tableView.respondsToSelector(Selector("setSeparatorInset:")) {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        //设置layoutMargins(iOS8之后)
        if tableView.respondsToSelector(Selector("setLayoutMargins:")) {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func showDropper() {
        if selectedString != nil {
            for index in 0..<items.count {
                if items[index] == selectedString {
                    selectedIndex = index
                    break
                }
            }
        }
        boxView.frame.origin = origin
        boxView.frame.size = size
        tableView.frame.origin = CGPointZero
        tableView.frame.size = size
        tableView.reloadData()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        clear()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("dropCell")
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: "dropCell")
        }
        if selectedIndex == indexPath.row {
            cell?.accessoryView = UIImageView(image: UIImage(named: "check"))
        }else{
            cell?.accessoryView = nil
        }
        cell?.textLabel!.text = items[indexPath.row]
        cell?.selectionStyle = .None
        return cell!
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //解决UITableView的分割线不能全屏，靠左的问题
        //设置separatorInset(iOS7之后)
        if cell.respondsToSelector(Selector("setSeparatorInset:")) {
            cell.separatorInset = UIEdgeInsetsZero
        }
        //设置layoutMargins(iOS8之后)
        if cell.respondsToSelector(Selector("setLayoutMargins:")) {
            cell.layoutMargins = UIEdgeInsetsZero
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let myDelegate = self.delegate{
            myDelegate.gDropDownMenuDidSelect(originTag, index: indexPath.row)
        }
        clear()
    }
    
    func clear() {
        originTag = ""
        selectedIndex = 0
        selectedString = nil
        self.removeFromSuperview()
    }

}

class GDropCell:UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style:style, reuseIdentifier:reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
