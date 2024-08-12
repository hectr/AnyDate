/*
 The MIT License (MIT)
 
 Original Copyright (c) 2015-2017 Aaron Raddon
 Swift port Copyright (c) 2019 Hèctor Marquès Ranea
 
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

public struct AnyDateParser {
    /// Reference date.
    public static let referenceDate: Date = Date(timeIntervalSince1970: 1136210645)
    
    public var timeZone: TimeZone? = nil
    public var locale: Locale? = nil
    public var preferMonthFirst = true
    public var dateFormatterHeuristics = true
    public var ignoreUnsupportedLayoutComponents = true
    public var preferTimeZoneIdentifier = true
    public var format24hStartsAtZero = true
    public var format12hStartsAtZero = false
    
    public init() {}
    
    public func parse(string: String) throws -> Result {
        let context = try parseAny(dateString: string,
                                   timeZone: timeZone,
                                   locale: locale,
                                   preferMonthFirst: preferMonthFirst)
        let layout = context.format.toString()
        return Result(context: context,
                      timeZone: timeZone,
                      locale: locale,
                      referenceLayout: layout,
                      dateFormatterHeuristics: dateFormatterHeuristics,
                      string: string,
                      dateFormat: try AnyDateParser.dateFormatPattern(fromReferenceDateLayout: layout,
                                                                      ignoreUnsupportedComponents: ignoreUnsupportedLayoutComponents,
                                                                      preferTimeZoneIdentifier: preferTimeZoneIdentifier,
                                                                      format24hStartsAtZero: format24hStartsAtZero,
                                                                      format12hStartsAtZero: format12hStartsAtZero))
    }
    
    public func date(from string: String) throws -> Date {
        let result = try parse(string: string)
        return try result.date()
    }
}
