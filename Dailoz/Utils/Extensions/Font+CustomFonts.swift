//
//  Font+CustomFonts.swift
//  Dailoz
//
//  Created by Nanda WK on 2024-12-01.
//

import SwiftUICore

extension Font {
    static func robotoB(_ size: CGFloat) -> Font {
        .custom("Roboto-Bold", size: size)
    }

    static func robotoM(_ size: CGFloat) -> Font {
        .custom("Roboto-Medium", size: size)
    }

    static func robotoR(_ size: CGFloat) -> Font {
        .custom("Roboto-Regular", size: size)
    }
}
