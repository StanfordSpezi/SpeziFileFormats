//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@_spi(TestingSupport) @testable import ByteCoding
@testable import EDFFormat
import Foundation
import NIO
import XCTest

// TODO: import XCTByteCoding?

final class EDFEncodingTests: XCTestCase {
    func testEDFPlusHeaderEncoding() throws {
        let url: URL = try .createTmpFile(name: "edf-test.edf")
        let startDate: Date = try .createDate(year: 2024, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)

        let writer = try EDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testEEGSignal]
        )


        var buffer = ByteBuffer()
        writer.encodeHeader(to: &buffer)


        let string = buffer.readString(length: buffer.readableBytes)

        let headerLength = 512
        let recordCount = -1

        let expectedHeader =
        """
        .       \
        P-1 M 26-May-1998 Test_Patient                                                  \
        Startdate 04-Mar-2024 R-1 I-1 Biopot                                            \
        04.03.24\
        18.51.10\
        \(headerLength.description)                                                 \
        \(recordCount.description)      \
        1       \
        1   \
        EEG AF8         \
        test-transducer                                                                 \
        uV      \
        -200    \
        200     \
        -250    \
        250     \
        test-perfiltering                                                               \
        5       \
        This is reserved.               \

        """
        XCTAssertEqual(string, expectedHeader)
    }

    func testEDFStartDateY2k() throws {
        let url: URL = try .createTmpFile(name: "edf-test-y2k.edf")
        let startDate: Date = try .createDate(year: 2094, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)


        let writer = try EDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testEEGSignal]
        )

        var buffer = ByteBuffer()
        writer.encodeHeader(to: &buffer)


        let string = buffer.readString(length: buffer.readableBytes)

        let headerLength = 512
        let recordCount = -1

        let expectedHeader =
            """
            .       \
            P-1 M 26-May-1998 Test_Patient                                                  \
            Startdate 04-Mar-2094 R-1 I-1 Biopot                                            \
            04.03.yy\
            18.51.10\
            \(headerLength.description)                                                 \
            \(recordCount.description)      \
            1       \
            1   \
            EEG AF8         \
            test-transducer                                                                 \
            uV      \
            -200    \
            200     \
            -250    \
            250     \
            test-perfiltering                                                               \
            5       \
            This is reserved.               \

            """
        XCTAssertEqual(string, expectedHeader)
    }
}
