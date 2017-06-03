//
//  UIRangeSlider.swift
//  UIRangeSlider
//
//  Created by Laurentiu Daisoreanu on 31/05/2017.
//  Copyright © 2017 Daisoreanu Laurentiu. All rights reserved.
//

import UIKit

@objc public protocol UIRangeSliderDelegate : class {
    func userUpdatedValues(minValue : CGFloat, maxValue : CGFloat)
}



@IBDesignable open class UIRangeSlider: UIView {
    
    var leftKnob: UIView!
    var rightKnob: UIView!
    var selectedRangeView: UIView!
    var trackerView: UIView!
    fileprivate var stepSizeInPoint : CGFloat = 1.0
    
    #if TARGET_INTERFACE_BUILDER
    @IBOutlet open weak var delegate: AnyObject?
    #else
    open weak var delegate: UIRangeSliderDelegate?
    #endif
            
    //sets the knob side size
    @IBInspectable open var knobHeight: CGFloat = 28.0
    
    //sets the knob filler color
    @IBInspectable open var knobColor : UIColor = UIColor.white
    
    //sets the knob corner radius, default is 1.0 -> round corners, 0.0 == square corners
    @IBInspectable open var knobCornerRadiuProcent : CGFloat = 1.0
    
    //enables/ dissables the shadow arround the knobs -> default is true
    @IBInspectable open var isKnobShadowVisibe : Bool = true
    
    //sets the minimum value of the range
    @IBInspectable open var minimumValue : CGFloat = 1.0
    
    //sets the maximum value of the range
    @IBInspectable open var maximumValue : CGFloat = 100.0
    
    //set the minimum value selected
    @IBInspectable open var minimumValueSelected : CGFloat = 25.0
    
    //set the maximum value selected
    @IBInspectable open var maximumValueSelected : CGFloat = 75.0
    
    //allow picker to overlap
    @IBInspectable open var isNegativeRangeEnabled : Bool = false
    
    //positive selected range view background color
    @IBInspectable open var positiveSelectedRangeViewBackgroundColor : UIColor = UIColor.blue
    
    //negative selected range view background color
    @IBInspectable open var negativeSelectedRangeViewBackgroundColor : UIColor = UIColor.red
    
    //set enable the snap to step for the range
    @IBInspectable open var isStepsEnabled = true
    
    //set the distance between steps
    @IBInspectable open var stepSize : CGFloat = 1.0
    
    //set minimum number of steps between knobs
    @IBInspectable open var minimumRange : CGFloat = 10.0
    
    //trackerView fill color
    @IBInspectable open var trackerViewBackgroundColor : UIColor = UIColor.lightGray
    
    // the tracker view height, the default OS is 2.0
    @IBInspectable open var trackerViewHeight : CGFloat = 2.0
    
    //sets the trackerView corner radius, default is 1.0 -> round corners, 0.0 == square corners
    @IBInspectable open var trackerViewCornerRadiuProcent : CGFloat = 1.0
    
    //the trackerView border
    @IBInspectable open var trackerViewBorderColor : UIColor = UIColor.clear
    
    //the trackerView border thickness
    @IBInspectable open var trackerViewBorderThickness : CGFloat = 0.0
    
    override open func awakeFromNib() {
        super .awakeFromNib()
        customizeView()
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        customizeView()
    }
    
    func customizeView() {
        stepSizeInPoint = ((self.frame.size.width - knobHeight) / (maximumValue - minimumValue)) * stepSize
        setupUI()
        addGestureRecognizer()
    }
    
    func addGestureRecognizer() {
        let panGesture1 = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(sender:)))
        panGesture1.maximumNumberOfTouches = 1
        panGesture1.minimumNumberOfTouches = 1
        leftKnob.addGestureRecognizer(panGesture1)
        
        let panGesture2 = UIPanGestureRecognizer.init(target: self, action: #selector(handlePan(sender:)))
        panGesture2.maximumNumberOfTouches = 1
        panGesture2.minimumNumberOfTouches = 1
        rightKnob.addGestureRecognizer(panGesture2)
    }
    
    func setupUI() {
        
        //SETUP BACKGROUND TRACKER VIEW
        trackerView = UIView.init(frame: CGRect.init(x: 0, y: (self.frame.size.height / 2.0) - (trackerViewHeight / 2.0), width: self.frame.size.width, height: trackerViewHeight))
        trackerView.backgroundColor = trackerViewBackgroundColor
        trackerView.layer.cornerRadius = (trackerViewHeight / 2.0) * trackerViewCornerRadiuProcent
        trackerView.layer.borderColor = trackerViewBorderColor.cgColor
        trackerView.layer.borderWidth = trackerViewBorderThickness
        self.addSubview(trackerView)
        
        //SETUP LEFT KNOB
        let knobYPos = (self.frame.size.height / 2.0) - (knobHeight / 2.0)
        
        var leftKnobInitialX : CGFloat = 0.0
        leftKnobInitialX = stepSizeInPoint * (minimumValueSelected - minimumValue)
        
        if leftKnobInitialX < 0.0 {
            leftKnobInitialX = 0.0
        }
        
        if leftKnobInitialX > self.frame.size.width - knobHeight {
            leftKnobInitialX = self.frame.size.width - knobHeight
        }
        
        let leftKnobFrame : CGRect = CGRect.init(x: leftKnobInitialX, y: knobYPos, width: knobHeight, height: knobHeight)
        leftKnob = UIView.init(frame: leftKnobFrame)
        leftKnob.backgroundColor = knobColor
        leftKnob.layer.backgroundColor = knobColor.cgColor
        leftKnob.layer.cornerRadius = knobHeight * knobCornerRadiuProcent
        if isKnobShadowVisibe {
            leftKnob.layer.shadowColor = UIColor.lightGray.cgColor
            leftKnob.layer.shadowOpacity = 1.0
            leftKnob.layer.shadowRadius = knobHeight / 8.0
            //the shadow offset is the default OS one but in mirror
            leftKnob.layer.shadowOffset = CGSize.init(width: 0.0, height: 3)
        }
        leftKnob.layer.cornerRadius = (leftKnob.frame.size.width / 2.0) * knobCornerRadiuProcent
        self.addSubview(leftKnob)
        
        //SETUP RIGHT KNOB
        var rightKnobInitialX : CGFloat = 0.0
        rightKnobInitialX = stepSizeInPoint * (maximumValueSelected - minimumValue)
        
        if rightKnobInitialX < 0.0 {
            rightKnobInitialX = 0.0
        }
        
        if rightKnobInitialX > self.frame.size.width - knobHeight {
            rightKnobInitialX = self.frame.size.width - knobHeight
        }
        
        let rightKnobFrame : CGRect = CGRect.init(x: rightKnobInitialX, y: knobYPos, width: knobHeight, height: knobHeight)
        rightKnob = UIView.init(frame: rightKnobFrame)
        rightKnob.backgroundColor = knobColor
        rightKnob.layer.backgroundColor = knobColor.cgColor
        rightKnob.layer.cornerRadius = knobHeight * knobCornerRadiuProcent
        if isKnobShadowVisibe {
            rightKnob.layer.shadowColor = UIColor.lightGray.cgColor
            rightKnob.layer.shadowOpacity = 1.0
            rightKnob.layer.shadowRadius = knobHeight / 8.0
            //the shadow offset is the default OS one but in mirror
            rightKnob.layer.shadowOffset = CGSize.init(width: 0.0, height: 3)
        }
        if isKnobShadowVisibe == true {
            leftKnob.layer.shadowColor = UIColor.lightGray.cgColor
            leftKnob.layer.shadowOpacity = 1.0
            leftKnob.layer.shadowRadius = knobHeight / 8.0
            //the shadow offset is the default OS one but in mirror
            leftKnob.layer.shadowOffset = CGSize.init(width: 0.0, height: 3)
            
            rightKnob.layer.shadowColor = UIColor.lightGray.cgColor
            rightKnob.layer.shadowOpacity = 1.0
            rightKnob.layer.shadowRadius = knobHeight / 8.0
            //the shadow offset is the default OS one but in mirror
            rightKnob.layer.shadowOffset = CGSize.init(width: 0.0, height: 3)
        }
        rightKnob.layer.cornerRadius = (rightKnob.frame.size.width / 2.0) * knobCornerRadiuProcent
        self.addSubview(rightKnob)
        
        //SETUP SELECTED RANGE VIEW
        let rangeFrame : CGRect?
        let yPos = (self.frame.size.height / 2.0) - (trackerViewHeight / 2.0)
        let selectedViewBackgroundColor : UIColor?
        if leftKnob.center.x <= rightKnob.center.x {
            selectedViewBackgroundColor = positiveSelectedRangeViewBackgroundColor
            rangeFrame = CGRect.init(x: leftKnob.center.x, y: yPos, width: rightKnob.center.x - leftKnob.center.x, height: trackerViewHeight)
        } else {
            selectedViewBackgroundColor = negativeSelectedRangeViewBackgroundColor
            rangeFrame = CGRect.init(x: rightKnob.center.x, y: yPos, width: leftKnob.center.x - rightKnob.center.x, height: trackerViewHeight)
        }
        selectedRangeView = UIView.init(frame: rangeFrame!)
        selectedRangeView.backgroundColor = selectedViewBackgroundColor
        self.addSubview(selectedRangeView)
        
        self.bringSubview(toFront: leftKnob)
        self.bringSubview(toFront: rightKnob)
        
    }
    
    func handlePan(sender : UIPanGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.changed || sender.state == UIGestureRecognizerState.ended {
            let translation = sender.translation(in: self)
            
            let futureXPosition = sender.view!.center.x + translation.x
            var distanceBetweenKnobs : CGFloat = 0.0
            if sender.view == leftKnob {
                distanceBetweenKnobs = rightKnob.center.x - futureXPosition
            }else{
                distanceBetweenKnobs = futureXPosition - leftKnob.center.x
            }
            if isNegativeRangeEnabled == false {
                if distanceBetweenKnobs < (minimumRange * stepSizeInPoint) {
                    return
                }
            }else{
                if distanceBetweenKnobs > 0.0 {
                    selectedRangeView.backgroundColor = positiveSelectedRangeViewBackgroundColor
                }else{
                    selectedRangeView.backgroundColor = negativeSelectedRangeViewBackgroundColor
                }
            }
            
            sender.view?.center = CGPoint.init(x: sender.view!.center.x + translation.x, y: sender.view!.center.y)
            sender.setTranslation(CGPoint.zero, in: self)
            var finalPoint : CGPoint = sender.view!.center
            
            if sender.state == UIGestureRecognizerState.ended{
                if isStepsEnabled {
                    let x = (finalPoint.x - knobHeight / 2.0).truncatingRemainder(dividingBy: stepSizeInPoint)// value between steps
                    let y = Int((finalPoint.x - knobHeight / 2.0) / stepSizeInPoint) //number of steps
                    var newXPos : CGFloat = 0.0
                    if x >  stepSizeInPoint / 2.0 {
                        //move to the upper step
                        newXPos = knobHeight / 2.0 + ((CGFloat(y) + 1.0) * stepSizeInPoint)
                    }else{
                        //move to lower step
                        newXPos = knobHeight / 2.0 + (CGFloat(y) * stepSizeInPoint)
                    }
                    finalPoint.x = newXPos
                }
            }
            
            if finalPoint.x < knobHeight / 2.0 {
                finalPoint.x = knobHeight / 2.0
            }
            if finalPoint.x > self.frame.size.width - knobHeight / 2 {
                finalPoint.x = self.frame.size.width - knobHeight / 2
            }
            
            UIView.animate(withDuration: 0.02 , delay: 0, options: UIViewAnimationOptions.beginFromCurrentState, animations: {
                print("X postion is \(finalPoint.x)")
                sender.view!.center = finalPoint
                let widh = self.rightKnob.center.x - self.leftKnob.center.x
                self.selectedRangeView.frame = CGRect.init(x: self.leftKnob.center.x, y: (self.frame.size.height / 2.0) - (self.trackerViewHeight / 2.0), width: widh, height: 2.0)
            }, completion: nil)
            
            let minValueSelected : CGFloat = leftKnob.frame.origin.x / stepSizeInPoint
            let maxValueSelected : CGFloat = rightKnob.frame.origin.x / stepSizeInPoint
            print("Min value selected is:\(minValueSelected) and max value selected is: \(maxValueSelected)")
            delegate?.userUpdatedValues(minValue: minValueSelected, maxValue: maxValueSelected)
            
        }
    }
    
    
}
