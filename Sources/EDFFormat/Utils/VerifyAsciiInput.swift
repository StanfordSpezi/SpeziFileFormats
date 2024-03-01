//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// Errors that can occur when encoding a EDF/BDF file.
public enum EDFEncodingError: Error {
    /// A provided field was too long to represent in the EDF file.
    case inputTooLong(field: String, _ value: String, expectedLength: Int)
    /// Non-ascii character was found in the given string.
    case invalidCharacter(field: String, _ character: Character, value: String)
}


func verifyAsciiInput<Value: BinaryInteger>(_ value: Value, maxLength: Int, for field: String) throws {
    try verifyAsciiInput(value.description, maxLength: maxLength, for: field)
}


func verifyAsciiInput(_ value: String, maxLength: Int, for field: String) throws {
    if value.count > maxLength {
        throw EDFEncodingError.inputTooLong(field: field, value, expectedLength: maxLength)
    }

    for character in value where !character.isASCII {
        throw EDFEncodingError.invalidCharacter(field: field, character, value: value)
    }
}


extension String {
    var isASCII: Bool {
        allSatisfy { character in
            character.isASCII
        }
    }
}
