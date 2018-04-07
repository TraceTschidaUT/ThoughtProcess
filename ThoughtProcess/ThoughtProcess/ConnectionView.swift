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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Draw the connection
        let path = UIBezierPath(rect: rect)
        
        // Set the color
        if savedBackgroundColor != nil {
            self.viewColor = self.savedBackgroundColor!
            self.savedBackgroundColor?.set()
        }
        else {
            self.viewColor.set()
        }
        
        // Fill the path
        path.fill()
        
    }

}
