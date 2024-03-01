//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import NIO


extension ByteBuffer {
    mutating func writeEDFAscii(_ value: String, length: Int) {
        let prefix = value.prefix(length)
        let padding = String(repeating: " ", count: max(0, length - prefix.count))

        let previousIndex = writerIndex
        // TODO: assert everything is ascii!
        writeString(String(prefix))
        writeString(padding)
        assert(writerIndex == previousIndex + length, "Unexpected writer increase from \(previousIndex) to \(writerIndex) which is not a offset of \(length).")
    }

    mutating func writeEDFAscii<Value: BinaryInteger>(_ value: Value, length: Int) {
        // TODO: how to cutoff numbers?
        writeEDFAscii(value.description, length: length)
    }
}
