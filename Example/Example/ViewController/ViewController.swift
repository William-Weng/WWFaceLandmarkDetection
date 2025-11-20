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
    
    private var overlayView: UIView = .init()
    private var boxLayers: [CALayer] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        WWFaceLandmarkDetection.shared.setting(detectImageView: detectImageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        WWFaceLandmarkDetection.shared.faceLandmarksBoxing(landmarkTypes: [.allPoints])
        WWFaceLandmarkDetection.shared.faceLandmarkCount() { result in print(result) }
    }
}
