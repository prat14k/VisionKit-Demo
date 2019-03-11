//
//  ProcessViewController.swift
//  VisionKitHack
//
//  Created by Prateek Sharma on 3/11/19.
//  Copyright © 2019 Prateek Sharma. All rights reserved.
//

import UIKit
import Vision

class ProcessViewController: UIViewController {

    var image: UIImage!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var processImgButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
    }

}

extension ProcessViewController {
    
    @IBAction private func processImage() {
        let orientation: CGImagePropertyOrientation
        switch image.imageOrientation {
        case .right: orientation = .right
        case .down: orientation = .down
        case .left: orientation = .left
        default: orientation = .up
        }

        let faceLandmarksReq = VNDetectFaceLandmarksRequest(completionHandler: handleFaceFeatures)
        let requestHandler = VNImageRequestHandler(cgImage: image.cgImage!, orientation: orientation ,options: [:])
        
        do {
            try requestHandler.perform([faceLandmarksReq])
        } catch {
            print(error)
        }

    }
    
    private func handleFaceFeatures(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNFaceObservation]
        else { fatalError("Unexpected Type;\nError: \(error?.localizedDescription ?? "nil")") }
        
        for face in observations {
            addLandMarks(to: face)
        }
    }
    
}

extension ProcessViewController {
    
    private func addLandMarks(to faceImage: VNFaceObservation) {
        var faceRect: CGRect {
            let w = faceImage.boundingBox.size.width * image.size.width
            let h = faceImage.boundingBox.size.height * image.size.height
            let x = faceImage.boundingBox.origin.x * image.size.width
            let y = faceImage.boundingBox.origin.y * image.size.height
            return CGRect(x: x, y: y, width: w, height: h)
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, true, 0.0)
        guard let context = UIGraphicsGetCurrentContext()  else { return }
        
        drawImage(in: context)
        draw(faceRect: faceRect, in: context)
        drawFor(landMarks: faceImage.landmarks?.faceContour, in: context, faceRect: faceRect, color: .yellow)
        drawFor(landMarks: faceImage.landmarks?.outerLips, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.innerLips, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.leftEye, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.rightEye, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.leftPupil, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.rightPupil, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.leftEyebrow, in: context, faceRect: faceRect, color: .yellow)
        drawFor(landMarks: faceImage.landmarks?.rightEyebrow, in: context, faceRect: faceRect, color: .yellow)
        drawFor(landMarks: faceImage.landmarks?.nose, in: context, faceRect: faceRect, color: .yellow, closePath: true)
        drawFor(landMarks: faceImage.landmarks?.noseCrest, in: context, faceRect: faceRect, color: .yellow)
        drawFor(landMarks: faceImage.landmarks?.medianLine, in: context, faceRect: faceRect, color: .yellow)
        
        // get the final image
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        // end drawing context
        UIGraphicsEndImageContext()
        imageView.image = finalImage
    }
    
}

extension ProcessViewController {
    
    private func drawImage(in context: CGContext) {
        image.draw(in: CGRect(origin: .zero, size: image.size))
        context.translateBy(x: 0, y: image.size.height)
        context.scaleBy(x: 1, y: -1)
    }
    
    private func draw(faceRect: CGRect, in context: CGContext) {
        context.saveGState()
        let path = UIBezierPath(rect: faceRect)
        UIColor.red.setStroke()
        path.lineWidth = 15
        path.stroke()
        context.restoreGState()
    }
    
    private func drawFor(landMarks: VNFaceLandmarkRegion2D?, in context: CGContext, faceRect: CGRect, color: UIColor, thickness: CGFloat = 10, closePath: Bool = false) {
        guard (landMarks?.normalizedPoints.count ?? 0) > 0  else { return }
        context.saveGState()
        if let landMarks = landMarks, landMarks.normalizedPoints.count > 1 {
            drawLine(alongPoints: landMarks.normalizedPoints, strokeColor: color, lineWidth: thickness, faceRect: faceRect, closePath: closePath)
        } else if let point = landMarks?.normalizedPoints[0] {
            drawArc(usingPoint: point, faceRect: faceRect, radius: thickness, fillColor: color)
        }
        
        context.saveGState()
    }
    
}

extension ProcessViewController {
    
    private func drawArc(usingPoint point: CGPoint, faceRect: CGRect, radius: CGFloat, fillColor: UIColor) {
        let centerPoint = CGPoint(x: faceRect.origin.x + (point.x * faceRect.width), y: faceRect.origin.y + (point.y * faceRect.height))
        let bezierPath = UIBezierPath(arcCenter: centerPoint, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
        fillColor.setFill()
        bezierPath.fill()
    }
    
    private func drawLine(alongPoints linePoints: [CGPoint], strokeColor: UIColor, lineWidth: CGFloat, faceRect: CGRect, closePath: Bool) {
        strokeColor.setStroke()
        let bezierPath = UIBezierPath()
        var isFirstPoint = true
        for point in linePoints {
            let nextPoint = CGPoint(x: faceRect.origin.x + (point.x * faceRect.width), y: faceRect.origin.y + (point.y * faceRect.height))
            if isFirstPoint {
                bezierPath.move(to: nextPoint)
                isFirstPoint = false
            } else {
                bezierPath.addLine(to: nextPoint)
            }
        }
        closePath ? bezierPath.close() : ()
        bezierPath.lineWidth = lineWidth
        bezierPath.stroke()
    }
    
}
