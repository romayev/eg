//
//  Color.swift
//  grafixpool
//
//  Created by Alex Romayev on 3/5/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    struct Siemens {
        struct Traffic {
            static var red: UIColor {
                return UIColor(red:0.60, green:0.00, blue:0.00, alpha:1.0)
            }
            static var yellow: UIColor {
                return UIColor(red:1.00, green:0.73, blue:0.00, alpha:1.0)
            }
            static var green: UIColor {
                return UIColor(red:0.39, green:0.49, blue:0.18, alpha:1.0)
            }
        }
         //UIColor(red:0.92, green:0.47, blue:0.04, alpha:1.0)
        static var stone2: UIColor {
            return UIColor(red:0.75, green:0.80, blue:0.84, alpha:1.0)
        }
        static var blue3: UIColor {
            return UIColor(red:0.33, green:0.66, blue:0.73, alpha:1.0)
        }
    }
    struct HUZ {
        static var blue: UIColor {
            return UIColor(red:0.12, green:0.21, blue:0.38, alpha:1.0)
        }
        static var lightBlue: UIColor {
            return UIColor(red:0.13, green:0.53, blue:0.76, alpha:1.0)
        }
    }
    struct MBIC {
        static var grey: UIColor {
            return UIColor(red:0.40, green:0.40, blue:0.40, alpha:1.0)
        }
    }
}
