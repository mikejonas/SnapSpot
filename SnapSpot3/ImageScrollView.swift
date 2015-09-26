//
//  imageScrollView.swift
//  ScrollViews
//
//  Created by Mike Jonas on 8/13/15.
//  Copyright (c) 2015 Skyrocket Software. All rights reserved.
//

import UIKit

class ImageScrollView: UIView, UIScrollViewDelegate {
    
    var scrollView = UIScrollView()
    var pageControl = UIPageControl()
    var pageViews: [UIImageView?] = []
    var images: [UIImage]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initScrollView()
    }
    


    func initScrollView() {
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.blackColor()
        scrollView.pagingEnabled = true
//        scrollView.alwaysBounceHorizontal = true
        self.addSubview(scrollView)
        self.addSubview(pageControl)
   
        print(pageControl.bounds.width)
    }
    
    func setupWithImages(images:[UIImage], width:CGFloat) {
        self.images = images
        setupView(width)
        
    }
    func setupView(width:CGFloat) {
        scrollView.frame = CGRectMake(0, 0, width, width)
        pageControl.frame = CGRectMake(width / 2, width - 10, 0, 0)
        
        if let images = images {
            // 0
            pageControl.currentPage = 0
            pageControl.numberOfPages = images.count
            if images.count <= 1 { pageControl.hidden = true }
            
            // 1
            for _ in 0..<images.count {
                pageViews.append(nil)
                
            }
            // 2
            scrollView.contentSize = CGSizeMake(width * CGFloat(images.count), width)
            
            loadPages()
        }
    }
    
    func loadPage(page: Int) {
        // 1
        var frame = scrollView.frame
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        
        // 2
        let newPageView = UIImageView(image: images![page])
        newPageView.contentMode = .ScaleAspectFit
        newPageView.frame = frame
        scrollView.addSubview(newPageView)
        
        // 3
        pageViews[page] = newPageView
    }
    func loadPages() {
        // Load pages in our range
        for i in 0 ..< images!.count {
            loadPage(i)
        }
    }
    
    func updatePager() {
        // First, determine which page is currently visible
        let pageWidth = scrollView.frame.size.width
        let page = Int(floor((scrollView.contentOffset.x * 2.0 + pageWidth) / (pageWidth * 2.0)))
        
        // Update the page control
        pageControl.currentPage = page
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Load the pages that are now on screen
        updatePager()
    }
    
}
