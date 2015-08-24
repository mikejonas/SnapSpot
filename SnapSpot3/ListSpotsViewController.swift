//
//  ListSpotsViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class ListSpotsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var VCIDs : [String] = ["ListSpotsCollectionViewController", "ListSpotsTableViewController", "ListSpotsMapViewController"]
        var buttonTitles : [String] = ["Collection", "Table", "Map"]
        let swiftPagesView : SwiftPages!
        swiftPagesView = SwiftPages(frame: CGRectMake(0, 0, self.view.frame.width, self.view.frame.height))
        swiftPagesView.initializeWithVCIDsArrayAndButtonTitlesArray(VCIDs, buttonTitlesArray: buttonTitles)
        swiftPagesView.backgroundColor = UIColor.whiteColor()
        swiftPagesView.setTopBarHeight(34)
        swiftPagesView.enableBarShadow(false)
        swiftPagesView.setButtonsTextFontAndSize(UIFont(name: "Helvetica Neue", size: 13)!)
        self.view.addSubview(swiftPagesView)
        self.automaticallyAdjustsScrollViewInsets = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToPreviousVC()
    }
    @IBAction func rightBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToNextVC()
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
