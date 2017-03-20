//
//  Color+Hex.swift
//  Apic
//
//  Created by Juan Jose Arreola on 16/03/17.
//
//

#if os(OSX)
    import AppKit
    public typealias Color = NSColor
#else
    import UIKit
    public typealias Color = UIColor
#endif

extension Color {
    convenience init?(hex: String) {
        var format = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        format = (format.hasPrefix("#")) ? format.substring(from: format.index(format.startIndex, offsetBy: 1)) : format
        
        var value: UInt32 = 0
        if Scanner(string: format).scanHexInt32(&value) {
            if format.characters.count == 8 {
                self.init(red: CGFloat((value & 0xFF000000) >> 24) / 255.0,
                          green: CGFloat((value & 0x00FF0000) >> 16) / 255.0,
                          blue: CGFloat((value & 0x0000FF00) >> 8) / 255.0,
                          alpha: CGFloat((value & 0x000000FF)) / 255.0)
                return
            } else if format.characters.count == 6 {
                self.init(red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
                          green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
                          blue: CGFloat(value & 0x0000FF) / 255.0,
                          alpha: 1.0)
                return
            }
        }
        self.init()
        return nil
    }
}
