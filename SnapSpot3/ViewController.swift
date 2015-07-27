//
//  ViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

let pageController = ViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)

class ViewController: UIPageViewController, UIPageViewControllerDataSource {

    let cameraVC: UIViewController! = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CameraNavController") as! UIViewController
    let settingsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavController") as! UIViewController

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        view.backgroundColor = UIColor.whiteColor()
        dataSource = self
        setViewControllers([cameraVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func goToNextVC() {
        let nextVC = pageViewController(self, viewControllerAfterViewController: viewControllers[0] as! UIViewController)!
        setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }

    func goToPreviousVC() {
        println(viewControllers)
        let previousVC = pageViewController(self, viewControllerBeforeViewController: viewControllers[0] as! UIViewController)!
        setViewControllers([previousVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
    }
    
    
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case cameraVC:
            return settingsVC
        case settingsVC:
            return nil
        default:
            return nil
        }

    }
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        switch viewController {
        case cameraVC:
            return nil
        case settingsVC:
            return cameraVC
        default:
            return nil
        }
    }
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
