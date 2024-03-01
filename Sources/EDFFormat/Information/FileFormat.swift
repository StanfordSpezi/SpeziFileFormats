//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIO


public enum FileFormat {
    /// European Data Format
    ///
    /// 16-bit signals.
    case edf
    /// BioSemi Data Format.
    ///
    /// 24-bit signals.
    case bdf
}


extension FileFormat: ByteEncodable {
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        switch self {
        case .edf:
            byteBuffer.writeEDFAscii(".", length: 8)
        case .bdf:
            byteBuffer.writeInteger(UInt8.max)
            byteBuffer.writeString("BIOMSEMI")
        }
    }
}
