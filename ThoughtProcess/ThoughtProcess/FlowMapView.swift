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

enum MindMapType: Int16 {
    case arrow = 0
    case bubble = 1
    case square = 2
}

class FlowMapView: UIView, ColorChangeProtocol {
    
    // MARK: - Properties
    var delegate: ViewAndEditViewController?
    var textView: UITextView?
    var selectedText: String = ""
    
    var viewColor = UIColor.gray {
        didSet {
            if self.savedBackgroundColor == nil{
                self.setNeedsDisplay()
            }
            else {
                self.savedBackgroundColor = nil
                self.backgroundColor = nil
            }
        }
    }
    
    var savedBackgroundColor: UIColor? = nil
   
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
    var textViewBackgroundColor: TextViewBackgroundColor = TextViewBackgroundColor(name: "Gray", value: 4, type: UIColor.gray) {
        didSet {
            self.textView?.backgroundColor = textViewBackgroundColor.type
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        print("in init")
        let frame = aDecoder.decodeCGRect(forKey: "frame")
        let text = aDecoder.decodeObject(forKey: "text") as? UITextView ?? UITextView()
        let viewColor = aDecoder.decodeObject(forKey: "backgroundColor") as? UIColor ?? UIColor.lightGray
        
        // Call the main init to build out the View
        self.init(frame: frame)
        
        // Set the necessary properties
        self.textView = text
        self.savedBackgroundColor = viewColor
    }
    
    override func encode(with aCoder: NSCoder) {
        print("in encode")
        super.encode(with: aCoder)
        aCoder.encode(self.frame, forKey: "frame")
        aCoder.encode(self.textView!, forKey: "text")
        aCoder.encode(self.viewColor, forKey: "backgroundColor")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
}

class ArrowView : FlowMapView {
    
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
        
        // Set the background color
        self.backgroundColor = UIColor.clear
        if savedBackgroundColor != nil {
            self.savedBackgroundColor?.set()
            self.viewColor = self.savedBackgroundColor!
            self.savedBackgroundColor = nil
        }
        else {
            self.viewColor.set()
        }
        
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
        
        // Configure the textview's background color
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
        
        self.addSubview(textView)
        
    }
}

class BubbleView : FlowMapView {
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Create the path
        print(rect)
        let circlePath = UIBezierPath(ovalIn: rect)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = circlePath.cgPath
        
        // Change the fill color depending on what is saved
        if self.savedBackgroundColor != nil {
            shapeLayer.fillColor = self.savedBackgroundColor?.cgColor
            shapeLayer.strokeColor = self.savedBackgroundColor?.cgColor
            self.viewColor = self.savedBackgroundColor!
            self.savedBackgroundColor = nil
        }
        else {
            self.backgroundColor = UIColor.clear
            shapeLayer.fillColor = self.viewColor.cgColor
            shapeLayer.strokeColor = self.viewColor.cgColor
        }
        
        // Change the stroke
        shapeLayer.lineWidth = 3.0
        
        self.layer.addSublayer(shapeLayer)
        
        // Configure User Interactions
        self.isUserInteractionEnabled = true
        
        // Create and add a Text View
        var textView: UITextView
        let textViewRect = rect.insetBy(dx: 25, dy: 25)
        textView = UITextView(frame: textViewRect)
        
        // Configure the font attributes
        textView.font = self.textView?.font ?? self.fontType.type
        textView.textColor = self.textView?.textColor ?? self.fontColor.type
        
        // Configure the text
        let textViewText: NSAttributedString = self.textView?.attributedText ?? NSAttributedString()
        textView.attributedText = textViewText
        
        // Configure the textview's background color
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
        
        self.addSubview(textView)
        
    }
}

class BoxView : FlowMapView {
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = UIBezierPath(rect: rect)
        
        // Set the background color
        self.backgroundColor = UIColor.clear
        if savedBackgroundColor != nil {
            self.savedBackgroundColor?.set()
            self.viewColor = self.savedBackgroundColor!
            self.savedBackgroundColor = nil
        }
        else {
            viewColor.set()
        }
        
        // fill the path
        path.fill()
        
        // Configure User Interactions
        self.isUserInteractionEnabled = true
        
        // Create and add a Text View
        var textView: UITextView
        let textViewRect = rect.insetBy(dx: 10, dy: 10)
        textView = UITextView(frame: textViewRect)
        
        // Configure the font attributes
        textView.font = self.textView?.font ?? self.fontType.type
        textView.textColor = self.textView?.textColor ?? self.fontColor.type
        
        // Configure the text
        let textViewText: NSAttributedString = self.textView?.attributedText ?? NSAttributedString()
        textView.attributedText = textViewText
        
        // Configure the textview's background color
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
        
        self.addSubview(textView)
    }
}
