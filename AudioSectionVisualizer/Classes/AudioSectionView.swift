
import UIKit

public class AudioSectionView: UIView {
  
  var unusedColor: UIColor = UIColor.brown
  var usedColor: UIColor = UIColor.magenta
  var percentColor: UIColor = UIColor.cyan
  
  /// The line that animates accross the view to indicate playback
  private var playingIndicatorLayer: FrameAnimationShapeLayer? {
    willSet(newLayer) {
      playingIndicatorLayer?.removeFromSuperlayer()
    }
    didSet {
      guard let playingIndicatorLayer = playingIndicatorLayer else {
        return
      }
      self.layer.addSublayer(playingIndicatorLayer)
    }
  }
  
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
    
    setupPlayingIndicatorLayer(usedPointsIndexStart: usedPointsIndexStart, usedPointsIndexEnd: usedPointsIndexEnd, lineSpaceing: maximumLineSpacing)
  }
  
  private func setupPlayingIndicatorLayer(usedPointsIndexStart: Int, usedPointsIndexEnd: Int, lineSpaceing: Double) {
    playingIndicatorLayer = FrameAnimationShapeLayer()
    playingIndicatorLayer?.backgroundColor = percentColor.cgColor
    playingIndicatorLayer?.hide()
    
    let startX = pointX(pointIndex: usedPointsIndexStart, lineSpacing: lineSpaceing)
    let endX = pointX(pointIndex: usedPointsIndexEnd, lineSpacing: lineSpaceing) + Double(lineWidth(lineSpacing: lineSpaceing))
    let height = Double(self.frame.size.height);
    playingIndicatorLayer?.startFrame = CGRect(x: startX, y: 0, width: 5.0, height: height)
    playingIndicatorLayer?.endFrame = CGRect(x: endX, y: 0, width: 5.0, height: height)
  }
  
  public func drawPlayingIndicatorLayer(fromPercentage: Double, toPercentage: Double) {
    let barWidth = 5.0
    let screenWidth = Double(self.frame.width)
    let screenHeight = Double(self.frame.height)
    
    playingIndicatorLayer?.startFrame = CGRect(x: screenWidth*fromPercentage/100.0-barWidth/2.0,
                        y: 0, width: barWidth, height: screenHeight)
    playingIndicatorLayer?.endFrame = CGRect(x: screenWidth*toPercentage/100.0-barWidth/2.0,
                      y: 0, width: barWidth, height: screenHeight)
    playingIndicatorLayer?.hide()
  }
  
  public func animatePlayingIndicatorLayer(duration: TimeInterval) {
    guard let playingIndicatorLayer = playingIndicatorLayer else {
      return
    }
    playingIndicatorLayer.animationDuration = duration
    playingIndicatorLayer.animate()
  }
  
}
