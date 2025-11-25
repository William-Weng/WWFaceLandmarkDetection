//
//  WWFaceLandmarkDetection.swift
//  WWFaceLandmarkDetection
//
//  Created by William.Weng on 2025/11/19.
//

import Vision
import VisionKit
import WWAutolayoutConstraint
import AVFoundation

// MARK: - 人臉特徵點偵測
open class WWFaceLandmarkDetection {
    
    private class LandmarkShapeLayer: CAShapeLayer {}
    
    public static let shared = WWFaceLandmarkDetection()
    
    public private(set) var overlayView: UIView?
    
    private var detectImageView: UIImageView?
    private var boxLayers: [CALayer] = []
}

// MARK: - 公開函式 (設定)
public extension WWFaceLandmarkDetection {
    
    /// 參數設定
    /// - Parameter detectImageView: 要被偵測的UIImageView
    func setting(detectImageView: UIImageView) {
        self.detectImageView = detectImageView
        overlayView = .init()
        overlayView!.autolayout.cover(on: detectImageView)
    }
    
    /// 清除標示框
    func clearOverlayView() {
        boxLayers._removeFromSuperlayer()
        boxLayers = .init()
        overlayView?.layer.sublayers?._removeFromSuperlayer()
    }
}

// MARK: - 公開函式 (原始分析值)
public extension WWFaceLandmarkDetection {
    
    /// 人臉特徵點原始分析值
    /// - Parameters:
    ///   - image: UIImage
    ///   - options: [VNImageOption : Any]
    ///   - result: Result<[VNFaceObservation], Error>
    func originalFaceLandmarks(image: UIImage, options: [VNImageOption : Any] = [:], result: @escaping (Result<[VNFaceObservation], Error>) -> Void) {
        
        image._detectFaceLandmarksResult(options: options) { _result_ in
            
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let faceObservations):
                guard let faceObservations = faceObservations else { result(.failure(CustomError.isNull)); return }
                result(.success(faceObservations))
            }
        }
    }
    
    /// 手指頭特徵點原始分析值
    /// - Parameters:
    ///   - image: 待測圖片
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    ///   - result: Result<[VNHumanHandPoseObservation], Error>
    func originalHumanHandPosePoints(image: UIImage, options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, result: @escaping ((Result<[VNHumanHandPoseObservation], Error>) -> Void)) {
        
        image._detectHumanHandPoseResult(options: options, maximumHandCount: maximumHandCount) { _result_ in
            
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let humanHandPoseObservations):
                guard let humanHandPoseObservations = humanHandPoseObservations else { result(.failure(CustomError.isNull)); return }
                result(.success(humanHandPoseObservations))
            }
        }
    }
}

// MARK: - 公開函式 (人臉)
public extension WWFaceLandmarkDetection {
        
    /// 人臉特徵點資訊
    /// - Parameters:
    ///   - landmarkTypes: 要偵測的類型
    ///   - result: Result<[WWFaceLandmarkDetection.FeaturePoints], Error>
    func faceLandmarks(landmarkTypes: [FaceLandmarkRegion], result: @escaping (Result<[WWFaceLandmarkDetection.FeaturePoints], Error>) -> Void) {
        
        guard let detectImageView = detectImageView else { return result(.failure(CustomError.unsetting)) }
                
        detectImageView._detectFaceLandmarksBox(landmarkTypes: landmarkTypes) { _result_ in
            
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let faceRegions):
                guard let faceRegions = faceRegions else { return result(.failure(CustomError.isEmpty)) }
                result(.success(faceRegions))
            }
        }
    }
    
    /// 人臉數量
    /// - Parameters:
    ///   - result: (Result<Int, Error>)
    func faceLandmarkCount(result: @escaping (Result<Int, Error>) -> Void) {
        
        faceLandmarks(landmarkTypes: []) { _result_ in
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let faceRegions): result(.success(faceRegions.count))
            }
        }
    }
    
    /// 人臉特徵點標示
    /// - Parameters:
    ///   - landmarkTypes: 要標示的類型
    ///   - isDisplayBox: 是否顯示人臉標示外框
    ///   - lineWidth: 框線寬度
    ///   - lineColor: 框線顏色
    ///   - result: Result<[WWFaceLandmarkDetection.FeaturePoints], Error>
    func faceLandmarksBoxing(landmarkTypes: [FaceLandmarkRegion], isDisplayBox: Bool = true, lineWidth: CGFloat = 1.0, lineColor: UIColor = .green, result: ((Result<[WWFaceLandmarkDetection.FeaturePoints], Error>) -> Void)? = nil) {
        
        guard let overlayView = overlayView else { result?(.failure(CustomError.unsetting)); return }
        
        let this = self
        
        clearOverlayView()
        faceLandmarks(landmarkTypes: landmarkTypes) { _result_ in
            
            switch _result_ {
            case .failure(let error): result?(.failure(error))
            case .success(let faceRegions):
                this.drawFaceRegions(faceRegions, overlayView: overlayView, isDisplayBox: isDisplayBox, lineWidth: lineWidth, lineColor: lineColor)
                result?(.success(faceRegions))
            }
        }
    }
}

// MARK: - 公開函式 (手指頭)
public extension WWFaceLandmarkDetection {
        
    /// 手指頭特徵點
    /// - Parameters:
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    ///   - jointNames: 手指頭的部位
    ///   - result: Result<[[CGPoint]], Error>
    func humanHandPosePoints(options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, jointNames: [VNHumanHandPoseObservation.JointName] = [.thumbTip, .indexTip, .middleTip, .ringTip, .littleTip], result: ((Result<[[CGPoint]], Error>) -> Void)? = nil) {
        
        guard let detectImageView = detectImageView else { result?(.failure(CustomError.unsetting)); return }
        
        let this = self
        
        detectImageView._detectHumanHandPosePoints(options: options, maximumHandCount: maximumHandCount, jointNames: jointNames) { _result_ in
            switch _result_ {
            case .failure(let error): result?(.failure(error))
            case .success(let pointsArray):
                guard let pointsArray = pointsArray else { result?(.failure(CustomError.isNull)); return }
                result?(.success(pointsArray))
            }
        }
    }
    
    /// 手的數量
    /// - Parameters:
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    ///   - result: Result<Int, Error>
    func humanHandPosePointCount(options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, result: @escaping (Result<Int, Error>) -> Void) {
        
        humanHandPosePoints(options: options, maximumHandCount: maximumHandCount, jointNames: []) { _result_ in
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let pointsArray): result(.success(pointsArray.count))
            }
        }
    }
        
    /// 手指頭特徵點標示
    /// - Parameters:
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    ///   - jointNames: 手指頭的部位
    ///   - lineWidth: 框線寬度
    ///   - lineColor: 框線顏色
    ///   - result: Result<[[CGPoint]], Error>)
    func humanHandPosePointsBoxing(options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, jointNames: [VNHumanHandPoseObservation.JointName] = [.thumbTip, .indexTip, .middleTip, .ringTip, .littleTip], lineWidth: CGFloat = 8.0, lineColor: UIColor = .green, result: ((Result<[[CGPoint]], Error>) -> Void)? = nil) {
        
        guard let overlayView = overlayView else { result?(.failure(CustomError.unsetting)); return }
        
        let this = self
        
        clearOverlayView()
        humanHandPosePoints(options: options, maximumHandCount: maximumHandCount, jointNames: jointNames) { _result_ in
            switch _result_ {
            case .failure(let error): result?(.failure(error))
            case .success(let pointsArray):
                pointsArray.forEach({ points in
                    points.forEach { this.drawHumanHand(on: overlayView, center: $0, lineWidth: lineWidth, lineColor: lineColor)}
                })
            }
        }
    }
}

// MARK: - 公開函式 (影片)
public extension WWFaceLandmarkDetection {
        
    /// 動態人臉位置
    /// - Parameters:
    ///   - sampleBuffer: 影片取像緩衝
    ///   - previewLayer: 影片預覽畫面
    ///   - orientation: 圖片方向
    ///   - options: [VNImageOption : Any]
    ///   - mark: 等比縮放圖片大小
    ///   - result: Result<[CGRect], Error>
    func faceLandmarksBoundingBox(sampleBuffer: CMSampleBuffer, previewLayer: AVCaptureVideoPreviewLayer, orientation: UIImage.Orientation = .downMirrored, options: [VNImageOption : Any] = [:], mark: WWFaceLandmarkDetection.SizeMark? = nil, result: @escaping ((Result<[CGRect], Error>) -> Void)) {
        
        guard let bufferImage = sampleBuffer._uiImage(scale: UIScreen.main.scale, orientation: orientation),
              var normalizedImage = bufferImage._normalized()
        else {
            return result(.failure(CustomError.notImage))
        }
        
        if let mark = mark { normalizedImage = normalizedImage._scaled(for: mark) }
        
        originalFaceLandmarks(image: normalizedImage, options: options) { _result_ in
            
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let faces):
                
                guard !faces.isEmpty else { result(.success(.init())); return }
                
                let faceBoundingBoxOnScreens = faces.map { previewLayer.layerRectConverted(fromMetadataOutputRect: $0.boundingBox) }
                result(.success(faceBoundingBoxOnScreens))
            }
        }
    }
    
    /// 動態人臉標示
    /// - Parameters:
    ///   - sampleBuffer: 影片取像緩衝
    ///   - previewLayer: 影片預覽畫面
    ///   - orientation: 圖片方向
    ///   - options: [VNImageOption : Any]
    ///   - mark: 等比縮放圖片大小
    ///   - strokeColor: 框線顏色
    ///   - result: Result<Int, Error>
    func faceLandmarksBoundingBoxing(sampleBuffer: CMSampleBuffer, previewLayer: AVCaptureVideoPreviewLayer, strokeColor: UIColor = .green, orientation: UIImage.Orientation = .downMirrored, options: [VNImageOption : Any] = [:], mark: WWFaceLandmarkDetection.SizeMark? = nil, result: @escaping ((Result<Int, Error>) -> Void)) {
        
        if let sublayers = previewLayer.sublayers {
            sublayers.forEach { layer in Task { @MainActor in if layer is LandmarkShapeLayer { layer.removeFromSuperlayer() }}}
        }
        
        faceLandmarksBoundingBox(sampleBuffer: sampleBuffer, previewLayer: previewLayer) { _result_ in
            switch _result_ {
            case .failure(let error): result(.failure(error))
            case .success(let rects):
                                
                rects.forEach {
                    let shapeLayer = LandmarkShapeLayer()._path(CGPath(rect: $0, transform: nil))._fillColor(.clear)._strokeColor(strokeColor)
                    Task { @MainActor in previewLayer.addSublayer(shapeLayer) }
                }
                
                result(.success(rects.count))
            }
        }
    }
}

// MARK: - 公開函式 (非同步)
public extension WWFaceLandmarkDetection {
    
    /// 人臉特徵點原始分析值
    /// - Parameters:
    ///   - image: 待測圖片
    ///   - options: 用於描述影像的特定屬性
    /// - Returns: Result<[VNFaceObservation], Error>
    func originalFaceLandmarks(image: UIImage, options: [VNImageOption : Any] = [:]) async -> Result<[VNFaceObservation], Error> {
        
        await withCheckedContinuation { continuation in
            originalFaceLandmarks(image: image, options: options) { continuation.resume(returning: $0) }
        }
    }
    
    /// 手指頭特徵點原始分析值
    /// - Parameters:
    ///   - image: 待測圖片
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    /// - Returns: Result<[VNHumanHandPoseObservation], Error>
    func originalHumanHandPosePoints(image: UIImage, options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2) async -> Result<[VNHumanHandPoseObservation], Error> {
        
        await withCheckedContinuation { continuation in
            originalHumanHandPosePoints(image: image, options: options) { continuation.resume(returning: $0) }
        }
    }
    
    /// 人臉特徵點資訊
    /// - Parameters:
    ///   - landmarkTypes: 要偵測的類型
    /// - Returns: Result<[WWFaceLandmarkDetection.FeaturePoints], Error>
    func faceLandmarks(landmarkTypes: [FaceLandmarkRegion]) async -> Result<[WWFaceLandmarkDetection.FeaturePoints], Error> {
        
        await withCheckedContinuation { continuation in
            faceLandmarks(landmarkTypes: landmarkTypes) { continuation.resume(returning: $0) }
        }
    }
    
    /// 人臉數量
    /// - Returns: Result<Int, Error>
    func faceLandmarkCount() async -> Result<Int, Error> {
        
        await withCheckedContinuation { continuation in
            faceLandmarkCount() { continuation.resume(returning: $0) }
        }
    }
    
    /// 人臉特徵點標示
    /// - Parameters:
    ///   - landmarkTypes: 要標示的類型
    ///   - isDisplayBox: 是否顯示人臉標示外框
    ///   - lineWidth: 框線寬度
    ///   - lineColor: 框線顏色
    /// - Returns: Result<[WWFaceLandmarkDetection.FeaturePoints], Error>
    func faceLandmarksBoxing(landmarkTypes: [FaceLandmarkRegion], isDisplayBox: Bool = true, lineWidth: CGFloat = 1.0, lineColor: UIColor = .green) async -> Result<[WWFaceLandmarkDetection.FeaturePoints], Error> {
        
        await withCheckedContinuation { continuation in
            faceLandmarksBoxing(landmarkTypes: landmarkTypes, isDisplayBox: isDisplayBox, lineWidth: lineWidth, lineColor: lineColor) { continuation.resume(returning: $0) }
        }
    }
    
    /// 手指頭特徵點
    /// - Parameters:
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    ///   - jointNames: 手指頭的部位
    /// - Returns: Result<[[CGPoint]], Error>
    func humanHandPosePoints(options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, jointNames: [VNHumanHandPoseObservation.JointName] = [.thumbTip, .indexTip, .middleTip, .ringTip, .littleTip]) async -> Result<[[CGPoint]], Error> {
        
        await withCheckedContinuation { continuation in
            humanHandPosePoints(options: options, maximumHandCount: maximumHandCount, jointNames: jointNames) { continuation.resume(returning: $0) }
        }
    }
    
    /// 手的數量
    /// - Parameters:
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    /// - Returns: Result<Int, Error>
    func humanHandPosePointCount(options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2) async -> Result<Int, Error> {
        
        await withCheckedContinuation { continuation in
            humanHandPosePointCount(options: options, maximumHandCount: maximumHandCount) { continuation.resume(returning: $0) }
        }
    }
    
    /// 手指頭特徵點標示
    /// - Parameters:
    ///   - options: 用於描述影像的特定屬性
    ///   - maximumHandCount: 辨識幾隻手的數量
    ///   - jointNames: 手指頭的部位
    ///   - lineWidth: 框線寬度
    ///   - lineColor: 框線顏色
    /// - Returns: Result<[[CGPoint]], Error>
    func humanHandPosePointsBoxing(options: [VNImageOption : Any] = [:], maximumHandCount: Int = 2, jointNames: [VNHumanHandPoseObservation.JointName] = [.thumbTip, .indexTip, .middleTip, .ringTip, .littleTip], lineWidth: CGFloat = 1.0, lineColor: UIColor = .green) async -> Result<[[CGPoint]], Error> {
        
        await withCheckedContinuation { continuation in
            humanHandPosePointsBoxing(options: options, maximumHandCount: maximumHandCount, jointNames: jointNames, lineWidth: lineWidth, lineColor: lineColor) { continuation.resume(returning: $0) }
        }
    }
}

// MARK: - 公開函式 (非同步)
extension WWFaceLandmarkDetection {
    
    /// 動態人臉位置
    /// - Parameters:
    ///   - sampleBuffer: 影片取像緩衝
    ///   - previewLayer: 影片預覽畫面
    ///   - orientation: 圖片方向
    ///   - options: [VNImageOption : Any]
    ///   - mark: 等比縮放圖片大小
    /// - Returns: Result<[CGRect], Error>
    func faceLandmarksBoundingBox(sampleBuffer: CMSampleBuffer, previewLayer: AVCaptureVideoPreviewLayer, orientation: UIImage.Orientation = .downMirrored, options: [VNImageOption : Any] = [:], mark: WWFaceLandmarkDetection.SizeMark? = nil) async -> Result<[CGRect], Error> {
        
        await withCheckedContinuation { continuation in
            faceLandmarksBoundingBox(sampleBuffer: sampleBuffer, previewLayer: previewLayer, orientation: orientation, options: options, mark: mark) { continuation.resume(returning: $0) }
        }
    }
    
    /// 動態人臉標示
    /// - Parameters:
    ///   - sampleBuffer: 影片取像緩衝
    ///   - previewLayer: 影片預覽畫面
    ///   - orientation: 圖片方向
    ///   - options: [VNImageOption : Any]
    ///   - mark: 等比縮放圖片大小
    ///   - strokeColor: 框線顏色
    /// - Returns: Result<Int, Error>
    func faceLandmarksBoundingBoxing(sampleBuffer: CMSampleBuffer, previewLayer: AVCaptureVideoPreviewLayer, strokeColor: UIColor = .green, orientation: UIImage.Orientation = .downMirrored, options: [VNImageOption : Any] = [:], mark: WWFaceLandmarkDetection.SizeMark?) async -> Result<Int, Error> {
        
        await withCheckedContinuation { continuation in
            faceLandmarksBoundingBoxing(sampleBuffer: sampleBuffer, previewLayer: previewLayer, orientation: orientation, options: options, mark: mark) { continuation.resume(returning: $0) }
        }
    }
}

// MARK: - 小工具
private extension WWFaceLandmarkDetection {
    
    /// 標記人臉特徵點標示
    /// - Parameters:
    ///   - faceRegions: 人臉特徵點
    ///   - overlayView: 要被畫上的UIView
    ///   - isDisplayBox: 是否顯示人臉標示外框
    ///   - lineWidth: 框線寬度
    ///   - lineColor: 框線顏色
    func drawFaceRegions(_ faceRegions: [WWFaceLandmarkDetection.FeaturePoints], overlayView: UIView, isDisplayBox: Bool, lineWidth: CGFloat, lineColor: UIColor) {
        
        faceRegions.forEach { regions in
            
            if isDisplayBox, let frame = regions.box {
                let layer = CALayer()._frame(frame)._borderColor(lineColor)._borderWidth(lineWidth)
                overlayView.layer.addSublayer(layer)
            }
            
            regions.landmarks.forEach { points in
                
                guard let points = points else { return }
                
                points.forEach { point in
                    
                    let frame = CGRect(origin: point, size: CGSize(width: lineWidth, height: lineWidth))
                    let layer = CALayer()._frame(frame)._borderColor(lineColor)._borderWidth(lineWidth)
                    
                    overlayView.layer.addSublayer(layer)
                }
            }
        }
    }
    
    /// 畫出手指頭方框
    /// - Parameter center: CGPoint
    func drawHumanHand(on overlayView: UIView, center: CGPoint, lineWidth: CGFloat, lineColor: UIColor) {
        
        let frame = CGRect(origin: .zero, size: CGSize(width: lineWidth, height: lineWidth))
        let layer = CALayer()._frame(frame)._borderColor(lineColor)._borderWidth(lineWidth)._center(center)
        
        overlayView.layer.addSublayer(layer)
    }
}
