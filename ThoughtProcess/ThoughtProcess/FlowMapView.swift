//
//  FlowMapView.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/8/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

struct FontType {
    var name: String
    var value: Int
    var type: UIFont
}

struct FontColor {
    var name: String
    var value: Int
    var type: UIColor
}

struct TextViewBackgroundColor {
    var name: String
    var value: Int
    var type: UIColor
}

protocol MindMapSectionProtocol {
    
}

class ArrowView: UIView {
    
    var delegate: ViewAndEditViewController?
    var textView: UITextView?
    var selectedText: String = ""
    var viewColor = UIColor.gray {
        didSet {
            self.setNeedsDisplay()
        }
    }
   
    var fontType: FontType = FontType(name: "Body", value: 0, type: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)) {
        didSet {
            self.textView?.font = fontType.type
        }
    }
    var fontColor: FontColor = FontColor(name: "Light Gray", value: 5, type: UIColor.lightGray) {
        didSet {
            self.textView?.textColor = fontColor.type
        }
    }
    var textViewBackgroundColor: TextViewBackgroundColor = TextViewBackgroundColor(name: "Black", value: 0, type: UIColor.black) {
        didSet {
            self.textView?.backgroundColor = textViewBackgroundColor.type
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        print("in init")
        let frame = aDecoder.decodeCGRect(forKey: "frame")
        let text = aDecoder.decodeObject(forKey: "text") as? UITextView ?? UITextView()
        let backgroundColor = aDecoder.decodeObject(forKey: "backgroundColor") as? UIColor ?? UIColor.lightGray
        print(text.text)
        
        // Call the main init to build out the View
        self.init(frame: frame)
        
        // Set the necessary properties
        self.textView = text
        self.backgroundColor = backgroundColor
    }
    
    override func encode(with aCoder: NSCoder) {
        print("in encode")
        super.encode(with: aCoder)
        aCoder.encode(self.frame, forKey: "frame")
        aCoder.encode(self.textView!, forKey: "text")
        aCoder.encode(self.backgroundColor, forKey: "backgroundColor")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let size = self.bounds.size
        let height = size.height * 0.85
        
        // calculate the 5 points of the pentagon
        let p1 = self.bounds.origin
        let p2 = CGPoint(x:p1.x, y:height)
        let p3 = CGPoint(x:size.width * 0.80, y:height)
        let p4 = CGPoint(x: size.width, y: height * 0.5)
        let p5 = CGPoint(x: p3.x, y: p1.y)
        
        // draw stuff
        let path = UIBezierPath()
        
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        path.addLine(to: p4)
        path.addLine(to: p5)
        path.close()
        
        // Set the color for the object
        viewColor.set()
        
        // fill the path
        path.fill()
        
        // Configure User Interactions
        self.isUserInteractionEnabled = true
        
        // Create and add a Text View
        var textView: UITextView
        textView = UITextView(frame: CGRect(x: self.bounds.minX + 10, y: self.bounds.minY + 10, width: p3.x - 10, height: p3.y - 20))
        
        // Configure the font attributes
        textView.font = self.textView?.font ?? self.fontType.type
        textView.textColor = self.textView?.textColor ?? self.fontColor.type
        
        // Configure the text
        let textViewText: NSAttributedString = self.textView?.attributedText ?? NSAttributedString()
        textView.attributedText = textViewText
        
        // Configure the background color
        let textViewBackgroundColor: UIColor = self.textView?.backgroundColor ?? self.textViewBackgroundColor.type
        textView.backgroundColor = textViewBackgroundColor
        
        // Confugre the editing abilities
        textView.allowsEditingTextAttributes = true
        textView.isSelectable = true
        textView.isEditable = true
        
        // Add the controller as the delgate for the Protocol
        textView.delegate = delegate
        
        // Save the TextView as a property
        self.textView = textView

        /* If there is a text view means this is being redrawn because of the color background
        // Just read the textView
        if self.textView != nil {
            textView = self.textView!
        }
        else {
            // Add a text view
            textView = UITextView(frame: CGRect(x: self.bounds.minX + 10, y: self.bounds.minY + 10, width: p3.x - 10, height: p3.y - 20))
            textView.backgroundColor = self.textViewBackgroundColor.type
            textView.font = self.fontType.type
            textView.textColor = self.fontColor.type
            textView.allowsEditingTextAttributes = true
            textView.isSelectable = true
            textView.isEditable = true
            textView.delegate = delegate
            self.textView = textView
        }
        
        textView.delegate = delegate
        self.textView?.delegate = delegate
    */
        
        self.addSubview(textView)
        
    }
    
}
