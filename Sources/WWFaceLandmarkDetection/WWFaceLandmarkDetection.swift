//
//  WWFaceLandmarkDetection.swift
//  WWFaceLandmarkDetection
//
//  Created by William.Weng on 2025/11/19.
//

import Vision
import VisionKit
import WWAutolayoutConstraint

// MARK: - 人臉特徵點偵測
open class WWFaceLandmarkDetection {
    
    public private(set) var overlayView: UIView?
    
    private var detectImageView: UIImageView?
    private var boxLayers: [CALayer] = []
    
    public static let shared = WWFaceLandmarkDetection()
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
}

// MARK: - 公開函式 (人臉)
public extension WWFaceLandmarkDetection {
        
    /// 人臉特徵點資訊
    /// - Parameters:
    ///   - landmarkTypes: 要偵測的類型
    ///   - result: Result<[WWFaceLandmarkDetection.FeaturePoints], Error>
    func faceLandmarks(landmarkTypes: [FaceLandmarkRegion], result: @escaping (Result<[WWFaceLandmarkDetection.FeaturePoints], Error>) -> Void) {
        
        guard let detectImageView = detectImageView else { return result(.failure(CustomError.unsetting)) }
        
        boxLayers._removeFromSuperlayer()
        boxLayers = []
        
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
        overlayView.layer.sublayers?._removeFromSuperlayer()
        
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
        
        boxLayers._removeFromSuperlayer()
        boxLayers = []
        
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
        overlayView.layer.sublayers?._removeFromSuperlayer()
        
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

// MARK: - 公開函式 (非同步)
public extension WWFaceLandmarkDetection {
    
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
