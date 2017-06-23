//
//  AppTarget.swift
//  grafixpool
//
//  Created by Alex Romayev on 6/15/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

enum AppTarget {
    case smc, hez, mbic

    static var current: AppTarget {
        #if SMC
            return .smc
        #elseif HUZ
            return .hez
        #else
            return .mbic
        #endif
    }

    var hasOwnGraphics: Bool {
        switch self {
        case .smc:
            return true
        case .hez, .mbic:
            return false
        }
    }
    func customizeAppearance(application: UIApplication, window: UIWindow) {
        switch self {

        case .smc:
            let navbarTintColor = UIColor.Siemens.blue3
            let whiteColor = UIColor.white

            window.tintColor = navbarTintColor

            let navigationBar = UINavigationBar.appearance()
            navigationBar.tintColor = whiteColor
            navigationBar.barTintColor = navbarTintColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

            let font = UIFont(name: "Arial", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: whiteColor, NSFontAttributeName: font]
            UILabel.appearance().targetFontName = "Arial"
            UILabel.appearance().targetBoldFontName = "Arial-BoldMT"
        case .hez:
            let navbarTintColor = UIColor.HUZ.blue
            let whiteColor = UIColor.white

            window.tintColor = UIColor.HUZ.lightBlue

            let navigationBar = UINavigationBar.appearance()
            navigationBar.tintColor = whiteColor
            navigationBar.barTintColor = navbarTintColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

            let font = UIFont(name: "HelveticaNeue", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: whiteColor, NSFontAttributeName: font]
            UILabel.appearance().targetFontName = "HelveticaNeue"
            UILabel.appearance().targetBoldFontName = "Helvetica-Bold"
        case .mbic:
            let navbarTintColor = UIColor.black
            let whiteColor = UIColor.white

            window.tintColor = UIColor.MBIC.grey

            let navigationBar = UINavigationBar.appearance()
            navigationBar.tintColor = whiteColor
            navigationBar.barTintColor = navbarTintColor
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

            let font = UIFont(name: "Arial", size: 18.0) ?? UIFont.systemFont(ofSize: 18.0)
            navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: whiteColor, NSFontAttributeName: font]
            UILabel.appearance().targetFontName = "GillSans"
            UILabel.appearance().targetBoldFontName = "GillSans-Bold"
        }
    }
}

extension UILabel {
    var targetFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of: "Medium") == nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
    var targetBoldFontName : String {
        get { return self.font.fontName }
        set {
            if self.font.fontName.range(of: "Medium") != nil {
                self.font = UIFont(name: newValue, size: self.font.pointSize)
            }
        }
    }
}
