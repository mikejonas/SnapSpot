//
//  UITextField+Extension.swift
//  textViewSample
//
//  Created by Robert Chen on 5/22/15.
//  Copyright (c) 2015 Thorn Technologies. All rights reserved.
//


// FIX ThIS FILE, MACH RANGE DOES NOTHING. CHECK THE GITHUB VERSION...


import UIKit

extension UITextView {
    
    func resolveHashTags(){
        
        // turn string in to NSString
        let nsText:NSString = self.text
        
        // this needs to be an array of NSString.  String does not work.
        let words:[String] = nsText.componentsSeparatedByString(" ")   //???? THIS SHOULDN't WORK ????
        
        // you can't set the font size in the storyboard anymore, since it gets overridden here.
        let attrs = [
            NSFontAttributeName : UIFont.systemFontOfSize(16.0)
        ]
        
        // you can staple URLs onto attributed strings
        let attrString = NSMutableAttributedString(string: nsText as String, attributes:attrs)
        
        // tag each word if it has a hashtag
        for word in words {
            
            // found a word that is prepended by a hashtag!
            if word.hasPrefix("#") {
                
                // a range is the character position, followed by how many characters are in the word.
                // we need this because we staple the "href" to this range.
                let matchRange:NSRange = nsText.rangeOfString(word as String)
                
                // convert the word from NSString to String
                // this allows us to call "dropFirst" to remove the hashtag
                var stringifiedWord:String = word as String
                
                // drop the hashtag
                stringifiedWord = String(stringifiedWord.characters.dropFirst())  //???
                // check to see if the hashtag has numbers.
                // ribl is "#1" shouldn't be considered a hashtag.
                let digits = NSCharacterSet.decimalDigitCharacterSet()
                
                if let numbersExist = stringifiedWord.rangeOfCharacterFromSet(digits) {
                    // hashtag contains a number, like "#1"
                    // so don't make it clickable
                    print("Don't make this( \(numbersExist) ) clickable")
                } else {
                    // set a link for when the user clicks on this word.
                    // it's not enough to use the word "hash", but you need the url scheme syntax "hash://"
                    // note:  since it's a URL now, the color is set to the project's tint color
                    attrString.addAttribute(NSLinkAttributeName, value: "hash:\(stringifiedWord)", range: matchRange)
                }
                
            }
        }
        
        // we're used to textView.text
        // but here we use textView.attributedText
        // again, this will also wipe out any fonts and colors from the storyboard,
        // so remember to re-add them in the attrs dictionary above
        self.attributedText = attrString
    }
    
    func appendAttributedText(string:String, attributes:[String: NSObject]) {
        
        let newText = NSMutableAttributedString()
        let newLine = NSMutableAttributedString(string: "\n")
        
        //Get original text
        let originalText = NSMutableAttributedString(attributedString: self.attributedText)

        //Append attributes to new Text
        let appendedString = NSAttributedString(string: string, attributes: attributes)

        //Append new
        newText.appendAttributedString(originalText)
        if originalText.length > 0 {
            newText.appendAttributedString(newLine)
        }
        newText.appendAttributedString(appendedString)
        
        
        // Define paragraph styling
        let paraStyle = NSMutableParagraphStyle()
        paraStyle.paragraphSpacing = 10.0
        let paraAttrs = [NSParagraphStyleAttributeName : paraStyle]
        newText.addAttributes(paraAttrs, range: NSMakeRange(0, newText.length))
        self.attributedText = newText
    }
    
    func extractHashTags( completion:(extractedHashtags:[String]) -> Void ){
        
        // turn string in to NSString
        let nsText:NSString = self.text
        
        // this needs to be an array of NSString.  String does not work.
        let words:[String] = nsText.componentsSeparatedByString(" ")  //???? THIS SHOULDN't WORK ????
        
        // Array of extracted hashtags (maybe make this a string)
        var extractedHashtags:[String] = []
        
        for word in words {

            if word.hasPrefix("#") {

                // a range is the character position, followed by how many characters are in the word.
                // we need this because we staple the "href" to this range.
                let matchRange:NSRange = nsText.rangeOfString(word as String)
                
                // convert the word from NSString to String
                var stringifiedWord:String = word as String
                
                // drop the hashtag
                stringifiedWord = String(stringifiedWord.characters.dropFirst())  //???
            
                extractedHashtags.append(stringifiedWord)
            }
        }
        
        completion(extractedHashtags: extractedHashtags)
        
    }

    
}