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


final class EDFEncodingTests: XCTestCase {
    func testEDFPlusHeaderEncoding() throws {
        let url: URL = try .createTmpFile(name: "edf-test.edf")
        let startDate: Date = try .createDate(year: 2024, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)

        let writer = try EDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testAF8EEGSignal]
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

    func testBDFPlusHeaderEncoding() throws {
        let url: URL = try .createTmpFile(name: "bdf-test.bdf")
        let startDate: Date = try .createDate(year: 2024, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)

        let writer = try BDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testAF8EEGSignal]
        )


        var buffer = ByteBuffer()
        writer.encodeHeader(to: &buffer)


        let string = buffer.readString(length: buffer.readableBytes)

        let headerLength = 512
        let recordCount = -1

        var prefixBuffer = ByteBuffer(bytes: [0xFF])
        let prefix = try XCTUnwrap(prefixBuffer.readString(length: 1))

        let expectedHeader =
            """
            \(prefix)BIOSEMI\
            P-1 M 26-May-1998 Test_Patient                                                  \
            Startdate 04-Mar-2024 R-1 I-1 Biopot                                            \
            04.03.24\
            18.51.10\
            \(headerLength.description)     \
            24BIT                                       \
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
            signals: [.testAF8EEGSignal]
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

    func testEDFFileCreation() throws {
        // swiftlint:disable:previous function_body_length

        let url: URL = try .createTmpFile(name: "edf-records-test.edf")
        let startDate: Date = try .createDate(year: 2024, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)


        let writer = try EDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testAF8EEGSignal, .testAF7EEGSignal]
        )

        try writer.writeHeader()

        let headerContent = try Data(contentsOf: url)
        let headerString = String(data: headerContent, encoding: .utf8)

        let headerLength = 768
        let expectedHeader = { (recordCount: Int) in
            """
            .       \
            P-1 M 26-May-1998 Test_Patient                                                  \
            Startdate 04-Mar-2024 R-1 I-1 Biopot                                            \
            04.03.24\
            18.51.10\
            \(headerLength.description)     \
                                                        \
            \(recordCount.description)\(recordCount > 0 ? " " : "")      \
            1       \
            2   \
            EEG AF8         \
            EEG AF7         \
            test-transducer                                                                 \
            test-transducer2                                                                \
            uV      \
            uV      \
            -200    \
            -202    \
            200     \
            202     \
            -250    \
            -252    \
            250     \
            252     \
            test-perfiltering                                                               \
            test-perfiltering2                                                              \
            5       \
            5       \
            This is reserved.               \
            This is reserved2.              \

            """
        }

        XCTAssertEqual(headerString, expectedHeader(-1))


        let record0 = DataRecord(channels: [
            // af8 signal
            Channel(samples: [
                EDFSample(1),
                EDFSample(-2),
                EDFSample(3),
                EDFSample(-4),
                EDFSample(5)
            ]),
            // af7 signal
            Channel(samples: [
                EDFSample(10),
                EDFSample(-20),
                EDFSample(30),
                EDFSample(-40),
                EDFSample(50)
            ])
        ])

        let record1 = DataRecord(channels: [
            // af8 signal
            Channel(samples: [
                EDFSample(1),
                EDFSample(-2),
                EDFSample(3),
                EDFSample(-4),
                EDFSample(5)
            ]),
            // af7 signal
            Channel(samples: [
                EDFSample(10),
                EDFSample(-20),
                EDFSample(30),
                EDFSample(-40),
                EDFSample(50)
            ])
        ])

        try writer.addRecord(record0)

        let fileContent0 = try Data(contentsOf: url)
        XCTAssert(fileContent0.count > headerLength)
        let record0Content = fileContent0[headerLength..<fileContent0.count]

        // record count is at offset 236
        let recordCountString0 = String(data: fileContent0[236..<236 + 8], encoding: .utf8)
        XCTAssertEqual(recordCountString0, "1       ")
        XCTAssertEqual(String(data: fileContent0[0..<headerLength], encoding: .utf8), expectedHeader(1))

        let expectedRecord = try XCTUnwrap(Data(
            hex: """
                 0100\
                 feff\
                 0300\
                 fcff\
                 0500\
                 \
                 0a00\
                 ecff\
                 1e00\
                 d8ff\
                 3200
                 """
        ))

        XCTAssertEqual(record0Content, expectedRecord)

        try writer.addRecord(record1)

        let fileContent1 = try Data(contentsOf: url)
        XCTAssert(fileContent1.count > headerLength + record0Content.count)
        let record1Content = fileContent1[(headerLength + record0Content.count)..<fileContent1.count]

        let recordCountString1 = String(data: fileContent1[236..<236 + 8], encoding: .utf8)
        XCTAssertEqual(recordCountString1, "2       ")
        XCTAssertEqual(String(data: fileContent1[0..<headerLength], encoding: .utf8), expectedHeader(2))

        XCTAssertEqual(record1Content, expectedRecord)
    }

    func testBDFFileCreation() throws {
        // swiftlint:disable:previous function_body_length

        let url: URL = try .createTmpFile(name: "bdf-records-test.bdf")
        let startDate: Date = try .createDate(year: 2024, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)


        let writer = try BDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testAF8EEGSignal, .testAF7EEGSignal]
        )

        try writer.writeHeader()

        let headerContent = try Data(contentsOf: url)
        let headerString = String(data: headerContent)

        let headerLength = 768
        let expectedHeader = { (recordCount: Int) in
            var prefixBuffer = ByteBuffer(bytes: [0xFF])
            let prefix = try XCTUnwrap(prefixBuffer.readString(length: 1))
            return """
                   \(prefix)BIOSEMI\
                   P-1 M 26-May-1998 Test_Patient                                                  \
                   Startdate 04-Mar-2024 R-1 I-1 Biopot                                            \
                   04.03.24\
                   18.51.10\
                   \(headerLength.description)     \
                   24BIT                                       \
                   \(recordCount.description)\(recordCount > 0 ? " " : "")      \
                   1       \
                   2   \
                   EEG AF8         \
                   EEG AF7         \
                   test-transducer                                                                 \
                   test-transducer2                                                                \
                   uV      \
                   uV      \
                   -200    \
                   -202    \
                   200     \
                   202     \
                   -250    \
                   -252    \
                   250     \
                   252     \
                   test-perfiltering                                                               \
                   test-perfiltering2                                                              \
                   5       \
                   5       \
                   This is reserved.               \
                   This is reserved2.              \

                   """
        }

        try XCTAssertEqual(headerString, expectedHeader(-1))


        let record0 = DataRecord(channels: [
            // af8 signal
            Channel(samples: [
                BDFSample(1),
                BDFSample(-2),
                BDFSample(3),
                BDFSample(-4),
                BDFSample(5)
            ]),
            // af7 signal
            Channel(samples: [
                BDFSample(10),
                BDFSample(-20),
                BDFSample(30),
                BDFSample(-40),
                BDFSample(50)
            ])
        ])

        let record1 = DataRecord(channels: [
            // af8 signal
            Channel(samples: [
                BDFSample(1),
                BDFSample(-2),
                BDFSample(3),
                BDFSample(-4),
                BDFSample(5)
            ]),
            // af7 signal
            Channel(samples: [
                BDFSample(10),
                BDFSample(-20),
                BDFSample(30),
                BDFSample(-40),
                BDFSample(50)
            ])
        ])

        try writer.addRecord(record0)

        let fileContent0 = try Data(contentsOf: url)
        XCTAssert(fileContent0.count > headerLength)
        let record0Content = fileContent0[headerLength..<fileContent0.count]

        // record count is at offset 236
        let recordCountString0 = String(data: fileContent0[236..<236 + 8], encoding: .utf8)
        XCTAssertEqual(recordCountString0, "1       ")
        try XCTAssertEqual(String(data: fileContent0[0..<headerLength]), expectedHeader(1))

        let expectedRecord = try XCTUnwrap(Data(
            hex: """
                 010000\
                 feffff\
                 030000\
                 fcffff\
                 050000\
                 \
                 0a0000\
                 ecffff\
                 1e0000\
                 d8ffff\
                 320000
                 """
        ))

        XCTAssertEqual(record0Content, expectedRecord)

        try writer.addRecord(record1)

        let fileContent1 = try Data(contentsOf: url)
        XCTAssert(fileContent1.count > headerLength + record0Content.count)
        let record1Content = fileContent1[(headerLength + record0Content.count)..<fileContent1.count]

        let recordCountString1 = String(data: fileContent1[236..<236 + 8], encoding: .utf8)
        XCTAssertEqual(recordCountString1, "2       ")
        try XCTAssertEqual(String(data: fileContent1[0..<headerLength]), expectedHeader(2))

        XCTAssertEqual(record1Content, expectedRecord)
    }

    func testErroneousAddRecordCalls() throws {
        let url: URL = try .createTmpFile(name: "edf-illegal-test.edf")
        let startDate: Date = try .createDate(year: 2024, month: 3, day: 4, hour: 18, minute: 51, second: 10)
        let birthdate: Date = try .createDate(year: 1998, month: 5, day: 26)


        let writer = try EDFFileWriter(
            url: url,
            information: .testFile(start: startDate, birthdate: birthdate),
            signals: [.testAF8EEGSignal]
        )

        XCTAssertThrowsError(try writer.addRecord(DataRecord(channels: []))) { error in
            XCTAssertEqual(error as? EDFEncodingError, .headerNotWritten)
        }

        try writer.writeHeader()

        XCTAssertThrowsError(try writer.addRecord(DataRecord(channels: []))) { error in
            XCTAssertEqual(error as? EDFEncodingError, .invalidChannelCount(expected: 1, received: 0))
        }

        XCTAssertThrowsError(try writer.addRecord(DataRecord(channels: [
            Channel(samples: []),
            Channel(samples: [])
        ]))) { error in
            XCTAssertEqual(error as? EDFEncodingError, .invalidChannelCount(expected: 1, received: 2))
        }

        XCTAssertThrowsError(try writer.addRecord(DataRecord(channels: [
            Channel(samples: [
            ])
        ]))) { error in
            XCTAssertEqual(error as? EDFEncodingError, .invalidSampleCount(channel: Signal.testAF8EEGSignal.label, expected: 5, received: 0))
        }

        XCTAssertThrowsError(try writer.addRecord(DataRecord(channels: [
            Channel(samples: [
                EDFSample(2),
                EDFSample(4),
                EDFSample(3)
            ])
        ]))) { error in
            XCTAssertEqual(error as? EDFEncodingError, .invalidSampleCount(channel: Signal.testAF8EEGSignal.label, expected: 5, received: 3))
        }
    }

    func testAnonymousPatient() throws {
        let patient = PatientInformation(code: "ASD", sex: nil, birthdate: nil, name: "Leland Stanford")
        XCTAssertEqual(patient.edfString, "ASD X X Leland_Stanford")
    }
}
