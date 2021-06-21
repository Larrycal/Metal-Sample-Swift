//
//  ReaderWriter.swift
//  AVCaptureSession
//
//  Created by 柳钰柯 on 2021/6/20.
//

import Foundation
import AVFoundation
import VideoToolbox

struct WriterConfigration {
    var outputURL: URL
    var settings: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecType.h264,
        AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill,
        // For simplicity, assume 16:9 aspect ratio.
        // For a production use case, modify this as necessary to match the source content.
        AVVideoWidthKey: 1920,
        AVVideoHeightKey: 1080,
        AVVideoCompressionPropertiesKey: [
            kVTCompressionPropertyKey_AverageBitRate: 6_000_000,
            kVTCompressionPropertyKey_ProfileLevel: kVTProfileLevel_H264_Main_AutoLevel
        ]
    ]
}

class ReaderWriter: NSObject {
    let assetWriter: AVAssetWriter
    let videoWriterInput: AVAssetWriterInput
    private(set) var isStartWritting: Bool = false
    
    init(writerConfigration: WriterConfigration) throws {
        assetWriter = try AVAssetWriter(outputURL: writerConfigration.outputURL, fileType: .mp4)
        videoWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerConfigration.settings)
        videoWriterInput.expectsMediaDataInRealTime = true
        assetWriter.add(videoWriterInput)
    }
    
    func start() -> Bool {
        guard !isStartWritting else { return false }
        if FileManager.default.fileExists(atPath: assetWriter.outputURL.path) {
            do {
                try FileManager.default.removeItem(at: assetWriter.outputURL)
            } catch {
                print(error)
                return false
            }
        }
        isStartWritting = assetWriter.startWriting()
        if !isStartWritting {
            assetWriter.finishWriting { }
            print(assetWriter.status, assetWriter.error)
        }
        return isStartWritting
    }
    
    func finish(_ completionHandler: (()->Void)?) {
        assetWriter.finishWriting {
            completionHandler?()
            self.isStartWritting = false
        }
    }
    
    func record(_ sampleBuffer: CMSampleBuffer) -> Error? {
        guard isStartWritting else { return nil }
        if !videoWriterInput.append(sampleBuffer) {
            return assetWriter.error!
        }
        return nil
    }
}
