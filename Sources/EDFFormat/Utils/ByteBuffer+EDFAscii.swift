//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIO


extension ByteBuffer {
    mutating func writeEDFAsciiTrimming(_ value: String, length: Int) {
        self.writeEDFAscii(value.prefix(length), length: length)
    }

    mutating func writeEDFAscii(_ value: String, length: Int) {
        // TODO: assert everything is ascii!
        precondition(value.count <= length, "Tried to encode string that was longer than \(length) bytes: \"\(value)\"")
        let padding = String(repeating: " ", count: max(0, length - value.count))

        let previousIndex = writerIndex
        writeString(value)
        writeString(padding)
        assert(writerIndex == previousIndex + length, "Unexpected writer increase from \(previousIndex) to \(writerIndex) which is not a offset of \(length).")
    }

    mutating func writeEDFAsciiTrimming<Value: BinaryInteger>(_ value: Value, length: Int) {
        writeEDFAsciiTrimming(value.description(length), length: length)
    }

    mutating func writeEDFAscii<Value: BinaryInteger>(_ value: Value, length: Int) {
        writeEDFAscii(value.description, length: length)
    }
}
