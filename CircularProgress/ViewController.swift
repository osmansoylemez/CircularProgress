//
//  ViewController.swift
//  CircularProgress
//
//  Created by Burcu Turan on 23.04.2022.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let fgColor1 = UIColor.init(red: 0/255.0, green: 196/255.0, blue: 180/255.0, alpha: 1.0)
        let fgColor2 = UIColor.init(red: 0/255.0, green: 217/255.0, blue: 199/255.0, alpha: 1.0)
        let fgColor3 = UIColor.init(red: 170/255.0, green: 209/255.0, blue: 54/255.0, alpha: 1.0)
        let fgColor4 = UIColor.init(red: 197/255.0, green: 229/255.0, blue: 97/255.0, alpha: 1.0)
        let fgColor5 = UIColor.init(red: 210/255.0, green: 239/255.0, blue: 119/255.0, alpha: 1.0)
        let fgColor6 = UIColor.init(red: 84/255.0, green: 102/255.0, blue: 119/255.0, alpha: 1.0)

        let rings = [
            ProgressRing(color: fgColor1, backgroundColor: .clear, width: 18),
            ProgressRing(color: fgColor2, backgroundColor: .clear, width: 18),
            ProgressRing(color: fgColor3, backgroundColor: .clear, width: 18),
            ProgressRing(color: fgColor4, backgroundColor: .clear, width: 18),
            ProgressRing(color: fgColor5, backgroundColor: .clear, width: 18),
            ProgressRing(color: fgColor6, backgroundColor: .clear, width: 18),
        ]
        
        let margin: CGFloat = 2
        let radius: CGFloat = 80
        let center = CGPoint.init(x: containerView.frame.width / 2.0, y: containerView.frame.height / 2.0)
        let progressRingView = ConcentricProgressRingView(center: center, radius: radius, margin: margin, rings: rings)
        
        containerView.addSubview(progressRingView)
        
        progressRingView.arcs[5].setProgress(0.0, progress:0.31, duration: 0.35)
        progressRingView.arcs[4].setProgress(0.31, progress:0.53, duration: 0.40)
        progressRingView.arcs[3].setProgress(0.53, progress:0.69, duration: 0.42)
        progressRingView.arcs[2].setProgress(0.69, progress:0.82, duration: 0.45)
        progressRingView.arcs[1].setProgress(0.82, progress:0.91, duration: 0.48)
        progressRingView.arcs[0].setProgress(0.91, progress:1.0, duration: 0.50)

    }
    
    
}

