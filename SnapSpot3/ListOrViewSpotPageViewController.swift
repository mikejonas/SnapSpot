//
//  ListOrViewSpotPageViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 8/5/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

let verticalPageController = ViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Vertical, options: nil)

class ListOrViewSpotPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    let listSpotsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsViewController") as! UIViewController
    let ViewSpot2VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewSpot2ViewController") as! UIViewController

    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        setViewControllers([listSpotsVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setViewControllers([listSpotsVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
        delegate = self
        dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case ViewSpot2VC:
            return listSpotsVC
        case listSpotsVC:
            return nil
        default:
            return nil
        }
        
    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case listSpotsVC:
            return ViewSpot2VC
        case ViewSpot2VC:
            return nil
        default:
            return nil
        }
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
