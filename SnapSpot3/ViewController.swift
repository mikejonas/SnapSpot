//
//  ViewController.swift
//  SnapSpot3
//
//  Created by Mike Jonas on 7/26/15.
//  Copyright (c) 2015 Mike Jonas. All rights reserved.
//

import UIKit

//GLOBALS!!!
let pageController = ViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
let editSpotVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("EditSpotViewController") as! EditSpotViewController

class ViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
 
    let settingsVC = UIStoryboard(name: "Settings", bundle: nil).instantiateViewControllerWithIdentifier("SettingsNavController")
    let cameraVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("CameraNavController")
    let listSpotsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ListSpotsNavController")
    let filterSpotsVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("FilterSpotsNavController")

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
        let nextVC = pageViewController(self, viewControllerAfterViewController: viewControllers![0])!  //??? TOO MANY !'s
        setViewControllers([nextVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        
    }

    func goToPreviousVC() {
        let previousVC = pageViewController(self, viewControllerBeforeViewController: viewControllers![0])! //??? TOO MANY !'s
        setViewControllers([previousVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
    }
    
    
    // MARK: UIPageViewControllerDataSource
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        switch viewController {
        case filterSpotsVC:
            return listSpotsVC
        case listSpotsVC:
            return cameraVC
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
        case filterSpotsVC:
            return nil
        case listSpotsVC:
            return filterSpotsVC
        case cameraVC:
            return listSpotsVC
        case settingsVC:
            return cameraVC
        default:
            return nil
        }
    }
}
