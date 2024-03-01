//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


public struct SignalLabel {
    public let type: SignalType
    public let location: String?
    public let dimension: String

    var rawValue: String {
        type.rawValue
            + (location.map { " " + $0 } ?? "")
    }

    fileprivate init(type: SignalType, location: String? = nil, prefix: DimensionPrefix = .none, dimension: String? = nil) {
        self.type = type
        self.location = location
        self.dimension = dimension.map { prefix.rawValue + $0 } ?? ""
    }
}

extension SignalLabel {
    public static func distance(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .distance, location: location, prefix: prefix, dimension: "m")
    }

    public static func area(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .area, location: location, prefix: prefix, dimension: "m^2")
    }

    public static func volume(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .volume, location: location, prefix: prefix, dimension: "m^3")
    }

    public static func duration(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .duration, location: location, prefix: prefix, dimension: "s")
    }

    public static func velocity(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .velocity, location: location, prefix: prefix, dimension: "m/s")
    }

    public static func mass(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .mass, location: location, prefix: prefix, dimension: "g")
    }

    public static func angle(location: String? = nil, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .angle, location: location, prefix: prefix, dimension: "deg") // TODO: dimension: rad, deg
    }

    public static func percentage(location: String? = nil) -> SignalLabel {
        SignalLabel(type: .mass, location: location, dimension: "%")
    }

    public static func money(location: String? = nil) -> SignalLabel { // TODO: unit!
        SignalLabel(type: .money, location: location, dimension: "EUR")
    }
}

extension SignalLabel {
    public static func eeg(location: EEGLocation, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .eeg, location: location.rawValue, prefix: prefix, dimension: "V") // TODO: this is not quire right, e.g. Fpz-Cz
    }

    public static func ecg(location: String, prefix: DimensionPrefix = .none) -> SignalLabel { // TODO: support typed dimension!
        SignalLabel(type: .ecg, location: location, prefix: prefix, dimension: "V")
    }

    public static func eog(location: String, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .eog, location: location, prefix: prefix, dimension: "V")
    }

    public static func erg(location: String, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .erg, location: location, prefix: prefix, dimension: "V")
    }

    public static func emg(location: String, prefix: DimensionPrefix = .none) -> SignalLabel {
        SignalLabel(type: .emg, location: location, prefix: prefix, dimension: "V") // TODO: LAT???
    }

    public static func meg(location: String) -> SignalLabel {
        SignalLabel(type: .meg, location: location)
    }

    public static func mcg(location: String) -> SignalLabel {
        SignalLabel(type: .mcg, location: location)
    }

    public static func evokedPotential(location: String) -> SignalLabel {
        SignalLabel(type: .evokedPotential, location: location) // TODO: two electrodes?
    }
}


extension SignalLabel {
    public static func temperature(location: String? = nil, dimension: String) { // TODO: support K, degC, degF
        SignalLabel(type: .temperature, location: location, dimension: dimension)
    }

    public static func respiration(location: String? = nil) {
        SignalLabel(type: .respiration, location: location)
    }

    public static func oxygenSaturation(location: String? = nil) {
        SignalLabel(type: .oxygenSaturation, location: location, dimension: "%")
    }

    public static func light(location: String? = nil) {
        SignalLabel(type: .light, location: location)
    }

    public static func sound(location: String? = nil) {
        SignalLabel(type: .sound, location: location)
    }

    public static func soundPressureLevel(dimension: String) { // TODO: support dimension
        SignalLabel(type: .sound, location: "SPL", dimension: dimension)
    }

    public static func events(location: String? = nil) {
        SignalLabel(type: .events, location: location)
    }
}


extension SignalLabel {
    public static func custom(type: SignalType, location: String? = nil, prefix: DimensionPrefix = .none, dimension: String? = nil) {
        SignalLabel(type: type, location: location, prefix: prefix, dimension: dimension)
    }
}
