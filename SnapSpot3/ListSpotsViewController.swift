//
//  ListSpotsViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

class ListSpotsViewController: UIViewController {
    var pageMenu : CAPSPageMenu?
    let listSpotsCollectionVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsCollectionViewController") as! ListSpotsCollectionViewController
    let ListSpotsTableVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsTableViewController") as! ListSpotsTableViewController
    let ListSpotsMapVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsMapViewController") as! ListSpotsMapViewController
    
    var buttonImage = UIImage(named: "Nav Hashtag")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//    var rightButton = UIButton()
    
    override func viewWillAppear(animated: Bool) {

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        
        var controllerArray : [UIViewController] = []
        

        listSpotsCollectionVC.title = String.fontAwesomeIconWithName(.ThLarge)
        controllerArray.append(listSpotsCollectionVC)
        
        ListSpotsTableVC.title = String.fontAwesomeIconWithName(.Navicon)
        controllerArray.append(ListSpotsTableVC)
        
        ListSpotsMapVC.title = String.fontAwesomeIconWithName(.MapMarker)
        controllerArray.append(ListSpotsMapVC)

        
        
        // Customize menu (Optional)
        var parameters: [CAPSPageMenuOption] = [
            .MenuItemSeparatorWidth(0),
            .ScrollMenuBackgroundColor(UIColor.whiteColor()),
            .ViewBackgroundColor(UIColor(red: 247.0/255.0, green: 247.0/255.0, blue: 247.0/255.0, alpha: 1.0)),
            .BottomMenuHairlineColor(UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 20.0/255.0, alpha: 0.1)),
            .SelectionIndicatorColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .MenuMargin(20.0),
            .MenuHeight(37.0),
            .SelectedMenuItemLabelColor(UIColor(red: 18.0/255.0, green: 150.0/255.0, blue: 225.0/255.0, alpha: 1.0)),
            .UnselectedMenuItemLabelColor(UIColor(red: 100.0/255.0, green: 100.0/255.0, blue: 100.0/255.0, alpha: 1.0)),
            .MenuItemFont(UIFont.fontAwesomeOfSize(21)),
            .UseMenuLikeSegmentedControl(true),
            .MenuItemSeparatorRoundEdges(false),
            .SelectionIndicatorHeight(2.0),
            .MenuItemSeparatorPercentageHeight(0),
            .ScrollAnimationDurationOnMenuItemTap(100)
        ]
        
        // Initialize scroll menu
        pageMenu = CAPSPageMenu(viewControllers: controllerArray, frame: CGRectMake(0.0, 0.0, self.view.frame.width, self.view.frame.height), pageMenuOptions: parameters)
        
        // Optional delegate
        pageMenu!.delegate = self
        

        self.view.addSubview(pageMenu!.view)
        
    }
    

    
    override func viewDidAppear(animated: Bool) {
        println("LIST SPOTS VIEW CONTROLLER APPEARED!")
        listSpotsCollectionVC.collectionViewTestReloadData()
        
        let hashtagString = ", #".join(Globals.variables.filterSpotsHashtag)
        println(hashtagString)
        if hashtagString == "" {
            self.navigationController?.navigationBar.topItem?.title = "Spots"
        } else {
            self.navigationController?.navigationBar.topItem?.title
            self.navigationController?.navigationBar.topItem?.title = "#\(hashtagString)"
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func leftBarButtonItemTapped(sender: UIBarButtonItem) {
        pageController.goToPreviousVC()
//        pageMenu!.moveToPage(2)
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

extension ListSpotsViewController: CAPSPageMenuDelegate {
    func willMoveToPage(controller: UIViewController, index: Int) {
        if index == 0 {
            println("0")
        }
        if index == 1 {
            println("1")
        }
        if index == 2 {
            println("2")
        }
    }
}
