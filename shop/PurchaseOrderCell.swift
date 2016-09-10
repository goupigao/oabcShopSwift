//
//  PurchaseOrderCell.swift
//  shop
//
//  Created by goupigao on 16/9/4.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class PurchaseOrderCell: UITableViewCell {
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var order: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        order.backgroundColor = MyColor.buttonBg
        order.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
