//
//  ViewController.swift
//  Example
//
//  Created by William.Weng on 2025/11/19.
//

import UIKit
import WWFaceLandmarkDetection

final class ViewController: UIViewController {
    
    @IBOutlet weak var detectImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        WWFaceLandmarkDetection.shared.setting(detectImageView: detectImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        WWFaceLandmarkDetection.shared.faceLandmarksBoxing(landmarkTypes: [.allPoints])
    }
    
    @IBAction func clean(_ sender: UIBarButtonItem) {
        WWFaceLandmarkDetection.shared.clearOverlayView()
    }
}
