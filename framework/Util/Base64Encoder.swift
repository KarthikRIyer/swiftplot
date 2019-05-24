import Foundation

public func encodeBase64PNG(pngBufferPointer: UnsafePointer<UInt8>, bufferSize: Int) -> String {
  let pngBuffer : NSData = NSData(bytes: pngBufferPointer, length: bufferSize)
  return pngBuffer.base64EncodedString(options: .lineLength64Characters)
}
