//
//  SearchLocationTableViewCell.swift
//  SnapSpotGoogleMaps
//
//  Created by Mike Jonas on 6/22/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class LocationSearchCell: UITableViewCell {
    
//    class var reuseIdentifier: String {
//        get {
//            return "SearchLocationTableViewCell"
//        }
//    }
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.Subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

}
