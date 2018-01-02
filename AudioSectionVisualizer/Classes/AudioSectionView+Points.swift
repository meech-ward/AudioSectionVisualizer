//
//  AudioSectionView+Points.swift
//  AudioSectionVisualizer
//
//  Created by Sam Meech-Ward on 2018-01-01.
//

import UIKit

extension AudioSectionView {
  
  func groupedPoints(allPoints: [Double], usedPointsIndexStart: Int, usedPointsIndexEnd: Int) -> (unusedStart: [Double], used: [Double], unusedEnd: [Double]) {
    
    var unusedStart = [Double]()
    var used = [Double]()
    var unusedEnd = [Double]()
    
    for (index, point) in allPoints.enumerated() {
      if index <= usedPointsIndexStart {
        unusedStart.append(point)
        continue
      }
      if index > usedPointsIndexEnd {
        unusedEnd.append(point)
        continue
      }
      used.append(point)
    }
    
    return (unusedStart, used, unusedEnd)
  }
  
  /**
   Create a `UIBezierPath` from all the points that were passed in.
   This path is the shape of the audio wave, modifying this funciton will modify how you see the wave.
   All points should have a value between 0 and 1.
   
   - parameter : points An array of doules from 0 to 1.
   - parameter : lineSpacing The amount of space between each point.
   
   - returns : A new `UIBezierPath` with all the points drawn to it.
   */
  func pathFromPoints(_ points: [Double], lineSpacing: Double, startPoint: Int = 0) -> UIBezierPath {
    
    let viewHeight = Double(self.frame.height)
    var pointNumber = startPoint
    let path = UIBezierPath()
    
    for point in points {
      let x = pointX(pointIndex: pointNumber, lineSpacing: lineSpacing)
      let height = viewHeight*point
      
      path.move(to: CGPoint(x: x, y: viewHeight/2.0+height/2.0))
      path.addLine(to: CGPoint(x: x, y: viewHeight/2.0-height/2.0))
      
      pointNumber += 1
    }
    
    return path
  }
  
  func pointX(pointIndex: Int, lineSpacing: Double) -> Double {
    return Double(pointIndex) * lineSpacing + (lineSpacing/2.0)
  }
  
  func pathsFromPoints(allPoints: [Double], lineSpacing: Double, unusedStartPoints: [Double], usedPoints: [Double], unusedEndPoints: [Double]) -> (unusedStart: UIBezierPath, used: UIBezierPath, unusedEnd:UIBezierPath) {
    
    let unusedStart = pathFromPoints(unusedStartPoints,
                                     lineSpacing: lineSpacing)
    let used = pathFromPoints(usedPoints,
                              lineSpacing: lineSpacing,
                              startPoint: unusedStartPoints.count)
    let unusedEnd = pathFromPoints(unusedEndPoints,
                                   lineSpacing: lineSpacing,
                                   startPoint: unusedStartPoints.count + usedPoints.count)
    return (unusedStart: unusedStart,
            used: used,
            unusedEnd: unusedEnd)
  }
  
  func layerFromPaths(frame: CGRect, lineSpacing: Double, paths: (unusedStart: UIBezierPath, used: UIBezierPath, unusedEnd:UIBezierPath)) -> CAShapeLayer {
    let superlayer = CAShapeLayer()
    superlayer.frame = frame
    let layersArray = [CAShapeLayer(), CAShapeLayer(), CAShapeLayer()]
    let layers = (unusedStart: layersArray[0], used: layersArray[1], unusedEnd: layersArray[2])
    for layer in layersArray {
      layer.frame = frame
      layer.lineWidth = lineWidth(lineSpacing: lineSpacing)
      layer.lineCap = kCALineCapRound
      superlayer.addSublayer(layer)
    }
    
    layers.unusedStart.path = paths.unusedStart.cgPath
    layers.unusedStart.strokeColor = unusedColor.cgColor
    
    layers.used.path = paths.used.cgPath
    layers.used.strokeColor = usedColor.cgColor
    
    layers.unusedEnd.path = paths.unusedEnd.cgPath
    layers.unusedEnd.strokeColor = unusedColor.cgColor
    
    return superlayer
  }
  
  /**
   Given the amount of space each line has, return the line width.
   The remaining space will be the whitespace around the line
  */
  func lineWidth(lineSpacing: Double) -> CGFloat {
    return CGFloat(lineSpacing/1.5)
  }
}
