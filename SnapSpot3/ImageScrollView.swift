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
    var testView = UIView()
    var pageControl = UIPageControl()
    var pageViews: [UIImageView?] = []

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initScrollView()
    }
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initScrollView()
    }

    func initScrollView() {
        scrollView.delegate = self
        scrollView.pagingEnabled = true
//        scrollView.alwaysBounceHorizontal = true
        scrollView.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        self.addSubview(scrollView)
        self.addSubview(pageControl)
        pageControl.frame = CGRectMake(self.frame.width / 2, self.frame.height - 10, pageControl.bounds.width, pageControl.bounds.height)
    }
    
    func setupWithImages(images:[UIImage]) {
        // 0
        pageControl.currentPage = 0
        pageControl.numberOfPages = images.count
        
        // 1
        for _ in 0..<images.count {
            pageViews.append(nil)

        }
        
        // 2
        let pagesScrollViewSize = scrollView.frame.size
        scrollView.contentSize = CGSizeMake(pagesScrollViewSize.width * CGFloat(images.count), pagesScrollViewSize.height)
        
        // 3
        loadPages(images)
    }
    
    func loadPage(page: Int, images:[UIImage]) {
        // 1
        var frame = scrollView.bounds
        frame.origin.x = frame.size.width * CGFloat(page)
        frame.origin.y = 0.0
        
        // 2
        let newPageView = UIImageView(image: images[page])
        newPageView.contentMode = .ScaleAspectFit
        newPageView.frame = frame
        scrollView.addSubview(newPageView)
        
        // 3
        pageViews[page] = newPageView
    }
    func loadPages(images:[UIImage]) {
        // Load pages in our range
        for i in 0 ..< images.count {
            loadPage(i, images: images)
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
