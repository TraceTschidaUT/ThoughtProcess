//
//  ConnectionView.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 4/5/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

protocol ColorChangeProtocol {
    var savedBackgroundColor: UIColor? { get set }
    var viewColor: UIColor { get set }
}

class ConnectionView: UIView, ColorChangeProtocol {
    
    var savedBackgroundColor: UIColor?
    var viewColor: UIColor = UIColor.gray {
        
        didSet {
            if self.savedBackgroundColor == nil{
                self.setNeedsDisplay()
            }
            else {
                self.savedBackgroundColor = nil
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    
    required convenience init?(coder aDecoder: NSCoder) {
        print("in init")
        let frame = aDecoder.decodeCGRect(forKey: "frame")
        let bounds = aDecoder.decodeCGRect(forKey: "bounds")
        let viewColor = aDecoder.decodeObject(forKey: "backgroundColor") as? UIColor ?? UIColor.gray
        let transform = aDecoder.decodeCGAffineTransform(forKey: "transform")
        let center = aDecoder.decodeCGPoint(forKey: "center")
        
        print("Before init", frame, bounds)
        
        // Call the main init to build out the View
        // Create a new frame from the bounds and frame
        let origin = CGPoint(x: center.x - (bounds.maxX / 2), y: center.y - (bounds.maxY / 2))
        let viewRect = CGRect(origin: origin, size: bounds.size)
        self.init(frame: viewRect)
        
        print("After init", self.frame, self.bounds)
        
        // Set the necessary properties
        self.savedBackgroundColor = viewColor
        self.transform = transform
        
        print("After transform", self.frame, self.bounds)
    }
    
    override func encode(with aCoder: NSCoder) {
        print("in encode")
        super.encode(with: aCoder)
        aCoder.encode(self.frame, forKey: "frame")
        aCoder.encode(self.bounds, forKey: "bounds")
        aCoder.encode(self.viewColor, forKey: "backgroundColor")
        aCoder.encode(self.transform, forKey: "transform")
        aCoder.encode(self.center, forKey: "center")
        print(self.frame, self.bounds)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw the connection
        let path = UIBezierPath(rect: rect)
        
        // Set the color
        if savedBackgroundColor != nil {
            self.savedBackgroundColor?.set()
            self.viewColor = self.savedBackgroundColor!
            self.savedBackgroundColor = nil
        }
        else {
            self.viewColor.set()
        }
        
        // Fill the path
        path.fill()
        
    }

}
