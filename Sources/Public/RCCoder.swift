//  MIT License

//  Copyright (c) 2020 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit

public final class RCCoder {
  
  public let configuration: RCCoderConfiguration
  public var scanningMode = ScanningMode.lightBackground {
    didSet {
      imageDecoder.pixelThreshold = scanningMode == .lightBackground ? RCConstants.lightBackgroundRange : RCConstants.darkBackgroundRange
    }
  }
  internal lazy var imageDecoder = RCImageDecoder(configuration: self.configuration)
  internal lazy var imageEncoder = RCImageEncoder(configuration: self.configuration)
  internal lazy var bitCoder = RCBitCoder(configuration: self.configuration)
  
  public init(configuration: RCCoderConfiguration = .defaultConfiguration) {
    self.configuration = configuration
  }
}

public extension RCCoder {
  func encode(_ image: RCImage) throws -> UIImage {
    let bits = try bitCoder.encode(message: image.message)
    let image = imageEncoder.encode(image, bits: bits)
    return image
  }
  
  func decode(_ image: UIImage) throws -> String {
    guard image.size.width == image.size.height else { throw RCError.wrongImageSize }
    imageDecoder.size = image.cgImage!.height
    imageDecoder.bytesPerRow = image.cgImage!.height
    let bits = try imageDecoder.decode(image)
    let message = try bitCoder.decode(bits)
    return message
  }
  
  func validate(_ text: String) -> Bool {
    configuration.validate(text)
  }
}

public extension RCCoder {
  enum ScanningMode {
    case lightBackground
    case darkBackground
  }
}

extension RCCoder {
  
  public func decode(buffer: UnsafeMutablePointer<UInt8>) throws -> String {
    let bits = try imageDecoder.process(pointer: buffer)
    let message = try bitCoder.decode(bits)
    return message
  }
}

