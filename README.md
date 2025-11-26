# WWFaceLandmarkDetection
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWFaceLandmarkDetection) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

### [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Facial landmark detection using the official Vision framework.](https://www.pexels.com/zh-tw/photo/3204088/)
- [使用官方Vision架構人臉特徵點偵測](https://steam.oxxostudio.tw/category/python/ai/ai-mediapipe-2023-face-landmark-detection.html)

![](Example.PNG)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWFaceLandmarkDetection.git", .upToNextMajor(from: "1.2.1"))
]
```

### 可用參數 (Paramter)
|參數|功能|
|-|-|
|overlayView|取得繪製特徵點的UIView|

### 可用函式 (Function)
|函式|功能|
|-|-|
|setting(detectImageView:)|參數設定|
|clearOverlayView()|清除標示框|
|originalFaceLandmarks(image:options:result:)|人臉特徵點原始分析值|
|originalFaceLandmarks(image:options:)|人臉特徵點原始分析值 (非同步)|
|originalHumanHandPosePoints(image:options:maximumHandCount:result:)|手指頭特徵點原始分析值|
|originalHumanHandPosePoints(image:options:maximumHandCount:)|手指頭特徵點原始分析值 (非同步)|
|faceLandmarks(landmarkTypes:result:)|人臉特徵點資訊|
|faceLandmarks(landmarkTypes:)|人臉特徵點資訊 (非同步)|
|faceLandmarkCount(result:)|人臉數量|
|faceLandmarkCount()|人臉數量 (非同步)|
|faceLandmarksBoxing(landmarkTypes:isDisplayBox:lineWidth:lineColor:result:)|人臉特徵點標示|
|faceLandmarksBoxing(landmarkTypes:isDisplayBox:lineWidth:lineColor:)|人臉特徵點標示 (非同步)|
|humanHandPosePoints(options:maximumHandCount:jointNames:result:)|手指頭特徵點|
|humanHandPosePoints(options:maximumHandCount:jointNames:)|手指頭特徵點 (非同步)|
|humanHandPosePointCount(options:maximumHandCount:result:)|手的數量|
|humanHandPosePointCount(options:maximumHandCount:)|手的數量 (非同步)|
|humanHandPosePointsBoxing(options:maximumHandCount:jointNames:lineWidth:lineColor:result:)|手指頭特徵點標示|
|humanHandPosePointsBoxing(options:maximumHandCount:jointNames:lineWidth:lineColor:)|手指頭特徵點標示 (非同步)|
|faceLandmarksBoundingBox(sampleBuffer:previewLayer:orientation:options:mark:result)|動態人臉位置|
|faceLandmarksBoundingBox(sampleBuffer:previewLayer:orientation:options:mark:)|動態人臉位置 (非同步)|
|faceLandmarksBoundingBoxing(sampleBuffer:previewLayer:strokeColor:orientation:options:mark:result)|動態人臉標示|
|faceLandmarksBoundingBoxing(sampleBuffer:previewLayer:strokeColor:orientation:options:mark)|動態人臉標示 (非同步)|
|humanHandPosePointsBoundingBox(sampleBuffer:previewLayer:orientation:options:mark:maximumHandCount:confidence:jointNames:result)|動態手指頭位置|
|humanHandPosePointsBoundingBox(sampleBuffer:previewLayer:orientation:options:mark:maximumHandCount:confidence:jointNames:)|動態手指頭 (非同步)|
|humanHandPosePointsBoundingBoxing(sampleBuffer:previewLayer:lineWidth:lineColor:orientation:options:mark:maximumHandCount:confidence:jointNames:result)|動態手指頭位置標示|
|humanHandPosePointsBoundingBoxing(sampleBuffer:previewLayer:lineWidth:lineColor:orientation:options:mark:maximumHandCount:confidence:jointNames)|動態手指頭位置標示 (非同步)|

### Example
```swift
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
```
