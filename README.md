# WWFaceLandmarkDetection
[![Swift-5.7](https://img.shields.io/badge/Swift-5.7-orange.svg?style=flat)](https://developer.apple.com/swift/) [![iOS-15.0](https://img.shields.io/badge/iOS-15.0-pink.svg?style=flat)](https://developer.apple.com/swift/) ![TAG](https://img.shields.io/github/v/tag/William-Weng/WWFaceLandmarkDetection) [![Swift Package Manager-SUCCESS](https://img.shields.io/badge/Swift_Package_Manager-SUCCESS-blue.svg?style=flat)](https://developer.apple.com/swift/) [![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

### [Introduction - 簡介](https://swiftpackageindex.com/William-Weng)
- [Facial landmark detection using the official Vision framework.](https://www.pexels.com/zh-tw/photo/3204088/)
- [使用官方Vision架構人臉特徵點偵測](https://steam.oxxostudio.tw/category/python/ai/ai-mediapipe-2023-face-landmark-detection.html)

![](Example.png)

### [Installation with Swift Package Manager](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/使用-spm-安裝第三方套件-xcode-11-新功能-2c4ffcf85b4b)
```bash
dependencies: [
    .package(url: "https://github.com/William-Weng/WWFaceLandmarkDetection.git", .upToNextMajor(from: "1.1.0"))
]
```

### 可用函式 (Function)
|函式|功能|
|-|-|
|setting(detectImageView:)|參數設定|
|faceLandmarks(landmarkTypes:result:)|人臉特徵點資訊|
|faceLandmarks(landmarkTypes:)|人臉特徵點資訊|
|faceLandmarksBoxing(landmarkTypes:isDisplayBox:lineWidth:lineColor:result:)|人臉特徵點標示|
|faceLandmarksBoxing(landmarkTypes:isDisplayBox:lineWidth:lineColor:)|人臉特徵點標示|
|humanHandPosePoints(options:maximumHandCount:result:)|手指頭特徵點|
|humanHandPosePoints(options:maximumHandCount:)|手指頭特徵點|
|humanHandPosePointsBoxing(options:lineWidth:lineColor:maximumHandCount:result:)|手指頭特徵點標示|
|humanHandPosePointsBoxing(options:lineWidth:lineColor:maximumHandCount:)|手指頭特徵點標示|

### Example
```swift
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
    }
}
```
