//
//  FlowMapView.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/8/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

protocol TextViewProtocol {
    func test()
}

class ArrowView: UIView {
    
    let controllerDelegate: ViewAndEditViewController
    var textView: UITextView?
    var color = UIColor.gray {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    init(frame: CGRect, controller: ViewAndEditViewController) {
        controllerDelegate = controller
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        color.set()
        
        // fill the path
        path.fill()
        
        // Create and add a Text View
        var textView: UITextView
        
        if self.textView != nil {
            textView = self.textView!
        }
        else
        {
            // Add a text view
            textView = UITextView(frame: CGRect(x: self.bounds.minX + 10, y: self.bounds.minY + 10, width: p3.x - 10, height: p3.y - 20))
            textView.backgroundColor = UIColor.orange
            textView.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            textView.delegate = controllerDelegate
            self.textView = textView
        }
        
        self.addSubview(textView)
        
        // Enable user interaction
        self.isUserInteractionEnabled = true
    }
    
}
