//
//  Colors.swift
//  Utility
//
//  Created by 柳钰柯 on 2021/6/18.
//

import Foundation
import UIKit

public struct Colors {
    
}
public extension Colors {
    struct Nord {
        // MARK: - Polar Night is made up of four darker colors that are commonly used for base elements like backgrounds or text color in bright ambiance designs.
        ///  0x2E3440 RGB:46,52,64
        ///  The origin color or the Polar Night palette.
        ///  For dark ambiance designs, it is used for background and area coloring while it's not used for syntax highlighting at all because otherwise it would collide with the same background color.
        ///  For bright ambiance designs, it is used for base elements like plain text, the text editor caret and reserved syntax characters like curly- and square brackets.
        ///  It is rarely used for passive UI elements like borders, but might be possible to achieve a higher contrast and better visual distinction (harder/not flat) between larger components.
        public static var nord0: UIColor = UIColor(hexValue: 0x2E3440)
        
        /// 0x2E3440 RGB:59,66,82
        /// A brighter shade color based on nord0.
        /// For dark ambiance designs it is used for elevated, more prominent or focused UI elements like
        /// * status bars and text editor gutters
        /// * panels, modals and floating popups like notifications or auto completion
        /// * user interaction/form components like buttons, text/select fields or checkboxes
        /// It also works fine for more inconspicuous and passive elements like borders or as dropshadow between different components.
        /// There's currently no official port project that makes use of it for syntax highlighting.
        /// For bright ambiance designs, it is used for more subtle/inconspicuous UI text elements that do not need so much visual attention.
        /// Other use cases are also state animations like a more brighter text color when a button is hovered, active or focused.
        public static var nord1: UIColor = UIColor(hexValue: 0x3B4252)
        
        /// 0x434C5E RGB:67,76,94
        /// An even more brighter shade color of nord0.
        /// For dark ambiance designs, it is used to colorize the currently active text editor line as well as selection- and text highlighting color.
        /// For both bright & dark ambiance designs it can also be used as an brighter variant for the same target elements like nord1.
        public static var nord2: UIColor = UIColor(hexValue: 0x434C5E)
        
        /// 0x4C566A RGB:76,86,106
        /// The brightest shade color based on nord0.
        /// For dark ambiance designs, it is used for UI elements like indent- and wrap guide marker.
        /// In the context of code syntax highlighting it is used for comments and invisible/non-printable characters.
        /// For bright ambiance designs, it is, next to nord1 and nord2 as darker variants, also used for the most subtle/inconspicuous UI text elements that do not need so much visual attention.
        public static var nord3: UIColor = UIColor(hexValue: 0x4C566A)
        
        // MARK: - Snow Storm is made up of three bright colors that are commonly used for text colors or base UI elements in bright ambiance designs.
        
        /// 0x2E3440 RGB:59,66,82
        /// The palette can be used for two different shading ambiance styles:
        /// * bright to dark — This is the recommended style that uses nord6 as base color and highlights other UI elements with nord5 and nord4.
        /// * dark to bright (semi-light) — This style uses nord4 as base color and highlights other UI elements with nord5 and nord6.
        /// The documentation of the different colors from this palette are based on the recommended bright to dark ambiance style.
        /// To apply the color purposes to the dark to bright style the definitions can be used in reversed order.
        public static var nord4: UIColor = UIColor(hexValue: 0xD8DEE9)
        
        /// 0xE5E9F0 RGB:229,233,240
        /// A brighter shade color of nord4.
        /// For dark ambiance designs, it is used for more subtle/inconspicuous UI text elements that do not need so much visual attention.
        /// Other use cases are also state animations like a more brighter text color when a button is hovered, active or focused.
        /// For bright ambiance designs, it is used to colorize the currently active text editor line as well as selection- and text highlighting color.
        public static var nord5: UIColor = UIColor(hexValue: 0xE5E9F0)
        
        
        /// 0xECEFF4 RGB：236,239,244
        /// The brightest shade color based on nord4.
        /// For dark ambiance designs, it is used for elevated UI text elements that require more visual attention.
        /// In the context of syntax highlighting it is used as text color for plain text as well as reserved and structuring syntax characters like curly- and square brackets.
        /// For bright ambiance designs, it is used as background and area coloring while it's not used for syntax highlighting at all because otherwise it would collide with the same background color.
        public static var nord6: UIColor = UIColor(hexValue: 0xECEFF4)
        
        
        // MARK: - Frost can be described as the heart palette of Nord, a group of four bluish colors that are commonly used for primary UI component and text highlighting and essential code syntax elements.
        
        /// 0x8FBCBB RGB:143, 188, 187
        /// A calm and highly contrasted color reminiscent of frozen polar water.
        /// Used for UI elements that should, next to the primary accent color nord8, stand out and get more visual attention.
        /// In the context of syntax highlighting it is used for classes, types and primitives.
        public static var nord7: UIColor = UIColor(hexValue: 0x8FBCBB)
        
        /// 0x88C0D0 RGB:136, 192, 208
        /// The bright and shiny primary accent color reminiscent of pure and clear ice.
        ///
        /// Used for primary UI elements with main usage purposes that require the most visual attention.
        /// In the context of syntax highlighting it is used for declarations, calls and execution statements of functions, methods and routines.
        public static var nord8: UIColor = UIColor(hexValue: 0x88C0D0)
        
        /// 0x81A1C1 RGB:129, 161, 193
        /// A more darkened and less saturated color reminiscent of arctic waters.
        ///
        /// Used for secondary UI elements that also require more visual attention than other elements.
        /// In the context of syntax highlighting it is used for language specific, syntactic and reserved keywords as well as
        ///
        /// * support characters
        /// * operators
        /// * tags
        /// * units
        /// * punctuations like (semi)colons, points and commas
        public static var nord9: UIColor = UIColor(hexValue: 0x81A1C1)
        
        /// 0x5E81AC RGB:94, 129, 172
        /// A dark and intensive color reminiscent of the deep arctic ocean.
        ///
        /// Used for tertiary UI elements that require more visual attention than default elements.
        /// In the context of syntax highlighting it is used for pragmas, comment keywords and pre-processor statements.
        public static var nord10: UIColor = UIColor(hexValue: 0x5E81AC)
        
        // MARK: - Aurora consists of five colorful components reminiscent of the „Aurora borealis“, sometimes referred to as polar lights or northern lights.
        
        /// 0xBF616A RGB:191, 97, 106
        /// Used for UI elements that are rendering error states like linter markers and the highlighting of Git diff deletions.
        /// In the context of syntax highlighting it is used to override the highlighting of syntax elements that are detected as errors.
        public static var nord11: UIColor = UIColor(hexValue: 0xBF616A)
        
        /// 0xD08770 RGB:208, 135, 112
        /// Rarely used for UI elements, but it may indicate a more advanced or dangerous functionality.
        /// In the context of syntax highlighting it is used for special syntax elements like annotations and decorators.
        public static var nord12: UIColor = UIColor(hexValue: 0xD08770)
        
        /// 0xEBCB8B 235, 203, 139
        /// Used for UI elements that are rendering warning states like linter markers and the highlighting of Git diff modifications.
        /// In the context of syntax highlighting it is used to override the highlighting of syntax elements that are detected as warnings as well as escape characters and within regular expressions.
        public static var nord13: UIColor = UIColor(hexValue: 0xEBCB8B)
        
        /// 0xA3BE8C RGB:163, 190, 140
        /// Used for UI elements that are rendering success states and visualizations and the highlighting of Git diff additions.
        /// In the context of syntax highlighting it is used as main color for strings of any type like double/single quoted or interpolated.
        public static var nord14: UIColor = UIColor(hexValue: 0xA3BE8C)
        
        /// 0xB48EAD RGB:180, 142, 173
        /// Rarely used for UI elements, but it may indicate a more uncommon functionality.
        /// In the context of syntax highlighting it is used as main color for numbers of any type like integers and floating point numbers.
        public static var nord15: UIColor = UIColor(hexValue: 0xB48EAD)
    }
}
