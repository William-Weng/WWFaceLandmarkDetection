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
    
    private var detectImageView: UIImageView?
    private var boxLayers: [CALayer] = []
    private(set) var overlayView: UIView?
    
    public static let shared = WWFaceLandmarkDetection()
}

// MARK: - 公開函式
public extension WWFaceLandmarkDetection {
    
    /// 參數設定
    /// - Parameter detectImageView: 要被偵測的UIImageView
    func setting(detectImageView: UIImageView) {
        self.detectImageView = detectImageView
        overlayView = .init()
        overlayView!.autolayout.cover(on: detectImageView)
    }
    
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
    
    /// 人臉特徵點標示
    /// - Parameters:
    ///   - landmarkTypes: 要標示的類型
    ///   - isDisplayBox: 是否顯示人臉標示外框
    ///   - lineWidth: 框線寬度
    ///   - lineColor: 框線顏色
    ///   - result: Result<[WWFaceLandmarkDetection.FeaturePoints], Error>
    func faceLandmarksBoxing(landmarkTypes: [FaceLandmarkRegion], isDisplayBox: Bool = true, lineWidth: CGFloat = 1.0, lineColor: UIColor = .green, result: ((Result<[WWFaceLandmarkDetection.FeaturePoints], Error>) -> Void)? = nil) {
        
        guard let overlayView = overlayView else { result?(.failure(CustomError.unsetting)); return }
        
        overlayView.layer.sublayers?._removeFromSuperlayer()
        
        faceLandmarks(landmarkTypes: landmarkTypes) { _result_ in
            
            switch _result_ {
            case .failure(let error): result?(.failure(error))
            case .success(let faceRegions):
                
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
                            
                            layer.cornerRadius = lineWidth * 0.5
                            overlayView.layer.addSublayer(layer)
                        }
                    }
                }
                
                result?(.success(faceRegions))
            }
        }
    }
}
