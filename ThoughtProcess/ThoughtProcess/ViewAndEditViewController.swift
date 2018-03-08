//
//  ViewAndEditViewController.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/8/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import UIKit

class ViewAndEditViewController: UIViewController, UIScrollViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Connect the scroll view delegate and configure size
        self.viewAndEditScrollView.delegate = self
        self.viewAndEditScrollView.minimumZoomScale = 1.0
        self.viewAndEditScrollView.maximumZoomScale = 4.0
        self.viewAndEditScrollView.zoomScale = 1.0
    }
    
    // UI Properties
    @IBOutlet weak var viewAndEditScrollView: UIScrollView!
    @IBOutlet weak var canvasView: UIView!
    var arrow: ArrowView!
    
    // UI Methods
    @IBAction func addSectionButton(_ sender: UIBarButtonItem) {
        
        // Create a new Arrow shape
        arrow = ArrowView(frame: CGRect(origin: CGPoint(), size: CGSize(width: 250, height: 250)), controller: self)
        
        // Add a pan gesture recognizer to the arrow
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleArrowPan(_:)))
        arrow.addGestureRecognizer(pan)
        
        // Add the arrow to the canvas
        self.canvasView.addSubview(arrow)
        
    }
    
    // Controller Methods
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return canvasView
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // updateMinZoomScaleForSize(view.bounds.size)
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // view?.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    
    func updateMinZoomScaleForSize (_ size: CGSize) {
        let widthScale = size.width / canvasView.bounds.width
        let heightScale = size.height / canvasView.bounds.height
        let minScale = min(widthScale, heightScale)
        
        viewAndEditScrollView.minimumZoomScale = minScale
        viewAndEditScrollView.zoomScale = minScale
    }
    
    // Gesture Handlers
    @IBAction func handleArrowPan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        guard let view = recognizer.view else { return }
        guard let canvas = view.superview else { return }
        
        // Set the translation
        // Check to make sure the item is not outside the bounds
        var newFrame = view.frame
        newFrame.origin.x += translation.x
        newFrame.origin.y += translation.y
        
        if canvas.bounds.contains(view.frame) {
            view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        }
        
        // Check the edges
        else if newFrame.minX < canvas.bounds.minX {
            view.center.x = canvas.bounds.minX + view.frame.size.width / 2
        }
        
        else if newFrame.maxX > canvas.bounds.maxX {
            view.center.x = canvas.bounds.maxX - view.frame.size.width / 2
        }
        
        else if newFrame.minY < canvas.bounds.minY {
            view.center.y = canvas.bounds.minY + view.frame.size.height / 2
        }
        
        else if newFrame.maxY > canvas.bounds.maxY {
            view.center.y = canvas.bounds.maxY - view.frame.size.height / 2
        }
        
        // Reset the translation to 0
        recognizer.setTranslation(CGPoint.zero, in: self.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ViewAndEditViewController: UITextViewDelegate {
    
    // Keyboard setup
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
