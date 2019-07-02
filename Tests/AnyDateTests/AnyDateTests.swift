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

final class AnyDateTests: XCTestCase {
    func testComplexLayouts() {
        _ = try! [
            Fixture(datestr: "Monday, 02-Jan-06 15:04:05 MST",
                    expected: "02-Jan-06 15:04:05 MST"), // Monday is superflous
            
            Fixture(datestr: "October 7th, 1970",
                    expected: "January 2, 2006"), // ordinals are not supported
            
            Fixture(datestr: "Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time),",
                    expected: "Mon Jan 02 2006 15:04:05 MST-0700"), // long timezone is trimmed
            
            Fixture(datestr: "2015-02-08 03:02:00 +0300 MSK m=+0.000000001",
                    expected: "2006-01-02 15:04:05 -0700 MST"), // m is trimmed
            
            Fixture(datestr: "2015-02-08 03:02:00.001 +0300 MSK m=+0.000000001",
                    expected: "2006-01-02 15:04:05.000 -0700 MST"), // m is trimmed
            
            Fixture(datestr: "Tue, 11 Jul 2017 16:28:13 +0200 (CEST),",
                    expected: "Mon, 02 Jan 2006 15:04:05 -0700 (MST),"), // trailing comma is preserved
        ]
    }
    
    func testLayouts() {
        _ = try! [
            Fixture(datestr: "oct 7, 1970", expected: "Jan 2, 2006"),
            Fixture(datestr: "oct 7, '70", expected: "Jan 2, '06"),
            Fixture(datestr: "oct. 7, 1970", expected: "Jan. 2, 2006"),
            Fixture(datestr: "oct. 7, 70", expected: "Jan. 2, 06"),
            Fixture(datestr: "Mon Jan  2 15:04:05 2006", expected: "Mon Jan  2 15:04:05 2006"),
            Fixture(datestr: "Mon Jan  2 15:04:05 MST 2006", expected: "Mon Jan  2 15:04:05 MST 2006"),
            Fixture(datestr: "Mon Jan 02 15:04:05 -0700 2006", expected: "Mon Jan 02 15:04:05 -0700 2006"),
            Fixture(datestr: "Mon, 02 Jan 2006 15:04:05 MST", expected: "Mon, 02 Jan 2006 15:04:05 MST"),
            Fixture(datestr: "Mon, 02 Jan 2006 15:04:05 -0700", expected: "Mon, 02 Jan 2006 15:04:05 -0700"),
            Fixture(datestr: "May 8, 2009 5:57:51 PM", expected: "Jan 2, 2006 3:04:05 PM"),
            Fixture(datestr: "Thu, 4 Jan 2018 17:53:36 +0000", expected: "Mon, 2 Jan 2006 15:04:05 -0700"),
            Fixture(datestr: "Mon Aug 10 15:44:11 UTC+0100 2015", expected: "Mon Jan 02 15:04:05 MST-0700 2006"),
            Fixture(datestr: "September 17, 2012 10:09am", expected: "January 02, 2006 03:04pm"),
            Fixture(datestr: "September 17, 2012 at 10:09am PST-08", expected: "January 02, 2006 at 03:04pm MST-07"),
            Fixture(datestr: "September 17, 2012, 10:10:09", expected: "January 02, 2006, 15:04:05"),
            Fixture(datestr: "October 7, 1970", expected: "January 2, 2006"),
            Fixture(datestr: "12 Feb 2006, 19:17", expected: "02 Jan 2006, 15:04"),
            Fixture(datestr: "12 Feb 2006 19:17", expected: "02 Jan 2006 15:04"),
            Fixture(datestr: "7 oct 70", expected: "2 Jan 06"),
            Fixture(datestr: "7 oct 1970", expected: "2 Jan 2006"),
            Fixture(datestr: "03 February 2013", expected: "02 January 2006"),
            Fixture(datestr: "1 July 2013", expected: "2 January 2006"),
            Fixture(datestr: "2013-Feb-03", expected: "2006-Jan-02"),
            Fixture(datestr: "3/31/2014", expected: "1/02/2006"),
            Fixture(datestr: "2014年04月08日", expected: "2006年01月02日"),
            Fixture(datestr: "2013-04-01 22:43", expected: "2006-01-02 15:04"),
            Fixture(datestr: "03/31/2014", expected: "01/02/2006"),
            Fixture(datestr: "08/21/71", expected: "01/02/06"),
            Fixture(datestr: "8/1/71", expected: "1/2/06"),
            Fixture(datestr: "4/8/2014 22:05", expected: "1/2/2006 15:04"),
            Fixture(datestr: "04/08/2014 22:05", expected: "01/02/2006 15:04"),
            Fixture(datestr: "4/8/14 22:05", expected: "1/2/06 15:04"),
            Fixture(datestr: "04/2/2014 03:00:51", expected: "01/2/2006 15:04:05"),
            Fixture(datestr: "8/8/1965 12:00:00 AM", expected: "1/2/2006 03:04:05 PM"),
            Fixture(datestr: "8/8/1965 01:00:01 PM", expected: "1/2/2006 03:04:05 PM"),
            Fixture(datestr: "8/8/1965 01:00 PM", expected: "1/2/2006 03:04 PM"),
            Fixture(datestr: "8/8/1965 1:00 PM", expected: "1/2/2006 3:04 PM"),
            Fixture(datestr: "8/8/1965 12:00 AM", expected: "1/2/2006 03:04 PM"),
            Fixture(datestr: "4/02/2014 03:00:51", expected: "1/02/2006 15:04:05"),
            Fixture(datestr: "03/19/2012 10:11:59", expected: "01/02/2006 15:04:05"),
            Fixture(datestr: "03/19/2012 10:11:59.3186369", expected: "01/02/2006 15:04:05.0000000"),
            Fixture(datestr: "2014/3/31", expected: "2006/1/02"),
            Fixture(datestr: "2014/03/31", expected: "2006/01/02"),
            Fixture(datestr: "2014/4/8 22:05", expected: "2006/1/2 15:04"),
            Fixture(datestr: "2014/04/08 22:05", expected: "2006/01/02 15:04"),
            Fixture(datestr: "2014/04/2 03:00:51", expected: "2006/01/2 15:04:05"),
            Fixture(datestr: "2014/4/02 03:00:51", expected: "2006/1/02 15:04:05"),
            Fixture(datestr: "2012/03/19 10:11:59", expected: "2006/01/02 15:04:05"),
            Fixture(datestr: "2012/03/19 10:11:59.3186369", expected: "2006/01/02 15:04:05.0000000"),
            Fixture(datestr: "2006-01-02T15:04:05+0000", expected: "2006-01-02T15:04:05-0700"),
            Fixture(datestr: "2009-08-12T22:15:09-07:00", expected: "2006-01-02T15:04:05-07:00"),
            Fixture(datestr: "2009-08-12T22:15:09", expected: "2006-01-02T15:04:05"),
            Fixture(datestr: "2009-08-12T22:15:09Z", expected: "2006-01-02T15:04:05Z"),
            Fixture(datestr: "2014-04-26 17:24:37.3186369", expected: "2006-01-02 15:04:05.0000000"),
            Fixture(datestr: "2012-08-03 18:31:59.257000000", expected: "2006-01-02 15:04:05.000000000"),
            Fixture(datestr: "2014-04-26 17:24:37.123", expected: "2006-01-02 15:04:05.000"),
            Fixture(datestr: "2013-04-01 22:43:22", expected: "2006-01-02 15:04:05"),
            Fixture(datestr: "2014-04-26 05:24:37 PM", expected: "2006-01-02 03:04:05 PM"),
            Fixture(datestr: "2014-04-26 13:13:43 +0800", expected: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "2014-04-26 13:13:43 +0800 +08", expected: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "2014-04-26 13:13:44 +09:00", expected: "2006-01-02 15:04:05 -07:00"),
            Fixture(datestr: "2015-02-18 00:12:00 +0000 GMT", expected: "2006-01-02 15:04:05 -0700 MST"),
            Fixture(datestr: "2015-02-18 00:12:00 +0000 UTC", expected: "2006-01-02 15:04:05 -0700 MST"),
            Fixture(datestr: "2017-07-19 03:21:51+00:00", expected: "2006-01-02 15:04:05-07:00"),
            Fixture(datestr: "2014-12-16 06:20:00 UTC", expected: "2006-01-02 15:04:05 MST"),
            Fixture(datestr: "2014-12-16 06:20:00 GMT", expected: "2006-01-02 15:04:05 MST"),
            Fixture(datestr: "2012-08-03 18:31:59.257000000 +0000 UTC", expected: "2006-01-02 15:04:05.000000000 -0700 MST"),
            Fixture(datestr: "2015-09-30 18:48:56.35272715 +0000 UTC", expected: "2006-01-02 15:04:05.00000000 -0700 MST"),
            Fixture(datestr: "2014-05-11 08:20:13,787", expected: "2006-01-02 15:04:05,000"),
        ]
    }

    func testDateOnlyLayouts() {
        _ = try! [
            Fixture(datestr: "2014-04-26", expected: "2006-01-02"),
            Fixture(datestr: "2014-04", expected: "2006-01"),
            Fixture(datestr: "2014", expected: "2006"),
            Fixture(datestr: "3.31.2014", expected: "1.02.2006"),
            Fixture(datestr: "03.31.2014", expected: "01.02.2006"),
            Fixture(datestr: "08.21.71", expected: "01.02.06"),
            Fixture(datestr: "2014.03", expected: "2006.01"),
            Fixture(datestr: "2014.03.30", expected: "2006.01.02"),
            Fixture(datestr: "20140601", expected: "20060102"),
            Fixture(datestr: "20140722105203", expected: "20060102150405"),
        ]
    }

    func testDates() {
        _ = try! [
            Fixture(datestr: "May 8, 2009 5:57:51 PM", date: "2009-05-08 17:57:51 +0000"),
            Fixture(datestr: "oct 7, 1970", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "oct 7, '70", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "oct. 7, 1970", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "oct. 7, 70", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "Mon Jan  2 15:04:05 2006", date: "2006-01-02 15:04:05 +0000"),
            Fixture(datestr: "Mon Jan 02 15:04:05 -0700 2006", date: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "Mon, 02 Jan 2006 15:04:05 -0700", date: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "Thu, 4 Jan 2018 17:53:36 +0000", date: "2018-01-04 17:53:36 +0000"),
            Fixture(datestr: "September 17, 2012 10:09am", date: "2012-09-17 10:09:00 +0000"),
            Fixture(datestr: "September 17, 2012, 10:10:09", date: "2012-09-17 10:10:09 +0000"),
            Fixture(datestr: "October 7, 1970", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "October 7th, 1970", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "12 Feb 2006, 19:17", date: "2006-02-12 19:17:00 +0000"),
            Fixture(datestr: "12 Feb 2006 19:17", date: "2006-02-12 19:17:00 +0000"),
            Fixture(datestr: "7 oct 70", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "7 oct 1970", date: "1970-10-07 00:00:00 +0000"),
            Fixture(datestr: "03 February 2013", date: "2013-02-03 00:00:00 +0000"),
            Fixture(datestr: "1 July 2013", date: "2013-07-01 00:00:00 +0000"),
            Fixture(datestr: "2013-Feb-03", date: "2013-02-03 00:00:00 +0000"),
            Fixture(datestr: "3/31/2014", date: "2014-03-31 00:00:00 +0000"),
            Fixture(datestr: "03/31/2014", date: "2014-03-31 00:00:00 +0000"),
            Fixture(datestr: "08/21/71", date: "1971-08-21 00:00:00 +0000"),
            Fixture(datestr: "8/1/71", date: "1971-08-01 00:00:00 +0000"),
            Fixture(datestr: "4/8/2014 22:05", date: "2014-04-08 22:05:00 +0000"),
            Fixture(datestr: "04/08/2014 22:05", date: "2014-04-08 22:05:00 +0000"),
            Fixture(datestr: "4/8/14 22:05", date: "2014-04-08 22:05:00 +0000"),
            Fixture(datestr: "04/2/2014 03:00:51", date: "2014-04-02 03:00:51 +0000"),
            Fixture(datestr: "8/8/1965 01:00:01 PM", date: "1965-08-08 13:00:01 +0000"),
            Fixture(datestr: "8/8/1965 01:00 PM", date: "1965-08-08 13:00:00 +0000"),
            Fixture(datestr: "8/8/1965 1:00 PM", date: "1965-08-08 13:00:00 +0000"),
            Fixture(datestr: "4/02/2014 03:00:51", date: "2014-04-02 03:00:51 +0000"),
            Fixture(datestr: "03/19/2012 10:11:59", date: "2012-03-19 10:11:59 +0000"),
            Fixture(datestr: "03/19/2012 10:11:59.3186369", date: "2012-03-19 10:11:59.3186369 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSS Z"),
            Fixture(datestr: "2014/3/31", date: "2014-03-31 00:00:00 +0000"),
            Fixture(datestr: "2014/03/31", date: "2014-03-31 00:00:00 +0000"),
            Fixture(datestr: "2014/4/8 22:05", date: "2014-04-08 22:05:00 +0000"),
            Fixture(datestr: "2014/04/08 22:05", date: "2014-04-08 22:05:00 +0000"),
            Fixture(datestr: "2014/04/2 03:00:51", date: "2014-04-02 03:00:51 +0000"),
            Fixture(datestr: "2014/4/02 03:00:51", date: "2014-04-02 03:00:51 +0000"),
            Fixture(datestr: "2012/03/19 10:11:59", date: "2012-03-19 10:11:59 +0000"),
            Fixture(datestr: "2012/03/19 10:11:59.3186369", date: "2012-03-19 10:11:59.3186369 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSS Z"),
            Fixture(datestr: "2014年04月08日", date: "2014-04-08 00:00:00 +0000"),
            Fixture(datestr: "2006-01-02T15:04:05+0000", date: "2006-01-02 15:04:05 +0000"),
            Fixture(datestr: "2009-08-12T22:15:09-07:00", date: "2009-08-12 22:15:09 -0700"),
            Fixture(datestr: "2009-08-12T22:15:09", date: "2009-08-12 22:15:09 +0000"),
            Fixture(datestr: "2009-08-12T22:15:09Z", date: "2009-08-12 22:15:09 +0000"),
            Fixture(datestr: "2014-04-26 17:24:37.3186369", date: "2014-04-26 17:24:37.3186369 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSS Z"),
            Fixture(datestr: "2012-08-03 18:31:59.257000000", date: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS Z"),
            Fixture(datestr: "2013-04-01 22:43", date: "2013-04-01 22:43:00 +0000"),
            Fixture(datestr: "2013-04-01 22:43:22", date: "2013-04-01 22:43:22 +0000"),
            Fixture(datestr: "2014-12-16 06:20:00 UTC", date: "2014-12-16 06:20:00 +0000"),
            Fixture(datestr: "2014-12-16 06:20:00 GMT", date: "2014-12-16 06:20:00 +0000"),
            Fixture(datestr: "2014-04-26 05:24:37 PM", date: "2014-04-26 17:24:37 +0000"),
            Fixture(datestr: "2014-04-26 13:13:43 +0800", date: "2014-04-26 13:13:43 +0800"),
            Fixture(datestr: "2014-04-26 13:13:43 +0800 +08", date: "2014-04-26 13:13:43 +0800"),
            Fixture(datestr: "2014-04-26 13:13:44 +09:00", date: "2014-04-26 13:13:44 +0900"),
            Fixture(datestr: "2015-02-18 00:12:00 +0000 GMT", date: "2015-02-18 00:12:00 +0000"),
            Fixture(datestr: "2015-02-18 00:12:00 +0000 UTC", date: "2015-02-18 00:12:00 +0000"),
            Fixture(datestr: "2017-07-19 03:21:51+00:00", date: "2017-07-19 03:21:51 +0000"),
            Fixture(datestr: "2014-04-26", date: "2014-04-26 00:00:00 +0000"),
            Fixture(datestr: "2014-04", date: "2014-04-01 00:00:00 +0000"),
            Fixture(datestr: "2014", date: "2014-01-01 00:00:00 +0000"),
            Fixture(datestr: "3.31.2014", date: "2014-03-31 00:00:00 +0000"),
            Fixture(datestr: "03.31.2014", date: "2014-03-31 00:00:00 +0000"),
            Fixture(datestr: "08.21.71", date: "1971-08-21 00:00:00 +0000"),
            Fixture(datestr: "2014.03", date: "2014-03-01 00:00:00 +0000"),
            Fixture(datestr: "2014.03.30", date: "2014-03-30 00:00:00 +0000"),
            Fixture(datestr: "20140601", date: "2014-06-01 00:00:00 +0000"),
            Fixture(datestr: "20140722105203", date: "2014-07-22 10:52:03 +0000"),
            Fixture(datestr: "1332151919", date: "2012-03-19 10:11:59 +0000"),
            Fixture(datestr: "1384216367189", date: "2013-11-12 00:32:47.189 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS Z"),
            Fixture(datestr: "Tue, 11 Jul 2017 16:28:13 +0200 (CEST),", date: "2017-07-11 16:28:13 +0200"),
            Fixture(datestr: "8/8/1965 12:00:00 AM", date: "1965-08-08 00:00:00 +0000"),
            Fixture(datestr: "8/8/1965 12:00 AM", date: "1965-08-08 00:00:00 +0000"),
            Fixture(datestr: "1384216367111222", date: "2013-11-12 00:32:47.111222 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS Z"),
            Fixture(datestr: "1384216367111222333", date: "2013-11-12 00:32:47.111222333 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSSS Z"),
            Fixture(datestr: "2014-05-11 08:20:13,787", date: "2014-05-11 08:20:13.787 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS Z"),
            Fixture(datestr: "2014-04-26 17:24:37.123", date: "2014-04-26 17:24:37.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS Z"),
            // FIXME: Fixture(datestr: "Mon Aug 10 15:44:11 UTC+0100 2015", date: "2015-08-10 15:44:11 +0100"),
            Fixture(datestr: "September 17, 2012 at 10:09am PST-08", date: "2012-09-17 10:09:00 -0800 PST"),
            // FIXME: Fixture(datestr: "Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time),", date: "2015-07-03 18:04:07 +0100"),
        ]
    }
    
    func testLenient() {
        _ = try! [
            Fixture(datestr: "Mon Jan  2 15:04:05 MST 2006", date: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "Monday, 02-Jan-06 15:04:05 MST", date: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "Mon, 02 Jan 2006 15:04:05 MST", date: "2006-01-02 15:04:05 -0700"),
            Fixture(datestr: "2012-08-03 18:31:59.257000000 +0000 UTC", date: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS Z"),
            Fixture(datestr: "2015-09-30 18:48:56.35272715 +0000 UTC", date: "2015-09-30 18:48:56.35272715 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSS Z"),
            Fixture(datestr: "2015-02-08 03:02:00 +0700 MST m=+0.000000001", date: "2015-02-08 03:02:00 -0700"),
            Fixture(datestr: "2015-02-08 03:02:00.001 +0700 MST m=+0.000000001", date: "2015-02-08 03:02:00.001 -0700", format: "yyyy-MM-dd HH:mm:ss.SSS Z"),
        ]
    }
    
    static var allTests = [
        ("testComplexLayouts", testComplexLayouts),
        ("testLayouts", testLayouts),
        ("testDateOnlyLayouts", testDateOnlyLayouts),
        ("testDates", testDates),
        ("testLenient", testLenient),
    ]
}
