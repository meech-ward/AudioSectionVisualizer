
import UIKit

public class AudioSectionView: UIView {
  
  var unusedColor: UIColor = UIColor.brown
  var usedColor: UIColor = UIColor.magenta
  var percentColor: UIColor = UIColor.cyan
  
  private var startFrame = CGRect.zero
  private var endFrame = CGRect.zero
  private var animationDuration: TimeInterval = 0
  
  private var percentLayer = CAShapeLayer()
  
  private var shapeLayer: CAShapeLayer? {
    willSet(newShapeLayer) {
      shapeLayer?.removeFromSuperlayer()
    }
    didSet {
      guard let shapeLayer = shapeLayer else {
        return
      }
      self.layer.addSublayer(shapeLayer)
    }
  }
  
  /**
   - parameter : allPoints should have a value between 0 and 1.
  */
  public func draw(points allPoints: [Double], usedPointsIndexStart: Int, usedPointsIndexEnd: Int) {
    let maximumLineSpacing = Double(self.frame.width) / Double(allPoints.count)
    
    let points = groupedPoints(allPoints: allPoints, usedPointsIndexStart: usedPointsIndexStart, usedPointsIndexEnd: usedPointsIndexEnd)
    
    let paths = pathsFromPoints(allPoints: allPoints, lineSpacing: maximumLineSpacing, unusedStartPoints: points.unusedStart, usedPoints: points.used, unusedEndPoints: points.unusedEnd)
    
    shapeLayer = layerFromPaths(frame: self.bounds, lineSpacing: maximumLineSpacing, paths: paths)
    
    percentLayer.backgroundColor = percentColor.cgColor
    self.layer.addSublayer(percentLayer)
  }
  
  public func draw(fromPercentage: Double, toPercentage: Double, duration: TimeInterval) {
    let width = 5.0
    startFrame = CGRect(x: Double(self.frame.width)/100.0*fromPercentage-width/2.0, y: 0, width: width, height: Double(self.frame.height))
    endFrame = CGRect(x: Double(self.frame.width)/100.0*toPercentage-width/2.0, y: 0, width: width, height: Double(self.frame.height))
    animationDuration = duration
    unanimate {
      self.percentLayer.removeAllAnimations()
      self.percentLayer.frame = self.startFrame
    }
  }
  
  public func animate() {
    unanimate {
      self.percentLayer.removeAllAnimations()
      self.percentLayer.frame = self.startFrame
    }
    CATransaction.flush()
    CATransaction.begin()
    CATransaction.setAnimationDuration(animationDuration)
    CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
    CATransaction.setCompletionBlock {
      self.unanimate {
        self.percentLayer.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
      }
    }
    
    self.percentLayer.frame = endFrame
    CATransaction.commit()
  }
  
}

extension AudioSectionView {
  
  /**
   Create a `UIBezierPath` from all the points that were passed in.
   This path is the shape of the audio wave, modifying this funciton will modify how you see the wave.
   All points should have a value between 0 and 1.
   
   - parameter : points An array of doules from 0 to 1.
   - parameter : lineSpacing The amount of space between each point.
   
   - returns : A new `UIBezierPath` with all the points drawn to it.
  */
  private func pathFromPoints(_ points: [Double], lineSpacing: Double, startPoint: Int = 0) -> UIBezierPath {
    let viewHeight = Double(self.frame.height)
    var pointNumber = startPoint
    let path = UIBezierPath()
    
    for point in points {
      let x = Double(pointNumber) * lineSpacing + (lineSpacing/2.0)
      pointNumber += 1
      
      let height = viewHeight*point
      path.move(to: CGPoint(x: x, y: viewHeight/2.0+height/2.0))
      path.addLine(to: CGPoint(x: x, y: viewHeight/2.0-height/2.0))
    }
    
    return path
  }
  
  private func pathsFromPoints(allPoints: [Double], lineSpacing: Double, unusedStartPoints: [Double], usedPoints: [Double], unusedEndPoints: [Double]) -> (unusedStart: UIBezierPath, used: UIBezierPath, unusedEnd:UIBezierPath) {
    
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
  
  private func layerFromPaths(frame: CGRect, lineSpacing: Double, paths: (unusedStart: UIBezierPath, used: UIBezierPath, unusedEnd:UIBezierPath)) -> CAShapeLayer {
    let superlayer = CAShapeLayer()
    superlayer.frame = frame
    let layersArray = [CAShapeLayer(), CAShapeLayer(), CAShapeLayer()]
    let layers = (unusedStart: layersArray[0], used: layersArray[1], unusedEnd: layersArray[2])
    for layer in layersArray {
      layer.frame = frame
      layer.lineWidth = CGFloat(lineSpacing/1.5)
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
  
  private func groupedPoints(allPoints: [Double], usedPointsIndexStart: Int, usedPointsIndexEnd: Int) -> (unusedStart: [Double], used: [Double], unusedEnd: [Double]) {
    
    var unusedStart = [Double]()
    var used = [Double]()
    var unusedEnd = [Double]()
    
    for (index, point) in allPoints.enumerated() {
      if index <= usedPointsIndexStart {
        unusedStart.append(point)
        continue
      }
      if index >= usedPointsIndexEnd {
        unusedEnd.append(point)
        continue
      }
      used.append(point)
    }
    
    return (unusedStart, used, unusedEnd)
  }
}

extension AudioSectionView {
  private func unanimate(_ closure: () -> (Void)) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    closure();
    CATransaction.commit()
  }
}
