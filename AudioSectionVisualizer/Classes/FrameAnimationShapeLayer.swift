//
//  FrameAnimationShapeLayer.swift
//  AudioSectionVisualizer
//
//  Created by Sam Meech-Ward on 2018-01-01.
//

import UIKit

class FrameAnimationShapeLayer: CAShapeLayer {
  
  var startFrame = CGRect.zero
  var endFrame = CGRect.zero
  var animationDuration: TimeInterval = 0
  
  func moveToStartPosition() {
    unanimate {
      self.removeAllAnimations()
      self.frame = self.startFrame
    }
  }
  
  func hide() {
    unanimate {
      self.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    }
  }
  
  func animate() {
    moveToStartPosition()
    
    CATransaction.flush()
    CATransaction.begin()
    CATransaction.setAnimationDuration(animationDuration)
    CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
    CATransaction.setCompletionBlock {
      self.hide()
    }
    
    self.frame = endFrame
    CATransaction.commit()
  }

}

extension FrameAnimationShapeLayer {
  private func unanimate(_ closure: () -> (Void)) {
    CATransaction.begin()
    CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
    closure();
    CATransaction.commit()
  }
}
