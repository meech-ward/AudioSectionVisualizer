//
//  ViewController.swift
//  AudioSectionVisualizer
//
//  Created by 05394b3722153a5cad3c776b90c433e6c1f36095 on 12/31/2017.
//  Copyright (c) 2017 05394b3722153a5cad3c776b90c433e6c1f36095. All rights reserved.
//

import UIKit
import AudioSectionVisualizer

class ViewController: UIViewController {

  @IBOutlet weak var audioSectionView: AudioSectionView!
  
  override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    var points: [Double] = []
    
    for _ in 0..<20 {
      points.append(Double(arc4random_uniform(100))/100.0)
    }
    self.audioSectionView.draw(points: points, usedPointsIndexStart: 10, usedPointsIndexEnd: 15)
//    self.audioSectionView.draw(fromPercentage: 50, toPercentage: 75, duration: 0.5)
//    self.audioSectionView.animate()
  }

}

