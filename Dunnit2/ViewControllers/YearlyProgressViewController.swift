//
//  YearlyProgressViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 3/28/21.
//

import UIKit
import Foundation

class YearlyProgressViewController : UIViewController {
    let shapeLayer = CAShapeLayer()
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var mainPercentageLabel: UILabel!
    
    var taskStore = [[TaskEntity](), [TaskEntity]()]
    var percentageValue: Float = 0.0
    var period: String = "monthly"
    
    override func viewDidLoad() {
        
        percentageValue = calculatePercentage(period: period)
        
        setupPercentageLabel(timePeriod: period, value: percentageValue)
        setupCircle(value: percentageValue)
        handleAnimation()
        
    }
    
    private func handleAnimation() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        
        basicAnimation.duration = 2
        
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "progressBasic")
    }
    
    private func setupCircle(value: Float) {
        // Draw a circle
        
        let center = view.center
        
        // Create track layer
        let trackLayer = CAShapeLayer()
        
        // Create main circle path
        let circularPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: (2 * CGFloat.pi * CGFloat(value) - (CGFloat.pi / 2)) , clockwise: true)
        
        let circularTrackPath = UIBezierPath(arcCenter: center, radius: 100, startAngle: -CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        // Track later customization
        trackLayer.path = circularTrackPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.lineWidth = 10
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.lineCap = .round
        view.layer.addSublayer(trackLayer)
        
        shapeLayer.path = circularPath.cgPath
        shapeLayer.strokeColor = UIColor.green.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = .round
        
        
        shapeLayer.strokeEnd = 0
        
        view.layer.addSublayer(shapeLayer)
    }
    
    
    private func calculatePercentage(period: String) -> Float{
        
        // Fetch tasks for all tasks
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        
        let partOne = tasks.filter{$0.isDone == false && $0.owner == user[0].email &&  ($0.date as! Date).isInThisYear}
        let partTwo = tasks.filter{$0.isDone == true && $0.owner == user[0].email &&  ($0.date as! Date).isInThisYear}
        
        taskStore = [partOne, partTwo]
        
        
        let numerator = taskStore[1].count
        let denominator = taskStore[0].count + taskStore[1].count
        var progressCount = Float(0)
        
        if (numerator == 0) {
            progressCount = Float(0)
        } else {
            progressCount = (Float(numerator) / Float(denominator))
            print("inside calculate percentage", progressCount)
        }
        
        return progressCount
    }
    
    private func setupPercentageLabel(timePeriod: String = "all", value: Float) {
        
        let percentage = NSString(format: "%.0f", 100 * value) as String
        let percentageLabel = percentage + "%"
        
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "y"
        let dateString = dateFormatter.string(from: now)
        
        labelType.text = dateString
        mainPercentageLabel.textColor = .black
        mainPercentageLabel.textAlignment = .center
        mainPercentageLabel.text = percentageLabel
    }
}
