/*
 The MIT License (MIT)
 
 Copyright (c) 2019 Hèctor Marquès Ranea
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import Foundation

extension AnyDateParser {
    public static func dateFormatPattern(fromReferenceDateLayout layout: String,
                                         ignoreUnsupportedComponents: Bool = false,
                                         preferTimeZoneIdentifier: Bool = true,
                                         format24hStartsAtZero: Bool = true,
                                         format12hStartsAtZero: Bool = false) throws -> String {
        var remaining = layout
        var pattern = layout
        for conversion in conversions(preferTimeZoneIdentifier: preferTimeZoneIdentifier,
                                      format24hStartsAtZero: format24hStartsAtZero,
                                      format12hStartsAtZero: format12hStartsAtZero) {
            guard let replacement = conversion.1 else {
                if ignoreUnsupportedComponents {
                    continue
                } else {
                    throw Error.unsupportedLayoutComponent(layout: layout, component: conversion.0)
                }
            }
            if let range = remaining.range(of: conversion.0) {
                remaining.replaceSubrange(range, with: "")
                pattern = pattern.replacingOccurrences(of: conversion.0, with: replacement)
            }
        }
        return pattern
    }

    private static func conversions(preferTimeZoneIdentifier: Bool, format24hStartsAtZero: Bool, format12hStartsAtZero: Bool) -> [(String, String?)] {
        // TODO: provide real implementation (see https://golang.org/src/time/format.go)
        return [
            ("Mountain Standard Time", "zzzz"),
            ("-07:00:00", nil),
            ("MST-07:00", "ZZZZ"),
            ("07:00:00", nil),
            ("January", "MMMM"),
            (".000000", ".SSSSSS"),
            (".999999", ".SSSSSS"),
            (",000000", ",SSSSSS"),
            (",999999", ",SSSSSS"),
            ("-070000", "xxxx"),
            ("070000", nil),
            ("-07:00", "ZZZZZ"),
            ("Monday", "EEEE"),
            ("07:00", nil),
            ("-0700", "ZZZ"),
            ("0700", nil),
            ("2006", "yyyy"),
            (".999", ".SSS"),
            (",999", ",SSS"),
            (".000", ".SSS"),
            (",000", ",SSS"),
            ("Mon", "EEE"),
            ("Jan", "MMM"),
            ("MST", preferTimeZoneIdentifier ? "zzz" : "VV"),
            ("-07", "X"),
            ("T15", format24hStartsAtZero ? "'T'HH" : "'T'kk"),
            ("05", "ss"),
            ("02", "dd"),
            ("pm", "a"),
            ("06", "yy"),
            ("04", "mm"),
            ("07", nil),
            ("03", format12hStartsAtZero ? "KK" : "hh"),
            ("15", format24hStartsAtZero ? "HH" : "kk"),
            ("PM", "a"),
            ("01", "MM"),
            ("4", "m"),
            ("1", "M"),
            ("5", "s"),
            ("Z", "X"),
            ("2", "d"),
            ("3", format12hStartsAtZero ? "K" : "h"),
            ("'", "''")
        ]
    }
}
