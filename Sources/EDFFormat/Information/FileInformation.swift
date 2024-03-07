//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Static information about an BDF(+)/EDF(+) file.
public struct FileInformation {
    /// The local subject identification for the recording.
    public let subject: SubjectIdentification
    /// The local recording identification.
    public let recording: RecordingIdentification
    /// The duration in seconds of a single data record.
    public let recordDuration: Int


    /// Create a new file information.
    /// - Parameters:
    ///   - subject: The local subject identification for the recording.
    ///   - recording: The local recording identification.
    ///   - recordDuration: The duration in seconds of a single data record.
    public init(subject: SubjectIdentification, recording: RecordingIdentification, recordDuration: Int) {
        self.subject = subject
        self.recording = recording
        self.recordDuration = recordDuration
    }
}


extension FileInformation: Hashable, Sendable {}


extension FileInformation {
    func verifyAsciiInputs() throws {
        try subject.verifyAsciiInputs()
        try recording.verifyAsciiInputs()
        try verifyAsciiInput(recordDuration, maxLength: 8, for: "recordDuration")
    }
}
