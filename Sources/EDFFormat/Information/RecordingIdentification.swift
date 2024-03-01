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


public struct RecordingInformation {
    /// The start data and time of the recording.
    public let startDate: Date
    /// The hospital administration code of the investigation (e.g., EEG number or PSG number).
    public let code: String?
    /// A code specifying the responsible investigator or technician.
    public let investigatorCode: String?
    /// A code specifying the used equipment.
    public let equipmentCode: String?
}


public enum RecordingIdentification {
    /// An unstructured representation of the recording information as a `String`. Maximum length is 80 bytes.
    case unstructured(_ recording: String, startDate: Date)
    /// A structured representation of the recording information according to the EDF+ specification.
    case structured(_ recording: RecordingInformation)


    var startDate: Date {
        switch self {
        case let .unstructured(_, startDate):
            startDate
        case let .structured(recording):
            recording.startDate
        }
    }
}


extension RecordingInformation: EDFRepresentable {
    private static var longYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyyy"
        return formatter
    }

    var edfString: String {
        "Startdate "
            + Self.longYearFormatter.string(from: startDate)
            + " "
            + code.edfString
            + " "
            + investigatorCode.edfString
            + " "
            + equipmentCode.edfString
    }
}


extension RecordingIdentification: ByteEncodable {
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        switch self {
        case let .unstructured(recording, _):
            byteBuffer.writeEDFAscii(recording, length: 80)
        case let .structured(recording):
            byteBuffer.writeEDFAscii(recording.edfString, length: 80)
        }
    }
}
