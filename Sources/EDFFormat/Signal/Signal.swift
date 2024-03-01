//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import Foundation
import NIO


public struct Signal {
    public let label: SignalLabel


    /// Transducer type description.
    ///
    /// 80 Byte string describing the transducer description.
    ///
    /// For example, "active electrode` or "respiration belt".
    public let transducerType: String?
    /// Description of the applied filtering.
    public let prefiltering: String?

    public var sampleCount: Int

    public let physicalMinimum: Int
    public let physicalMaximum: Int
    public let digitalMinimum: Int
    public let digitalMaximum: Int

    /// 32 bytes of reserved area.
    public let reserved: String?
}


extension Array: ByteEncodable where Element == Signal {
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        for header in self {
            byteBuffer.writeEDFAscii(header.label.rawValue, length: 16)
        }
        for header in self {
            byteBuffer.writeEDFAscii(header.transducerType ?? "", length: 80)
        }
        for header in self {
            byteBuffer.writeEDFAscii(header.label.dimension, length: 8)
        }

        for header in self {
            byteBuffer.writeEDFAscii(header.physicalMinimum, length: 8)
        }
        for header in self {
            byteBuffer.writeEDFAscii(header.physicalMaximum, length: 8)
        }
        for header in self {
            byteBuffer.writeEDFAscii(header.digitalMinimum, length: 8)
        }
        for header in self {
            byteBuffer.writeEDFAscii(header.digitalMaximum, length: 8)
        }

        for header in self {
            byteBuffer.writeEDFAscii(header.prefiltering ?? "", length: 80)
        }
        for header in self {
            byteBuffer.writeEDFAscii(header.sampleCount, length: 8)
        }
        
        for header in self {
            byteBuffer.writeEDFAscii(header.reserved ?? "", length: 32)
        }
    }
}
