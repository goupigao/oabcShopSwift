//
//  OrderContactCell.swift
//  shop
//
//  Created by goupigao on 16/9/1.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class OrderContactCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var postCode: UILabel!
    @IBOutlet weak var mobile: UILabel!
    @IBOutlet weak var phone: UILabel!
    var test: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
