//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import NIO


extension Float32: ByteCodable {
    /// Decodes a float from its byte representation.
    ///
    /// Decodes a `Float32` from a `ByteBuffer`.
    /// - Parameters:
    ///   - byteBuffer: The ByteBuffer to decode from.
    ///   - endianness: The endianness to use for decoding.
    public init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let bitPattern = UInt32(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }

        self.init(bitPattern: bitPattern)
    }

    /// Encodes a float to its byte representation.
    ///
    /// Encodes a `Float32` into a `ByteBuffer`.
    /// - Parameters:
    ///   - byteBuffer: The ByteBuffer to write to.
    ///   - endianness: The endianness to use for encoding.
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        bitPattern.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}


extension Float64: ByteCodable {
    /// Decodes a float from its byte representation.
    ///
    /// Decodes a `Float64` from a `ByteBuffer`.
    /// - Parameters:
    ///   - byteBuffer: The ByteBuffer to decode from.
    ///   - endianness: The endianness to use for decoding.
    public init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let bitPattern = UInt64(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }

        self.init(bitPattern: bitPattern)
    }

    /// Encodes a float to its byte representation.
    ///
    /// Encodes a `Float64` into a `ByteBuffer`.
    /// - Parameters:
    ///   - byteBuffer: The ByteBuffer to write to.
    ///   - endianness: The endianness to use for encoding.
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        bitPattern.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}
