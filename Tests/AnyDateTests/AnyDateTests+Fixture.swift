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

import XCTest
@testable import AnyDate

extension AnyDateTests {
    struct Fixture {
        let datestr: String
        let expected: String?
        let format: String!
        let date: Date?
        
        init(datestr: String,
             timezone: TimeZone? = TimeZone(abbreviation: "GMT"),
             locale: Locale = Locale(identifier: "en_GB"),
             expected: String,
             file: StaticString = #file, line: UInt = #line) throws {
            var parser = AnyDateParser()
            parser.timeZone = timezone
            parser.locale = locale
            
            let result = try! parser.parse(string: datestr)
            
            self.datestr = datestr
            self.expected = expected
            self.date = try? result.date()
            self.format = result.referenceLayout
            
            XCTAssertEqual(format, expected, file: file, line: line)
        }
        
        init(datestr: String,
             date expected: String,
             format: String = "yyyy-MM-dd HH:mm:ss Z",
             timezone: TimeZone? = TimeZone(abbreviation: "GMT"),
             locale: Locale = Locale(identifier: "en_GB"),
             file: StaticString = #file,
             line: UInt = #line) throws {
            var parser = AnyDateParser()
            parser.timeZone = timezone
            parser.locale = locale
            
            let result = try? parser.parse(string: datestr)
            self.datestr = datestr
            self.format = nil
            self.date = try? result?.date()
            self.expected = nil
            
            let formatter = DateFormatter()
            formatter.locale = locale
            formatter.dateFormat = format
            formatter.timeZone = timezone
            
            let expectedDate =
                formatter.date(from: expected)
            
            if let date = date, let expectedDate = expectedDate, Float(date.timeIntervalSince1970) == Float(expectedDate.timeIntervalSince1970) {
                // OK
            } else {
                XCTAssertEqual(date, expectedDate, file: file, line: line)
            }
        }
    }
}
