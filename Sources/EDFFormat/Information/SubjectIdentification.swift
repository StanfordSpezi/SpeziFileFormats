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


/// The structured representation of the `Local Subject Identification` field specified by EDF+.
public struct PatientInformation {
    /// The sex of the patient as defined by the EDF+ spec.
    public enum Sex: String {
        /// Female sex.
        case female = "F"
        /// Male sex.
        case male = "M"
    }

    /// The code by which the patient is known in the hospital administration.
    public let code: String?
    /// The sex of the patient.
    public let sex: Sex?
    /// The birthdate of the patient.
    public let birthdate: Date?
    /// The name of the patient without spaces.
    public let name: String?


    public init(code: String? = nil, sex: Sex? = nil, birthdate: Date? = nil, name: String? = nil) {
        self.code = code
        self.sex = sex
        self.birthdate = birthdate
        self.name = name
    }
}


public enum SubjectIdentification {
    /// An unstructured representation of the subject as a `String`. Maximum length is 80 bytes.
    case unstructured(_ subject: String)
    /// A structured representation of the subject according to the EDF+ specification.
    case structured(_ subject: PatientInformation)
}


extension PatientInformation: Sendable {}
extension SubjectIdentification: Sendable {}


extension SubjectIdentification {
    func verifyAsciiInputs() throws {
        switch self {
        case let .unstructured(subject):
            try verifyAsciiInput(subject, maxLength: 80, for: "subjectIdentification")
        case let .structured(subject):
            try verifyAsciiInput(subject.edfString, maxLength: 80, for: "subjectIdentification")
        }
    }
}


extension PatientInformation: EDFRepresentable {
    private static var birthdayFormatter: DateFormatter {
        var formatter = DateFormatter()
        formatter.dateFormat = "dd-MMM-yyyy"
        return formatter
    }

    var edfString: String {
        code.edfString
            + " "
            + sex.edfString
            + " "
            + (birthdate.map { Self.birthdayFormatter.string(from: $0) } ?? "X")
            + " "
            + name.edfString
    }
}


extension PatientInformation.Sex: EDFRepresentable {
    var edfString: String {
        rawValue
    }
}


extension SubjectIdentification: ByteEncodable {
    public func encode(to byteBuffer: inout ByteBuffer, preferredEndianness endianness: Endianness) {
        switch self {
        case let .unstructured(subject):
            byteBuffer.writeEDFAsciiTrimming(subject, length: 80)
        case let .structured(subject):
            byteBuffer.writeEDFAsciiTrimming(subject.edfString, length: 80)
        }
    }
}
