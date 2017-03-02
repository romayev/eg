//
//  BookingAttributes.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/27/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation

enum JobType: Int {
    case adjustToSMC = 1, improve, createVersion, finalCheck, translation
    var localizedName: String {
        switch self {
        case .adjustToSMC:
            return NSLocalizedString("job-type.adjust-to-smc", comment: "")
        case.improve:
            return NSLocalizedString("job-type.improve", comment: "")
        case .createVersion:
            return NSLocalizedString("job-type.create-version", comment: "")
        case .finalCheck:
            return NSLocalizedString("job-type.final-check", comment: "")
        case .translation:
            return NSLocalizedString("job-type.translation", comment: "")
        }
    }

    static let all = [JobType.adjustToSMC, JobType.improve, JobType.createVersion, JobType.finalCheck, JobType.translation]
    static let localizedValues: [String] = {
        var values = [String]()
        for type in JobType.all {
            values.append(type.localizedName)
        }
        return values
    }()
}

enum Layout: Int {
    case one = 1, two, three
    var localizedName: String {
        switch self {
        case .one:
            return NSLocalizedString("layout.one", comment: "")
        case .two:
            return NSLocalizedString("layout.two", comment: "")
        case .three:
            return NSLocalizedString("layout.three", comment: "")
        }
    }

    static let all = [Layout.one, Layout.two, Layout.three]
    static let localizedValues: [String] = {
        var values = [String]()
        for type in Layout.all {
            values.append(type.localizedName)
        }
        return values
    }()
}

enum AspectRatio: Int {
    case standard = 1, widescreen
    var localizedName: String {
        switch self {
        case .standard:
            return NSLocalizedString("aspect-ratio.standard", comment: "")
        case .widescreen:
            return NSLocalizedString("aspect-ratio.widescreen", comment: "")
        }
    }

    static let all = [AspectRatio.standard, AspectRatio.widescreen]
    static let localizedValues: [String] = {
        var values = [String]()
        for type in AspectRatio.all {
            values.append(type.localizedName)
        }
        return values
    }()
}

enum Confidentiality: Int {
    case level1 = 1, level2, level3
    var localizedName: String {
        switch self {
        case .level1:
            return NSLocalizedString("confidentiality.level1", comment: "")
        case .level2:
            return NSLocalizedString("confidentiality.level2", comment: "")
        case .level3:
            return NSLocalizedString("confidentiality.level3", comment: "")
        }
    }

    static let all = [Confidentiality.level1, Confidentiality.level3, Confidentiality.level3]
    static let localizedValues: [String] = {
        var values = [String]()
        for type in Confidentiality.all {
            values.append(type.localizedName)
        }
        return values
    }()
}
