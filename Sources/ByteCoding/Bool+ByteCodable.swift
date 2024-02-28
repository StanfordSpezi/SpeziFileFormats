//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIO


extension Bool: ByteCodable {
    /// Decode a `Bool` from its byte representation.
    ///
    /// - Note: Note that the byte representation uses a whole byte.
    /// - Parameters:
    ///   - byteBuffer: The ByteBuffer to decode from.
    ///   - endianness: The endianness to use for decoding.
    public init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let bytes = byteBuffer.readBytes(length: 1),
              let byte = bytes.first else {
            return nil
        }

        self = byte > 0
    }

    /// Encodes a `Bool` to its byte representation.
    ///
    /// - Note: Note that the byte representation uses a whole byte.
    /// - Parameters:
    ///   - byteBuffer: The ByteBuffer to write to.
    ///   - endianness: The endianness to use for encoding.
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        byteBuffer.writeBytes([self ? 1 : 0])
    }
}
