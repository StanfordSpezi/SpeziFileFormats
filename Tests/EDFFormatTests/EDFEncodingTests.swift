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
    private lazy var testDate: Date? = {
        var components = DateComponents()
        components.year = 2024
        components.month = 3
        components.day = 4
        components.hour = 18
        components.minute = 51
        components.second = 10

        return Calendar.current.date(from: components)
    }()

    private lazy var birthDate: Date? = {
        var components = DateComponents()
        components.year = 1998
        components.month = 5
        components.day = 26

        return Calendar.current.date(from: components)
    }()

    func testEDFHeaderEncoding() throws {
        // swiftlint:disable:previous function_body_length

        let tmpDir = NSTemporaryDirectory()

        // TODO: FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: a, create: true)
        let url = try XCTUnwrap(NSURL.fileURL(withPathComponents: [tmpDir, "edf-test.edf"]))
        try "".write(to: url, atomically: true, encoding: .utf8)
        // TODO: FileManager.default.createFile(atPath: url.absoluteString, contents: nil)

        let startDate = try XCTUnwrap(self.testDate)
        let birthDate = try XCTUnwrap(self.birthDate)

        let file = FileInformation(
            subject: .structured(PatientInformation( // TODO: test anonymsous!
                code: "P-1",
                sex: .male,
                birthdate: birthDate,
                name: "Test Patient" // tests escaping!
                                                   )),
            recording: .structured(RecordingInformation(
                startDate: startDate,
                code: "R-1",
                investigatorCode: "I-1",
                equipmentCode: "Biopot"
            )),
            recordDuration: 1
        )

        let signal = Signal(
            label: .eeg(location: .af8, prefix: .micro),
            transducerType: "test-transducer",
            prefiltering: "test-perfiltering",
            sampleCount: 5,
            physicalMinimum: -200,
            physicalMaximum: 200,
            digitalMinimum: -250,
            digitalMaximum: 250,
            reserved: "This is reserved."
        )

        let writer = try EDFFileWriter(
            url: url,
            information: file,
            signals: [signal]
        )


        var buffer = ByteBuffer()

        writer.encodeHeader(to: &buffer)


        let string = buffer.readString(length: buffer.readableBytes)

        // TODO: date needs to be upper-cased
        // TODO: verify spaces!
        // TODO: digit too much in start date???
        // TODO: header length is 512 right?
        let expectedHeader =
        """
        .       \
        P-1 M 26-May-1998 Test_Patient                                                  \
        Startdate 04-Mar-2024 R-1 I-1 Biopot                                            \
        04.03.24\
        18.51.10\
        512                                                 \
        -1      \
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

        // ".       P-1 M 01-Mar-2024 Test_Patient
        // Startdate 01-Mar-02024 R-1 I-1 Biopot
        // 01.03.2416.45.44512                                                 -1      1       1   EEG AF8
        // test-transducer
        // uV      -200    200     -250    250
        // test-perfiltering
        // 5       This is reserved.               "
        XCTAssertEqual(string, expectedHeader)
    }
}
