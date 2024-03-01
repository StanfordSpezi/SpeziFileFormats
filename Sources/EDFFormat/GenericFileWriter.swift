//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import ByteCoding
import Foundation
import NIO
import NIOFoundationCompat

public typealias EDFFileWriter = GenericFileWriter<EDFSample>


public typealias BDFFileWriter = GenericFileWriter<BDFSample>


// TODO: make different typealiases for the writer!
public class GenericFileWriter<S: Sample> { // TODO: sendable?
    private static var dataRecordsCountOffset: UInt64 {
        8 + 80 + 80 + 8 + 8 + 8 + 44
    }

    /// The file format.
    public let format: FileFormat
    /// File information
    public let fileInformation: FileInformation
    /// The format of the file records.
    private let dataFormat: FileRecordsFormat // TODO: make this readable for public interface?
    /// Array of signal descriptions.
    public let signals: [Signal]

    private let fileHandle: FileHandle
    private var dataRecordsCount: Int = -1 // TODO: write that in the end?
    private var writerIndex: UInt64 = 0
    private var didClose = false


    public var channelCount: Int {
        signals.count
    }

    private var headerLength: Int {
        256 * (1 + channelCount)
    }

    private init(url: URL, format: FileFormat, fileInformation: FileInformation, dataFormat: FileRecordsFormat, signals: [Signal]) throws {
        self.format = format
        self.fileInformation = fileInformation
        self.dataFormat = dataFormat
        self.signals = signals
        self.fileHandle = try FileHandle(forWritingTo: url)
    }


    public func writeHeader() throws {
        self.writerIndex = 0
        try fileHandle.seek(toOffset: writerIndex) // make sure we are at the start

        var header = ByteBuffer()
        header.reserveCapacity(headerLength)
        self.encodeHeader(to: &header)


        let headerData = header.getData(at: 0, length: header.readableBytes) ?? .init()
        try fileHandle.write(contentsOf: headerData)

        writerIndex += UInt64(headerData.count)
    }

    public func addRecord(_ record: DataRecord<S>) throws { // TODO defined
        try fileHandle.seek(toOffset: writerIndex)

        var recordBuffer = ByteBuffer()
        // TODO: reserve capacity!
        record.encode(to: &recordBuffer, preferredEndianness: .little) // TODO: specify preferred everywhere!

        let recordData = recordBuffer.getData(at: 0, length: recordBuffer.readableBytes) ?? .init()
        try fileHandle.write(contentsOf: recordData)

        writerIndex += UInt64(recordData.count)
        self.dataRecordsCount += 1
    }

    public func close() throws {
        // update the dataRecordsCount
        try fileHandle.seek(toOffset: Self.dataRecordsCountOffset)

        var countBuffer = ByteBuffer()
        countBuffer.reserveCapacity(8)
        countBuffer.writeEDFAscii(dataRecordsCount, length: 8)

        let countData = countBuffer.getData(at: 0, length: countBuffer.readableBytes) ?? .init()
        try fileHandle.write(contentsOf: countData)

        try fileHandle.close()
        didClose = true
    }

    deinit {
        if !didClose {
            try? close()
        }
    }
}


extension GenericFileWriter {
    private static var shortYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yy"
        return formatter
    }

    private static var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH.mm.ss"
        return formatter
    }

    func encodeHeader(to byteBuffer: inout ByteBuffer) {
        format.encode(to: &byteBuffer)

        fileInformation.subject.encode(to: &byteBuffer)
        fileInformation.recording.encode(to: &byteBuffer)

        // TODO: 2. The 'startdate' and 'starttime' fields in the header should contain only characters 0-9, and the period (.)
        //  as a separator, for example "02.08.51". In the 'startdate', use 1985 as a clipping date in order to avoid the Y2K problem.
        //  So, the years 1985-1999 must be represented by yy=85-99 and the years 2000-2084 by yy=00-84. After 2084, yy must be 'yy'
        //  and only item 4 of this paragraph defines the date.
        byteBuffer.writeEDFAscii(Self.shortYearFormatter.string(from: fileInformation.recording.startDate), length: 8)
        byteBuffer.writeEDFAscii(Self.timeFormatter.string(from: fileInformation.recording.startDate), length: 8)

        byteBuffer.writeEDFAscii(headerLength, length: 8)
        dataFormat.encode(to: &byteBuffer)

        byteBuffer.writeEDFAscii(dataRecordsCount, length: 8)
        byteBuffer.writeEDFAscii(fileInformation.recordDuration, length: 8)

        byteBuffer.writeEDFAscii(channelCount, length: 4)
        signals.encode(to: &byteBuffer)
    }
}


extension GenericFileWriter where S == EDFSample {
    public convenience init(url: URL, format: EDFRecordsFormat = .custom(), information: FileInformation, signals: [Signal]) throws {
        // swiftlint:disable:previous function_default_parameter_at_end
        try self.init(url: url, format: .edf, fileInformation: information, dataFormat: .init(from: format), signals: signals)
    }
}


extension GenericFileWriter where S == BDFSample {
    public convenience init(url: URL, format: FileFormat = .bdf, information: FileInformation, signals: [Signal]) throws {
        // swiftlint:disable:previous function_default_parameter_at_end

        let dataFormat: FileRecordsFormat
        switch format {
        case .edf:
            dataFormat = .biosemi
        case .bdf:
            dataFormat = .bits24
        }

        try self.init(url: url, format: format, fileInformation: information, dataFormat: dataFormat, signals: signals)
    }
}
