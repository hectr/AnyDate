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

import XCTest
@testable import AnyDate

extension DateParseTests {
    struct Fixture {
        static func dateFormatter(dateFormat: String, locale: Locale?, timeZone: TimeZone?) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.dateFormat = dateFormat
            formatter.timeZone = timeZone
            return formatter
        }
        
        init(in input: String, locale: Locale? =  nil, out: String, format: String = "yyyy-MM-dd HH:mm:ss ZZZ", timeZone: TimeZone? = TimeZone(abbreviation: "UTC")!, file: StaticString = #file, line: UInt = #line) {
            var parser = AnyDateParser()
            parser.locale = locale
            parser.timeZone = timeZone
            XCTAssertEqual("\(try? parser.parse(string: input).date())",
                "\(Fixture.dateFormatter(dateFormat: format, locale: nil, timeZone: timeZone).date(from: out))",
                file: file,
                line: line)
        }
        
        init(in input: String, out: String, format: String = "yyyy-MM-dd HH:mm:ss", loc: String, file: StaticString = #file, line: UInt = #line) {
            var parser = AnyDateParser()
            let timeZone = TimeZone(identifier: loc)
            parser.timeZone = timeZone
            XCTAssertEqual("\(try? parser.parse(string: input).date())",
                "\(Fixture.dateFormatter(dateFormat: format, locale: nil, timeZone: timeZone).date(from: out))",
                file: file,
                line: line)
        }
        
        init(in input: String, error: Bool, file: StaticString = #file, line: UInt = #line) {
            let parser = AnyDateParser()
            if error {
                XCTAssertThrowsError(try parser.parse(string: input).date(), file: file, line: line)
            } else {
                XCTAssertNoThrow(try parser.parse(string: input).date(), file: file, line: line)
            }
        }
        
        init(in input: String, reference: String, file: StaticString = #file, line: UInt = #line) {
            let parser = AnyDateParser()
            let result = try? parser.parse(string: input)
            XCTAssertEqual(result?.referenceLayout, reference, file: file, line: line)
        }
        
        init(ambiguous input: String, file: StaticString = #file, line: UInt = #line) {
            let parser = AnyDateParser()
            if let result = try? parser.parse(string: input) {
                XCTAssertTrue(result.isAmbiguous, file: file, line: line)
            } else {
                XCTFail(file: file, line: line)
            }
            
        }
    }
}
