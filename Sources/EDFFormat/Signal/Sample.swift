//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIO


/// A sample for a given channel.
///
/// A single sample value for a given channel in BDF file format (24-bit signed integer).
public struct BDFSample {
    /// The 24-bit sample value.
    public let value: Int32

    public init(_ value: Int32) {
        self.value = value
    }
}


/// A sample for a given channel.
///
/// A single sample value for a given channel in EDF file format (16-bit signed integer).
public struct EDFSample {
    /// The 16-bit sample value.
    public let value: Int16

    public init(_ value: Int16) {
        self.value = value
    }
}


public protocol Sample: ByteCodable, Sendable {
    associatedtype Value: BinaryInteger

    var value: Value { get }
}


extension BDFSample: Sample {}
extension EDFSample: Sample {}


extension BDFSample: ByteCodable {
    public init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let value = byteBuffer.readInt24(endianness: endianness) else {
            return nil
        }
        self.init(value)
    }

    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        byteBuffer.writeInt24(value, endianness: endianness)
    }
}


extension EDFSample: ByteCodable {
    public init?(from byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        guard let value = Int16(from: &byteBuffer, preferredEndianness: endianness) else {
            return nil
        }
        self.init(value)
    }

    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        value.encode(to: &byteBuffer, preferredEndianness: endianness)
    }
}
