
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
    let barWidth = 5.0
    let screenWidth = Double(self.frame.width)
    let screenHeight = Double(self.frame.height)
    
    startFrame = CGRect(x: screenWidth*fromPercentage/100.0-barWidth/2.0,
                        y: 0, width: barWidth, height: screenHeight)
    endFrame = CGRect(x: screenWidth*toPercentage/100.0-barWidth/2.0,
                      y: 0, width: barWidth, height: screenHeight)
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
  private func unanimate(_ closure: () -> (Void)) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    closure();
    CATransaction.commit()
  }
}
