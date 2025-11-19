//
//  Extension.swift
//  WWFaceLandmarkDetection
//
//  Created by William.Weng on 2025/11/19.
//

import UIKit
import Vision
import AVFoundation

// MARK: - Collection (function)
extension Collection where Self.Element: CALayer {
    
    /// 將所有CALayer移除
    func _removeFromSuperlayer() {
        self.forEach { $0.removeFromSuperlayer() }
    }
}

// MARK: - CGSize (function)
extension CGSize {
    
    /// 計算長寬比
    func _aspectRatio() -> Double { return width / height }
}

// MARK: - CGPoint (function)
extension CGPoint {
    
    /// 計算更新尺寸置中後的原點
    /// - Parameters:
    ///   - originSize: 原來尺寸大小
    ///   - newSize: 更新後的尺寸大小
    /// - Returns: Self
    static func _movePointWithSize(from originSize: CGSize, to newSize: CGSize) -> Self {
        
        let originX = (originSize.width - newSize.width) * 0.5
        let originY = (originSize.height - newSize.height) * 0.5
        
        return Self(x: originX, y: originY)
    }
}

// MARK: - CGRect (function)
extension CGRect {
    
    /// [將取得的比例大小 => 位置](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/83-利用-cgaffinetransform-縮放-位移和旋轉-e061df9ed672)
    /// - Parameters:
    ///   - scaleX: CGFloat
    ///   - scaleY: CGFloat
    ///   - frame: [CGRect](https://medium.com/彼得潘的-swift-ios-app-開發教室/作業-52-使用-swiftui-預覽-uibezierpath-畫出喜歡角落的貓咪-ed4042a23303)
    /// - Returns: CGRect
    func _convertRatio(scaleX: CGFloat, scaleY: CGFloat, to frame: CGRect) -> CGRect {
                
        let size = frame.size
        let scaleTranslate = CGAffineTransform.identity.scaledBy(x: size.width, y: size.height)
        let frameTransform = CGAffineTransform(scaleX: scaleX, y: scaleY).translatedBy(x: frame.origin.x, y: -size.height - frame.origin.y)
        
        return self.applying(scaleTranslate).applying(frameTransform)
    }
}

// MARK: - CALayer (function)
extension CALayer {
    
    /// 設定frame
    /// - Parameter frame: CGRect
    /// - Returns: Self
    func _frame(_ frame: CGRect) -> Self { self.frame = frame; return self }
    
    /// 設定框線寬度
    /// - Parameter width: CGFloat
    /// - Returns: Self
    func _borderWidth(_ width: CGFloat) -> Self { borderWidth = width; return self }
    
    /// 設定框線顏色
    /// - Parameter color: UIColor
    /// - Returns: Self
    func _borderColor(_ color: UIColor) -> Self { borderColor = color.cgColor; return self }
}

// MARK: - UIImage (function)
extension UIImage {
    
    /// UIImage (圖片) => CGImage (點陣圖)
    /// - Returns: CGImage?
    func _cgImage() -> CGImage? { return self.cgImage }
    
    /// [UIImage (圖片) => CGImage (點陣圖) => CIImage (圖片資訊)](https://www.itread01.com/p/350908.html)
    /// - Returns: CIImage?
    func _ciImage(options: [CIImageOption : Any]?) -> CIImage? {
        guard let cgImage = _cgImage() else { return nil }
        return CIImage(cgImage: cgImage, options: options)
    }
    
    /// 依照比例縮放圖片的尺寸 (以寬度為準)
    /// - Parameter width: 寬度大小
    /// - Returns: CGSize
    func _scaledSize(toWidth width: CGFloat) -> CGSize {
        
        let scale = width / size.width
        let newSize = CGSize(width: width, height: size.height * scale)
        
        return newSize
    }
    
    /// 依照比例縮放圖片的尺寸 (以高度為準)
    /// - Parameter width: 高度大小
    /// - Returns: CGSize
    func _scaledSize(toHeight height: CGFloat) -> CGSize {
        
        let scale = height / size.height
        let newSize = CGSize(width: size.width * scale, height: height)
        
        return newSize
    }
}

// MARK: - UIImage (for Vision)
extension UIImage {
    
    /// [人臉關鍵點提取的結果](https://medium.com/msapps-development/face-recognition-ios-fadfecb99b15)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<VNRequest, Error>
    func _detectFaceLandmarksResult(dispatchQueue: DispatchQueue = .global(qos: .userInitiated), options: [VNImageOption : Any] = [:], result: @escaping (Result<[VNFaceObservation]?, Error>) -> ()) {
        _detectResults(for: VNDetectFaceLandmarksRequest.self, result: result)
    }
    
    /// [取得識別人臉的結果 => 使用泛型選擇](https://www.jianshu.com/p/83aa3983ac76)
    /// - Parameters:
    ///   - type: T: VNImageBasedRequest
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - maximumHandCount: [辨識幾隻手的數量 => VNDetectHumanHandPoseRequest](https://www.raywenderlich.com/19454476-vision-tutorial-for-ios-detect-body-and-hand-pose)
    ///   - result: Result<[VNFaceObservation]?, Error>
    func _detectResults<T: VNImageBasedRequest, U: VNObservation>(for type: T.Type, dispatchQueue: DispatchQueue = .global(qos: .userInitiated), options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, result: @escaping (Result<[U]?, Error>) -> ()) {
        
        if (T.self == VNDetectFaceRectanglesRequest.self) {
            
            self._detectFaceRectanglesRequest(dispatchQueue: dispatchQueue, options: options) { detectResult in
                switch detectResult {
                case .failure(let error): result(.failure(error))
                case .success(let request):
                    let results = request.results as? [U]
                    result(.success(results))
                }
            }
        }
        
        if (T.self == VNDetectFaceLandmarksRequest.self) {
            
            self._detectFaceLandmarksRequest(dispatchQueue: dispatchQueue, options: options) { detectResult in
                switch detectResult {
                case .failure(let error): result(.failure(error))
                case .success(let request):
                    let results = request.results as? [U]
                    result(.success(results))
                }
            }
        }
        
        if (T.self == VNDetectHumanHandPoseRequest.self) {
            
            self._detectHumanHandPoseRequest(dispatchQueue: dispatchQueue, options: options, maximumHandCount: maximumHandCount) { detectResult in
                switch detectResult {
                case .failure(let error): result(.failure(error))
                case .success(let request):
                    let results = request.results as? [U]
                    result(.success(results))
                }
            }
        }
    }
}

// MARK: - UIImage (for Vision)
private extension UIImage {
    
    /// [人臉辨識](https://medium.com/@zhgchgli/vision-初探-app-頭像上傳-自動識別人臉裁圖-swift-9a9aa892f9a9)
    /// - Parameters:
    ///   - dispatchQueue: [DispatchQueue](https://juejin.cn/post/6844903504469819399)
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<VNRequest, Error>
    func _detectFaceRectanglesRequest(dispatchQueue: DispatchQueue = .global(qos: .userInitiated), options: [VNImageOption : Any] = [:], result: @escaping (Result<VNDetectFaceRectanglesRequest, Error>) -> ()) {
        _detectRequest(for: VNDetectFaceRectanglesRequest.self, dispatchQueue: dispatchQueue, options: options, result: result)
    }
    
    /// [人臉關鍵點提取](https://www.jianshu.com/p/59b43dbe4fbd)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<VNRequest, Error>
    func _detectFaceLandmarksRequest(dispatchQueue: DispatchQueue = .global(qos: .userInitiated), options: [VNImageOption : Any] = [:], result: @escaping (Result<VNDetectFaceLandmarksRequest, Error>) -> ()) {
        _detectRequest(for: VNDetectFaceLandmarksRequest.self, dispatchQueue: dispatchQueue, options: options, result: result)
    }

    /// [手指關鍵點提取](https://www.appcoda.com.tw/ios-14-vision-framework-tinder-app/)
    /// - Parameters:
    ///   - dispatchQueue: [DispatchQueue](https://www.raywenderlich.com/19454476-vision-tutorial-for-ios-detect-body-and-hand-pose)
    ///   - options: [VNImageOption : Any]
    ///   - maximumHandCount: [辨識幾隻手的數量 => VNDetectHumanHandPoseRequest](https://www.raywenderlich.com/19454476-vision-tutorial-for-ios-detect-body-and-hand-pose)
    ///   - result: Result<VNRequest, Error>
    func _detectHumanHandPoseRequest(dispatchQueue: DispatchQueue = .global(qos: .userInitiated), options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, result: @escaping (Result<VNDetectHumanHandPoseRequest, Error>) -> ()) {
        _detectRequest(for: VNDetectHumanHandPoseRequest.self, dispatchQueue: dispatchQueue, options: options, maximumHandCount: maximumHandCount, result: result)
    }
    
    /// [取得人臉辨識的結果 => 使用泛型選擇](https://medium.com/@zhgchgli/vision-初探-app-頭像上傳-自動識別人臉裁圖-swift-9a9aa892f9a9)
    /// - Parameters:
    ///   - type: T: VNImageBasedRequest
    ///   - dispatchQueue: [DispatchQueue](https://juejin.cn/post/6844903504469819399)
    ///   - options: [[VNImageOption : Any]](https://www.jianshu.com/p/59b43dbe4fbd)
    ///   - maximumHandCount: [辨識幾隻手的數量 => VNDetectHumanHandPoseRequest](https://www.raywenderlich.com/19454476-vision-tutorial-for-ios-detect-body-and-hand-pose)
    ///   - result: Result<VNRequest, Error>
    func _detectRequest<T: VNImageBasedRequest>(for type: T.Type, dispatchQueue: DispatchQueue = .global(qos: .userInitiated), options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, result: @escaping (Result<T, Error>) -> ()) {
        
        guard let ciImage = _ciImage(options: nil) else { result(.failure(WWFaceLandmarkDetection.CustomError.notImage)); return }
        
        let faceRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: options)
        var faceRequest = T { request, error in
            if let error = error { result(.failure(error)); return }
            result(.success(request as! T))
        }
        
        dispatchQueue.async {
            
            if let _faceRequest = faceRequest as? VNDetectHumanHandPoseRequest {
                _faceRequest.maximumHandCount = maximumHandCount
                faceRequest = _faceRequest as! T
            }
            
            do {
                try faceRequestHandler.perform([faceRequest])
            } catch {
                result(.failure(error))
            }
        }
    }
}


// MARK: - UIImageView (function)
extension UIImageView {
    
    /// [取得內部圖片的實際位置與大小](https://stackoverflow.com/questions/4711615/how-to-get-the-displayed-image-frame-from-uiimageview)
    /// - Returns: [CGRect?](https://sarunw.com/posts/how-to-resize-and-position-image-in-uiimageview-using-contentmode/)
    func _innerImageFrame() -> CGRect? {
        
        guard let image = image else { return nil }
        
        switch contentMode {
        case .scaleToFill: return bounds
        case .scaleAspectFit: return AVMakeRect(aspectRatio: image.size, insideRect: bounds)
        case .scaleAspectFill: return _aspectFillRect()
        default: return nil
        }
    }
    
    /// 計算.aspectFill時圖片的位置大小
    /// - Returns: CGRect
    func _aspectFillRect() -> CGRect {
        
        guard let image = image, bounds.size != .zero else { return .zero }
        
        let imageViewSize = bounds.size
        let imageSize = image.size
        let imageViewAspectRatio = imageViewSize._aspectRatio()
        let imageAspectRatio = imageSize._aspectRatio()
        
        if imageAspectRatio > imageViewAspectRatio {
            let newSize = image._scaledSize(toHeight: imageViewSize.height)
            return CGRect(origin: CGPoint._movePointWithSize(from: imageViewSize, to: newSize), size: newSize)
        }
        
        let newSize = image._scaledSize(toWidth: imageViewSize.width)
        return CGRect(origin: CGPoint._movePointWithSize(from: imageViewSize, to: newSize), size: newSize)
    }
}

// MARK: - UIImageView (for Vision)
extension UIImageView {
    
    /// [辨識圖片上人臉特徵點的位置](https://www.jianshu.com/p/83aa3983ac76)
    /// - Parameters:
    ///   - dispatchQueue: DispatchQueue
    ///   - landmarkTypes: [Constant.FaceLandmarkRegion]
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<[Constant.FeaturePoints]?, Error>
    func _detectFaceLandmarksBox(dispatchQueue: DispatchQueue = .global(qos: .userInitiated), landmarkTypes: [WWFaceLandmarkDetection.FaceLandmarkRegion], options: [VNImageOption : Any] = [:], result: @escaping (Result<[WWFaceLandmarkDetection.FeaturePoints]?, Error>) -> ()) {
        
        guard let innerImage = image else { result(.failure(WWFaceLandmarkDetection.CustomError.notImage)); return }
        
        innerImage._detectFaceLandmarksResult(dispatchQueue: dispatchQueue, options: options) { detectResult in
            
            switch detectResult {
            case .failure(let error): result(.failure(error))
            case .success(let detectResults):
                
                guard let detectResults = detectResults else { return result(.success(nil)) }
                
                DispatchQueue.main.async {
                    let featurePoints = detectResults.compactMap { $0._featurePoints(mirrorTo: self, landmarkTypes: landmarkTypes) }
                    result(.success(featurePoints))
                }
            }
        }
    }
}

// MARK: - VNFaceObservation (function)
extension VNFaceObservation {
    
    /// [將取得的比例大小 => 畫面上的大小 -> .scaleToFill / .scaleAspectFit](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/利用-cgaffinetransform-控制元件縮放-位移-旋轉的三種方法-dca1abbf9590)
    /// - Parameters:
    ///   - imageView: UIImageView
    ///   - landmarkTypes: [Constant.FaceLandmarkRegion]
    /// - Returns: Constant.FeaturePoints?
    func _featurePoints(mirrorTo imageView: UIImageView, landmarkTypes: [WWFaceLandmarkDetection.FaceLandmarkRegion]) -> WWFaceLandmarkDetection.FeaturePoints? {
        guard let innerImageFrame = imageView._innerImageFrame() else { return nil }
        return self._featurePoints(mirrorToFrame: innerImageFrame, landmarkTypes: landmarkTypes)
    }
    
    /// [轉換圖片上人臉關鍵點的位置 => 滿版](https://www.jianshu.com/p/59b43dbe4fbd)
    /// - Parameters:
    ///   - frame: 對應要顯示的UIView大小
    ///   - landmarkTypes: 人臉特徵點的類型 (左眼 / 右眼 / …)
    /// - Returns: Constant.FeaturePoints
    func _featurePoints(mirrorToFrame frame: CGRect, landmarkTypes: [WWFaceLandmarkDetection.FaceLandmarkRegion]) -> WWFaceLandmarkDetection.FeaturePoints {
        
        let faceBox = _convertRatio(mirrorTo: frame)
        
        var copyLandmarkTypes = landmarkTypes
        var faceRegion: WWFaceLandmarkDetection.FeaturePoints = (nil, [])
        
        if copyLandmarkTypes.contains(.allPoints) { copyLandmarkTypes = [.allPoints] }
        
        copyLandmarkTypes.forEach { region in
            
            let regionClass = region.toClass(with: self)
            let points = regionClass?._convertPoints(mirrorTo: frame, detectResult: self)
            
            faceRegion.landmarks.append(points)
        }
        
        faceRegion.box = faceBox
        return faceRegion
    }
    
    /// [將取得的比例大小 => 位置](https://medium.com/彼得潘的-swift-ios-app-開發問題解答集/83-利用-cgaffinetransform-縮放-位移和旋轉-e061df9ed672)
    /// - Parameter frame: [CGRect](https://medium.com/彼得潘的-swift-ios-app-開發教室/作業-52-使用-swiftui-預覽-uibezierpath-畫出喜歡角落的貓咪-ed4042a23303)
    /// - Returns: CGRect
    func _convertRatio(mirrorTo frame: CGRect) -> CGRect {
        return self.boundingBox._convertRatio(scaleX: 1.0, scaleY: -1.0, to: frame)
    }
}

// MARK: - VNFaceLandmarkRegion2D (function)
extension VNFaceLandmarkRegion2D {
    
    /// [轉換檢測出來臉上特徵點的位置 -> .scaleToFill / .scaleAspectFit](https://stackoverflow.com/questions/4711615/how-to-get-the-displayed-image-frame-from-uiimageview)
    /// - Parameters:
    ///   - frame: CGRect
    ///   - detectResult: VNFaceObservation
    /// - Returns: [CGPoint]
    func _convertPoints(mirrorTo imageView: UIImageView, detectResult: VNFaceObservation) -> [CGPoint]? {
        guard let innerImageFrame = imageView._innerImageFrame() else { return nil }
        return self._convertPoints(mirrorTo: innerImageFrame, detectResult: detectResult)
    }
    
    /// [轉換檢測出來特徵點的位置](https://medium.com/msapps-development/face-recognition-ios-fadfecb99b15)
    /// - Parameters:
    ///   - frame: CGRect
    ///   - detectResult: VNFaceObservation
    /// - Returns: [CGPoint]
    func _convertPoints(mirrorTo frame: CGRect, detectResult: VNFaceObservation) -> [CGPoint] {
        
        let faceBox = detectResult._convertRatio(mirrorTo: frame)
        
        let mirrorPoints = self.normalizedPoints.map({ normalizedPoint -> CGPoint in
            
            let px = faceBox.minX + (normalizedPoint.x * faceBox.width)
            let py = faceBox.minY + (1.0 - normalizedPoint.y) * faceBox.height

            return CGPoint(x: px, y: py)
        })
        
        return mirrorPoints
    }
}
