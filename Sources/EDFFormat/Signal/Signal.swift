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
    public let transducerType: String
    /// Description of the applied filtering.
    public let prefiltering: String

    public var sampleCount: Int

    public let physicalMinimum: Int
    public let physicalMaximum: Int
    public let digitalMinimum: Int
    public let digitalMaximum: Int

    /// 32 bytes of reserved area.
    public let reserved: String


    public init(
        label: SignalLabel,
        transducerType: String? = nil,
        prefiltering: String? = nil,
        sampleCount: Int,
        physicalMinimum: Int,
        physicalMaximum: Int,
        digitalMinimum: Int,
        digitalMaximum: Int,
        reserved: String? = nil
    ) {
        self.label = label
        self.transducerType = transducerType ?? ""
        self.prefiltering = prefiltering ?? ""
        self.sampleCount = sampleCount
        self.physicalMinimum = physicalMinimum
        self.physicalMaximum = physicalMaximum
        self.digitalMinimum = digitalMinimum
        self.digitalMaximum = digitalMaximum
        self.reserved = reserved ?? ""
    }
}


extension Signal: Sendable {}


extension Signal {
    func verifyAsciiInput() throws {
        try verifyAsciiInput(label.rawValue, maxLength: 16, for: "signal.label")
        try verifyAsciiInput(transducerType, maxLength: 80, for: "signal.transducerType")
        try verifyAsciiInput(label.dimension, maxLength: 8, for: "signal.dimension")

        try verifyAsciiInput(physicalMinimum, maxLength: 8, for: "signal.physicalMinimum")
        try verifyAsciiInput(physicalMaximum, maxLength: 8, for: "signal.physicalMaximum")
        try verifyAsciiInput(digitalMinimum, maxLength: 8, for: "signal.digitalMinimum")
        try verifyAsciiInput(digitalMaximum, maxLength: 8, for: "signal.digitalMaximum")

        try verifyAsciiInput(prefiltering, maxLength: 80, for: "signal.prefiltering")
        try verifyAsciiInput(sampleCount, maxLength: 8, for: "signal.sampleCount")

        try verifyAsciiInput(reserved, maxLength: 32, for: "signal.reserved")
    }
}


extension Array: ByteEncodable where Element == Signal {
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.label.rawValue, length: 16)
        }
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.transducerType, length: 80)
        }
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.label.dimension, length: 8)
        }

        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.physicalMinimum, length: 8)
        }
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.physicalMaximum, length: 8)
        }
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.digitalMinimum, length: 8)
        }
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.digitalMaximum, length: 8)
        }

        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.prefiltering, length: 80)
        }
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.sampleCount, length: 8)
        }
        
        for header in self {
            byteBuffer.writeEDFAsciiTrimming(header.reserved, length: 32)
        }
    }
}
