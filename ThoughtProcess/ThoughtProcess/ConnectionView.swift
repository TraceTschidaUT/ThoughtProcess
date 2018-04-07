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
                self.backgroundColor = nil
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
        let viewColor = aDecoder.decodeObject(forKey: "backgroundColor") as? UIColor ?? UIColor.gray
        
        // Call the main init to build out the View
        self.init(frame: frame)
        
        // Set the necessary properties
        self.savedBackgroundColor = viewColor
    }
    
    override func encode(with aCoder: NSCoder) {
        print("in encode")
        super.encode(with: aCoder)
        aCoder.encode(self.bounds, forKey: "frame")
        // SAVE THE BOUNDS AND THE FRAME!
        aCoder.encode(self.viewColor, forKey: "backgroundColor")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw the connection
        let path = UIBezierPath(rect: rect)
        
        // Set the color
        if savedBackgroundColor != nil {
            self.savedBackgroundColor?.set()
            self.viewColor = self.savedBackgroundColor!
        }
        else {
            self.viewColor.set()
        }
        
        // Fill the path
        path.fill()
        
    }

}
