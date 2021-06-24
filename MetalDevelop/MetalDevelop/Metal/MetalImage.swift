//
//  MetalImage.swift
//  MetalDevelop
//
//  Created by 柳钰柯 on 2021/6/22.
//

import Foundation

class MetalImage {
    let width: Int
    let height: Int
    let data: Data
    init?(_ location: URL) {
        let fileExtension = location.pathExtension
        if fileExtension.lowercased() != "tga" {
            print("不支持的格式")
            return nil
        }
        guard let fileData = try? Data(contentsOf: location) else { return nil }
        guard let tgaInfo = fileData.withUnsafeBytes({ ptr in
            ptr.baseAddress?.load(as: TGAHeader.self)
        }) else { return nil }
        if tgaInfo.imageType != 2 {
            print("This image loader only supports non-compressed BGR(A) TGA files")
            return nil
        }
        if tgaInfo.colorMapType != 0 {
            print("This image loader doesn't support TGA files with a colormap")
            return nil
        }
        if tgaInfo.xOrigin != 0 || tgaInfo.yOrigin != 0 {
            print("This image loader doesn't support TGA files with a non-zero origin")
            return nil
        }
        if tgaInfo.bitsPerPixel != 32 && tgaInfo.bitsPerPixel != 24 {
            print("This image loader only supports 24-bit and 32-bit TGA files")
            return nil
        }
        let srcBytesPerPixel: Int
        if tgaInfo.bitsPerPixel == 32 {
            srcBytesPerPixel = 4
            if tgaInfo.bitsPerAlpha != 8 {
                print("This image loader only supports 32-bit TGA files with 8 bits of alpha")
                return nil
            }
        } else {
            srcBytesPerPixel = 3
            if tgaInfo.bitsPerAlpha != 0 {
                print("This image loader only supports 24-bit TGA files with no alpha")
                return nil
            }
        }
        width = Int(tgaInfo.width)
        height = Int(tgaInfo.height)
        let dataSize = width * height * 4
        var dstImageData = Array(repeating: UInt8(0), count: dataSize)
        let srcImageData = Array(Array(fileData)[MemoryLayout<TGAHeader>.size + Int(tgaInfo.IDSize) ..< fileData.count])
        for y in 0 ..< height {
            let srcRow = Int(tgaInfo.topOrigin) != 0 ? y : height - 1 - y
            for x in 0 ..< width {
                let srcColum = Int(tgaInfo.rightOrigin) != 0 ? width - 1 - x : x
                let srcPixelIndex = srcBytesPerPixel * (srcRow * width + srcColum)
                let dstPixelIndex = 4 * (y * width + x)
                dstImageData[dstPixelIndex + 0] = srcImageData[srcPixelIndex + 0]
                dstImageData[dstPixelIndex + 1] = srcImageData[srcPixelIndex + 1]
                dstImageData[dstPixelIndex + 2] = srcImageData[srcPixelIndex + 2]
                if tgaInfo.bitsPerPixel == 32 {
                    dstImageData[dstPixelIndex + 3] = srcImageData[srcPixelIndex + 3]
                } else {
                    dstImageData[dstPixelIndex + 3] = 255
                }
            }
        }
        data = Data(dstImageData)
    }
}
