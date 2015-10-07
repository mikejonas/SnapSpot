//
//  DebugImagesTableViewCell.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 10/1/15.
//  Copyright © 2015 Mike Jonas. All rights reserved.
//

import UIKit

class DebugImagesTableViewCell: UITableViewCell {

    @IBOutlet weak var photo: UIImageView!
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var dimensionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
