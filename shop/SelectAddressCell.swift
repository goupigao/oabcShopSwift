//
//  SelectAddressCell.swift
//  shop
//
//  Created by goupigao on 16/9/5.
//  Copyright © 2016年 goupigao. All rights reserved.
//

import UIKit

class SelectAddressCell: UITableViewCell {
    @IBOutlet weak var radio: UIImageView!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var edit: UIButton!
    @IBOutlet weak var delete: UIButton!
    var index:Int = -1

    override func awakeFromNib() {
        super.awakeFromNib()
        edit.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12)
        delete.contentEdgeInsets = UIEdgeInsetsMake(8, 12, 8, 12)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}


