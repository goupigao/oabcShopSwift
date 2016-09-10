//
//  OrderOrderCell.swift
//  shop
//
//  Created by goupigao on 16/9/1.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class OrderOrderCell: UITableViewCell {
    @IBOutlet weak var orderNo: UILabel!
    @IBOutlet weak var orderPrice: UILabel!
    @IBOutlet weak var payPrice: UILabel!
    @IBOutlet weak var createTime: UILabel!
    @IBOutlet weak var deliveryTime: UILabel!
    @IBOutlet weak var orderState: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
