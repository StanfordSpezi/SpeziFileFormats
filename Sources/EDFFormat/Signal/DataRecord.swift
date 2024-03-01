//
// This source file is part of the Neurodevelopment Assessment and Monitoring System (NAMS) project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import NIO


public struct DataRecord<S: Sample> {
    public let channels: [Channel<S>]


    public init(channels: [EDFFormat.Channel<S>]) {
        self.channels = channels
    }
}


extension DataRecord: ByteEncodable {
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        for channel in channels {
            channel.encode(to: &byteBuffer, preferredEndianness: endianness)
        }
    }
}
