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

final class DateParseTests: XCTestCase {    
    func testUTC() {
        var parser = AnyDateParser()
        parser.timeZone = TimeZone(abbreviation: "UTC")
        XCTAssertEqual(try parser.parse(string: "2018.09.30").date(),
                       try parser.parse(string: "2018-09-30 00:00:00 +0000 UTC").date())
    }
    
    func testInvalid() {
        let parser = AnyDateParser()
        XCTAssertThrowsError(try parser.parse(string: "Invalid"))
    }
    
    func testValid() {
        let parser = AnyDateParser()
        XCTAssertEqual(try!  parser.parse(string: "\(Date(timeIntervalSince1970: 0))").date(),
                       Date(timeIntervalSince1970: 0))
    }
    
    func testMany() {
        _ = [
            Fixture(in: "oct 7, 1970", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "oct 7, '70", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "Oct 7, '70", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "Oct. 7, '70", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "oct. 7, '70", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "oct. 7, 1970", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "Sep. 7, '70", out: "1970-09-07 00:00:00 +0000"),
            Fixture(in: "sep. 7, 1970", out: "1970-09-07 00:00:00 +0000"),
            Fixture(in: "Feb 8, 2009 5:57:51 AM", out: "2009-02-08 05:57:51 +0000"),
            Fixture(in: "May 8, 2009 5:57:51 PM", out: "2009-05-08 17:57:51 +0000"),
            Fixture(in: "May 8, 2009 5:57:1 PM", out: "2009-05-08 17:57:01 +0000"),
            Fixture(in: "May 8, 2009 5:7:51 PM", out: "2009-05-08 17:07:51 +0000"),
            Fixture(in: "May 8, 2009, 5:7:51 PM", out: "2009-05-08 17:07:51 +0000"),
            Fixture(in: "7 oct 70", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "7 oct 1970", out: "1970-10-07 00:00:00 +0000"),
            Fixture(in: "7 May 1970", out: "1970-05-07 00:00:00 +0000"),
            Fixture(in: "7 Sep 1970", out: "1970-09-07 00:00:00 +0000"),
            Fixture(in: "7 June 1970", out: "1970-06-07 00:00:00 +0000"),
            Fixture(in: "7 September 1970", out: "1970-09-07 00:00:00 +0000"),
            //   ANSIC       = "Mon Jan _2 15:04:05 2006"
            Fixture(in: "Mon Jan  2 15:04:05 2006", out: "2006-01-02 15:04:05 +0000"),
            Fixture(in: "Thu May 8 17:57:51 2009", out: "2009-05-08 17:57:51 +0000"),
            Fixture(in: "Thu May  8 17:57:51 2009", out: "2009-05-08 17:57:51 +0000"),
            // RubyDate    = "Mon Jan 02 15:04:05 -0700 2006"
            Fixture(in: "Mon Jan 02 15:04:05 -0700 2006", out: "2006-01-02 22:04:05 +0000"),
            Fixture(in: "Thu May 08 11:57:51 -0700 2009", out: "2009-05-08 18:57:51 +0000"),
            //   UnixDate    = "Mon Jan _2 15:04:05 MST 2006"
            Fixture(in: "Mon Jan  2 15:04:05 MST 2006", out: "2006-01-02 15:04:05 -0700"),
            Fixture(in: "Thu May  8 17:57:51 MST 2009", out: "2009-05-08 17:57:51 -0700"),
            Fixture(in: "Thu May  8 17:57:51 PST 2009", out: "2009-05-08 17:57:51 -0700"),
            Fixture(in: "Thu May 08 17:57:51 PST 2009", out: "2009-05-08 17:57:51 -0700"),
            // FIXME: Fixture(in: "Thu May 08 17:57:51 CEST 2009", out: "2009-05-08 17:57:51 +0000"),
            Fixture(in: "Thu May 08 05:05:07 PST 2009", out: "2009-05-08 05:05:07 -0700"),
            Fixture(in: "Thu May 08 5:5:7 PST 2009", out: "2009-05-08 05:05:07 -0700"),
            // Day Month dd time
            // FIXME: Fixture(in: "Mon Aug 10 15:44:11 UTC+0000 2015", out: "2015-08-10 15:44:11 +0000"),
            Fixture(in: "Mon Aug 10 15:44:11 PST-0700 2015", out: "2015-08-10 22:44:11 +0000"),
            Fixture(in: "Mon Aug 10 15:44:11 CEST+0200 2015", out: "2015-08-10 13:44:11 +0000"),
            Fixture(in: "Mon Aug 1 15:44:11 CEST+0200 2015", out: "2015-08-01 13:44:11 +0000"),
            Fixture(in: "Mon Aug 1 5:44:11 CEST+0200 2015", out: "2015-08-01 03:44:11 +0000"),
            // ??
            // FIXME: Fixture(in: "Fri Jul 03 2015 18:04:07 GMT+0100 (GMT Daylight Time)", out: "2015-07-03 17:04:07 +0000"),
            // FIXME: Fixture(in: "Fri Jul 3 2015 06:04:07 GMT+0100 (GMT Daylight Time)", out: "2015-07-03 05:04:07 +0000"),
            Fixture(in: "Fri Jul 3 2015 06:04:07 PST-0700 (Pacific Daylight Time)", out: "2015-07-03 13:04:07 +0000"),
            // Month dd, yyyy at time
            Fixture(in: "September 17, 2012, 10:10:09", out: "2012-09-17 10:10:09 +0000"),
            // FIXME: Fixture(in: "September 17, 2012 at 5:00pm UTC-05", out: "2012-09-17 17:00:00 +0000"),
            // FIXME: Fixture(in: "September 17, 2012 at 10:09am PST-08", out: "2012-09-17 18:09:00 +0000"),
            // FIXME: Fixture(in: "May 17, 2012 AT 10:09am PST-08", out: "2012-05-17 18:09:00 +0000"),
            // FIXME: Fixture(in: "May 17, 2012 at 10:09am PST-08", out: "2012-05-17 18:09:00 +0000"),
            // Month dd, yyyy time
            // FIXME: Fixture(in: "September 17, 2012 5:00pm UTC-05", out: "2012-09-17 17:00:00 +0000"),
            Fixture(in: "September 17, 2012 10:09am PST-08", out: "2012-09-17 18:09:00 +0000"),
            Fixture(in: "September 17, 2012 09:01:00", out: "2012-09-17 09:01:00 +0000"),
            // Month dd yyyy time
            // FIXME: Fixture(in: "September 17 2012 5:00pm UTC-05", out: "2012-09-17 17:00:00 +0000"),
            // FIXME: Fixture(in: "September 17 2012 5:00pm UTC-0500", out: "2012-09-17 17:00:00 +0000"),
            // FIXME: Fixture(in: "September 17 2012 5:00PM UTC-05", out: "2012-09-17 17:00:00 +0000"),
            Fixture(in: "September 17 2012 10:09am PST-08", out: "2012-09-17 18:09:00 +0000"),
            Fixture(in: "September 17 2012 10:09AM PST-08", out: "2012-09-17 18:09:00 +0000"),
            Fixture(in: "September 17 2012 09:01:00", out: "2012-09-17 09:01:00 +0000"),
            Fixture(in: "May 17, 2012 10:10:09", out: "2012-05-17 10:10:09 +0000"),
            // Month dd, yyyy
            Fixture(in: "September 17, 2012", out: "2012-09-17 00:00:00 +0000"),
            Fixture(in: "May 7, 2012", out: "2012-05-07 00:00:00 +0000"),
            Fixture(in: "June 7, 2012", out: "2012-06-07 00:00:00 +0000"),
            Fixture(in: "June 7 2012", out: "2012-06-07 00:00:00 +0000"),
            // Month dd[th,nd,st,rd] yyyy
            Fixture(in: "September 17th, 2012", out: "2012-09-17 00:00:00 +0000"),
            Fixture(in: "September 17th 2012", out: "2012-09-17 00:00:00 +0000"),
            Fixture(in: "September 7th, 2012", out: "2012-09-07 00:00:00 +0000"),
            Fixture(in: "September 7th 2012", out: "2012-09-07 00:00:00 +0000"),
            Fixture(in: "September 7tH 2012", out: "2012-09-07 00:00:00 +0000"),
            Fixture(in: "May 1st 2012", out: "2012-05-01 00:00:00 +0000"),
            Fixture(in: "May 1st, 2012", out: "2012-05-01 00:00:00 +0000"),
            Fixture(in: "May 21st 2012", out: "2012-05-21 00:00:00 +0000"),
            Fixture(in: "May 21st, 2012", out: "2012-05-21 00:00:00 +0000"),
            Fixture(in: "May 23rd 2012", out: "2012-05-23 00:00:00 +0000"),
            Fixture(in: "May 23rd, 2012", out: "2012-05-23 00:00:00 +0000"),
            Fixture(in: "June 2nd, 2012", out: "2012-06-02 00:00:00 +0000"),
            Fixture(in: "June 2nd 2012", out: "2012-06-02 00:00:00 +0000"),
            Fixture(in: "June 22nd, 2012", out: "2012-06-22 00:00:00 +0000"),
            Fixture(in: "June 22nd 2012", out: "2012-06-22 00:00:00 +0000"),
            // ?
            Fixture(in: "Fri, 03 Jul 2015 08:08:08 MST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 03 Jul 2015 08:08:08 PST", out: "2015-07-03 08:08:08", loc: "America/Los_Angeles"),
            Fixture(in: "Fri, 03 Jul 2015 08:08:08 PST", out: "2015-07-03 07:08:08 -0800"),
            Fixture(in: "Fri, 3 Jul 2015 08:08:08 MST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 03 Jul 2015 8:08:08 MST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 03 Jul 2015 8:8:8 MST", out: "2015-07-03 08:08:08 -0700"),
            // ?
            Fixture(in: "Thu, 03 Jul 2017 08:08:04 +0100", out: "2017-07-03 07:08:04 +0000"),
            Fixture(in: "Thu, 03 Jul 2017 08:08:04 -0100", out: "2017-07-03 09:08:04 +0000"),
            Fixture(in: "Thu, 3 Jul 2017 08:08:04 +0100", out: "2017-07-03 07:08:04 +0000"),
            Fixture(in: "Thu, 03 Jul 2017 8:08:04 +0100", out: "2017-07-03 07:08:04 +0000"),
            Fixture(in: "Thu, 03 Jul 2017 8:8:4 +0100", out: "2017-07-03 07:08:04 +0000"),
            //
            Fixture(in: "Tue, 11 Jul 2017 04:08:03 +0200 (CEST)", out: "2017-07-11 02:08:03 +0000"),
            Fixture(in: "Tue, 5 Jul 2017 04:08:03 -0700 (CEST)", out: "2017-07-05 02:08:03 +0000"),
            Fixture(in: "Tue, 11 Jul 2017 04:08:03 +0200 (CEST)", out: "2017-07-11 04:08:03", loc: "Europe/Berlin"),
            // day, dd-Mon-yy hh:mm:zz TZ
            Fixture(in: "Fri, 03-Jul-15 08:08:08 MST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 03-Jul-15 08:08:08 PST", out: "2015-07-03 08:08:08", loc: "America/Los_Angeles"),
            Fixture(in: "Fri, 03-Jul 2015 08:08:08 PST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 3-Jul-15 08:08:08 MST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 03-Jul-15 8:08:08 MST", out: "2015-07-03 08:08:08 -0700"),
            Fixture(in: "Fri, 03-Jul-15 8:8:8 MST", out: "2015-07-03 08:08:08 -0700"),
            // RFC850    = "Monday, 02-Jan-06 15:04:05 MST"
            Fixture(in: "Wednesday, 07-May-09 08:00:43 MST", out: "2009-05-07 08:00:43 -0700"),
            Fixture(in: "Wednesday, 28-Feb-18 09:01:00 MST", out: "2018-02-28 09:01:00 -0700"),
            Fixture(in: "Wednesday, 28-Feb-18 09:01:00 MST", out: "2018-02-28 09:01:00", loc: "America/Denver"),
            // with offset then with variations on non-zero filled stuff
            Fixture(in: "Monday, 02 Jan 2006 15:04:05 +0100", out: "2006-01-02 14:04:05 +0000"),
            Fixture(in: "Wednesday, 28 Feb 2018 09:01:00 -0300", out: "2018-02-28 12:01:00 +0000"),
            Fixture(in: "Wednesday, 2 Feb 2018 09:01:00 -0300", out: "2018-02-02 12:01:00 +0000"),
            Fixture(in: "Wednesday, 2 Feb 2018 9:01:00 -0300", out: "2018-02-02 12:01:00 +0000"),
            Fixture(in: "Wednesday, 2 Feb 2018 09:1:00 -0300", out: "2018-02-02 12:01:00 +0000"),
            //  dd mon yyyy  12 Feb 2006, 19:17:08
            Fixture(in: "07 Feb 2004, 09:07", out: "2004-02-07 09:07:00 +0000"),
            Fixture(in: "07 Feb 2004, 09:07:07", out: "2004-02-07 09:07:07 +0000"),
            Fixture(in: "7 Feb 2004, 09:07:07", out: "2004-02-07 09:07:07 +0000"),
            Fixture(in: "07 Feb 2004, 9:7:7", out: "2004-02-07 09:07:07 +0000"),
            // dd Mon yyyy hh:mm:ss
            Fixture(in: "07 Feb 2004 09:07:08", out: "2004-02-07 09:07:08 +0000"),
            Fixture(in: "07 Feb 2004 09:07", out: "2004-02-07 09:07:00 +0000"),
            Fixture(in: "7 Feb 2004 9:7:8", out: "2004-02-07 09:07:08 +0000"),
            Fixture(in: "07 Feb 2004 09:07:08.123", out: "2004-02-07 09:07:08.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            //  dd-mon-yyyy  12 Feb 2006, 19:17:08 GMT
            Fixture(in: "07 Feb 2004, 09:07:07 GMT", out: "2004-02-07 09:07:07 +0000"),
            //  dd-mon-yyyy  12 Feb 2006, 19:17:08 +0100
            Fixture(in: "07 Feb 2004, 09:07:07 +0100", out: "2004-02-07 08:07:07 +0000"),
            //  dd-mon-yyyy   12-Feb-2006 19:17:08
            Fixture(in: "07-Feb-2004 09:07:07 +0100", out: "2004-02-07 08:07:07 +0000"),
            //  dd-mon-yy   12-Feb-2006 19:17:08
            Fixture(in: "07-Feb-04 09:07:07 +0100", out: "2004-02-07 08:07:07 +0000"),
            // yyyy-mon-dd    2013-Feb-03
            Fixture(in: "2013-Feb-03", out: "2013-02-03 00:00:00 +0000"),
            // 03 February 2013
            Fixture(in: "03 February 2013", out: "2013-02-03 00:00:00 +0000"),
            Fixture(in: "3 February 2013", out: "2013-02-03 00:00:00 +0000"),
            // Chinese 2014年04月18日
            Fixture(in: "2014年04月08日", out: "2014-04-08 00:00:00 +0000"),
            Fixture(in: "2014年04月08日 19:17:22", out: "2014-04-08 19:17:22 +0000"),
            //  mm/dd/yyyy
            Fixture(in: "03/31/2014", out: "2014-03-31 00:00:00 +0000"),
            Fixture(in: "3/31/2014", out: "2014-03-31 00:00:00 +0000"),
            Fixture(in: "3/5/2014", out: "2014-03-05 00:00:00 +0000"),
            //  mm/dd/yy
            Fixture(in: "08/08/71", out: "1971-08-08 00:00:00 +0000"),
            Fixture(in: "8/8/71", out: "1971-08-08 00:00:00 +0000"),
            //  mm/dd/yy hh:mm:ss
            Fixture(in: "04/02/2014 04:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "4/2/2014 04:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "04/02/2014 4:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "04/02/2014 4:8:9", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "04/02/2014 04:08", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "04/02/2014 4:8", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "04/02/2014 04:08:09.123", out: "2014-04-02 04:08:09.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "04/02/2014 04:08:09.12312", out: "2014-04-02 04:08:09.12312 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSS ZZZ"),
            Fixture(in: "04/02/2014 04:08:09.123123", out: "2014-04-02 04:08:09.123123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            //  mm/dd/yy hh:mm:ss AM
            Fixture(in: "04/02/2014 04:08:09 AM", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "04/02/2014 04:08:09 PM", out: "2014-04-02 16:08:09 +0000"),
            Fixture(in: "04/02/2014 04:08 AM", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "04/02/2014 04:08 PM", out: "2014-04-02 16:08:00 +0000"),
            Fixture(in: "04/02/2014 4:8 AM", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "04/02/2014 4:8 PM", out: "2014-04-02 16:08:00 +0000"),
            Fixture(in: "04/02/2014 04:08:09.123 AM", out: "2014-04-02 04:08:09.123", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            // FIXME: Fixture(in: "04/02/2014 04:08:09.123 PM", out: "2014-04-02 16:08:09.123", format: "yyyy-MM-dd HH:mm:ss.SSS"),
            //   yyyy/mm/dd
            Fixture(in: "2014/04/02", out: "2014-04-02 00:00:00 +0000"),
            Fixture(in: "2014/03/31", out: "2014-03-31 00:00:00 +0000"),
            Fixture(in: "2014/4/2", out: "2014-04-02 00:00:00 +0000"),
            //   yyyy/mm/dd hh:mm:ss AM
            Fixture(in: "2014/04/02 04:08", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "2014/03/31 04:08", out: "2014-03-31 04:08:00 +0000"),
            Fixture(in: "2014/4/2 04:08", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "2014/04/02 4:8", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "2014/04/02 04:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014/03/31 04:08:09", out: "2014-03-31 04:08:09 +0000"),
            Fixture(in: "2014/4/2 04:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014/04/02 04:08:09.123", out: "2014-04-02 04:08:09.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2014/04/02 04:08:09.123123", out: "2014-04-02 04:08:09.123123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2014/04/02 04:08:09 AM", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014/03/31 04:08:09 AM", out: "2014-03-31 04:08:09 +0000"),
            Fixture(in: "2014/4/2 04:08:09 AM", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014/04/02 04:08:09.123 AM", out: "2014-04-02 04:08:09.123", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            // FIXME: Fixture(in: "2014/04/02 04:08:09.123 PM", out: "2014-04-02 16:08:09.123", format: "yyyy-MM-dd HH:mm:ss.SSS"),
            //   yyyy-mm-dd
            Fixture(in: "2014-04-02", out: "2014-04-02 00:00:00 +0000"),
            Fixture(in: "2014-03-31", out: "2014-03-31 00:00:00 +0000"),
            Fixture(in: "2014-4-2", out: "2014-04-02 00:00:00 +0000"),
            // yyyy-mm
            Fixture(in: "2014-04", out: "2014-04-01 00:00:00 +0000"),
            //   yyyy-mm-dd hh:mm:ss AM
            Fixture(in: "2014-04-02 04:08", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "2014-03-31 04:08", out: "2014-03-31 04:08:00 +0000"),
            Fixture(in: "2014-4-2 04:08", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "2014-04-02 4:8", out: "2014-04-02 04:08:00 +0000"),
            Fixture(in: "2014-04-02 04:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014-03-31 04:08:09", out: "2014-03-31 04:08:09 +0000"),
            Fixture(in: "2014-4-2 04:08:09", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014-04-02 04:08:09.123", out: "2014-04-02 04:08:09.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2014-04-02 04:08:09.123123", out: "2014-04-02 04:08:09.123123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2014-04-02 04:08:09.12312312", out: "2014-04-02 04:08:09.12312312 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSS ZZZ"),
            Fixture(in: "2014-04-02 04:08:09 AM", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014-03-31 04:08:09 AM", out: "2014-03-31 04:08:09 +0000"),
            Fixture(in: "2014-04-26 05:24:37 PM", out: "2014-04-26 17:24:37 +0000"),
            Fixture(in: "2014-4-2 04:08:09 AM", out: "2014-04-02 04:08:09 +0000"),
            Fixture(in: "2014-04-02 04:08:09.123 AM", out: "2014-04-02 04:08:09.123", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2014-04-02 04:08:09.123 PM", out: "2014-04-02 12:08:09.123", format: "yyyy-MM-dd HH:mm:ss.SSS"),
            //   yyyy-mm-dd hh:mm:ss,000
            Fixture(in: "2014-05-11 08:20:13,787", out: "2014-05-11 08:20:13.787 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            //   yyyy-mm-dd hh:mm:ss +0000
            Fixture(in: "2012-08-03 18:31:59 +0000", out: "2012-08-03 18:31:59 +0000"),
            Fixture(in: "2012-08-03 13:31:59 -0600", out: "2012-08-03 19:31:59 +0000"),
            Fixture(in: "2012-08-03 18:31:59.257000000 +0000", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-08-03 8:1:59.257000000 +0000", out: "2012-08-03 08:01:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-8-03 18:31:59.257000000 +0000", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-8-3 18:31:59.257000000 +0000", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.123456 +0000", out: "2014-04-26 17:24:37.123456 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.12 +0000", out: "2014-04-26 17:24:37.12 +0000"),
            Fixture(in: "2014-04-26 17:24:37.1 +0000", out: "2014-04-26 17:24:37.1 +0000"),
            Fixture(in: "2014-05-11 08:20:13 +0000", out: "2014-05-11 08:20:13 +0000"),
            Fixture(in: "2014-05-11 08:20:13 +0530", out: "2014-05-11 02:50:13 +0000"),
            //   yyyy-mm-dd hh:mm:ss +0300 +03  ?? issue author said this is from golang?
            Fixture(in: "2018-06-29 19:09:57.77297118 +0300 +03", out: "2018-06-29 16:09:57.77297118 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSS ZZZ"),
            Fixture(in: "2018-06-29 19:09:57.77297118 +0300 +0300", out: "2018-06-29 16:09:57.77297118 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSS ZZZ"),
            Fixture(in: "2018-06-29 19:09:57 +0300 +03", out: "2018-06-29 16:09:57 +0000"),
            Fixture(in: "2018-06-29 19:09:57 +0300 +0300", out: "2018-06-29 16:09:57 +0000"),
            
            // 13:31:51.999 -07:00 MST
            //   yyyy-mm-dd hh:mm:ss +00:00
            Fixture(in: "2012-08-03 18:31:59 +00:00", out: "2012-08-03 18:31:59 +0000"),
            Fixture(in: "2014-05-01 08:02:13 +00:00", out: "2014-05-01 08:02:13 +0000"),
            Fixture(in: "2014-5-01 08:02:13 +00:00", out: "2014-05-01 08:02:13 +0000"),
            Fixture(in: "2014-05-1 08:02:13 +00:00", out: "2014-05-01 08:02:13 +0000"),
            Fixture(in: "2012-08-03 13:31:59 -06:00", out: "2012-08-03 19:31:59 +0000"),
            Fixture(in: "2012-08-03 18:31:59.257000000 +00:00", out: "2012-08-03 18:31:59.257 +0000"),
            Fixture(in: "2012-08-03 8:1:59.257000000 +00:00", out: "2012-08-03 08:01:59.257 +0000"),
            Fixture(in: "2012-8-03 18:31:59.257000000 +00:00", out: "2012-08-03 18:31:59.257 +0000"),
            Fixture(in: "2012-8-3 18:31:59.257000000 +00:00", out: "2012-08-03 18:31:59.257 +0000"),
            Fixture(in: "2014-04-26 17:24:37.123456 +00:00", out: "2014-04-26 17:24:37.123456 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.12 +00:00", out: "2014-04-26 17:24:37.12 +0000"),
            Fixture(in: "2014-04-26 17:24:37.1 +00:00", out: "2014-04-26 17:24:37.1 +0000"),
            //   yyyy-mm-dd hh:mm:ss +0000 TZ
            // Golang Native Format
            Fixture(in: "2012-08-03 18:31:59 +0000 UTC", out: "2012-08-03 18:31:59 +0000"),
            Fixture(in: "2012-08-03 13:31:59 -0600 MST", out: "2012-08-03 14:31:59", loc: "America/Denver"),
            Fixture(in: "2015-02-18 00:12:00 +0000 UTC", out: "2015-02-18 00:12:00 +0000"),
            Fixture(in: "2015-02-18 00:12:00 +0000 GMT", out: "2015-02-18 00:12:00 +0000"),
            Fixture(in: "2015-02-08 03:02:00 +0200 CEST", out: "2015-02-08 02:02:00", loc: "Europe/Berlin"),
            Fixture(in: "2012-08-03 18:31:59.257000000 +0000 UTC", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-08-03 8:1:59.257000000 +0000 UTC", out: "2012-08-03 08:01:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-8-03 18:31:59.257000000 +0000 UTC", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-8-3 18:31:59.257000000 +0000 UTC", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.123456 +0000 UTC", out: "2014-04-26 17:24:37.123456 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.12 +0000 UTC", out: "2014-04-26 17:24:37.12 +0000"),
            Fixture(in: "2014-04-26 17:24:37.1 +0000 UTC", out: "2014-04-26 17:24:37.1 +0000"),
            Fixture(in: "2015-02-08 03:02:00 +0200 CEST m=+0.000000001", out: "2015-02-08 02:02:00", loc: "Europe/Berlin"),
            //   yyyy-mm-dd hh:mm:ss TZ
            Fixture(in: "2012-08-03 18:31:59 UTC", out: "2012-08-03 18:31:59 +0000"),
            Fixture(in: "2014-12-16 06:20:00 GMT", out: "2014-12-16 06:20:00 +0000"),
            Fixture(in: "2012-08-03 13:31:59 MST", out: "2012-08-03 14:31:59", loc: "America/Denver"),
            Fixture(in: "2012-08-03 18:31:59.257000000 UTC", out: "2012-08-03 18:31:59.257 +0000"),
            Fixture(in: "2012-08-03 8:1:59.257000000 UTC", out: "2012-08-03 08:01:59.257 +0000"),
            Fixture(in: "2012-8-03 18:31:59.257000000 UTC", out: "2012-08-03 18:31:59.257 +0000"),
            Fixture(in: "2012-8-3 18:31:59.257000000 UTC", out: "2012-08-03 18:31:59.257 +0000"),
            Fixture(in: "2014-04-26 17:24:37.123456 UTC", out: "2014-04-26 17:24:37.123456 +0000"),
            Fixture(in: "2014-04-26 17:24:37.12 UTC", out: "2014-04-26 17:24:37.12 +0000"),
            Fixture(in: "2014-04-26 17:24:37.1 UTC", out: "2014-04-26 17:24:37.1 +0000"),
            // This one is pretty special, it is TIMEZONE based but starts with P to emulate collions with PM
            Fixture(in: "2014-04-26 05:24:37 PST", out: "2014-04-26 05:24:37 -0700"),
            Fixture(in: "2014-04-26 05:24:37 PST", out: "2014-04-26 05:24:37", loc: "America/Los_Angeles"),
            //   yyyy-mm-dd hh:mm:ss+00:00
            Fixture(in: "2012-08-03 18:31:59+00:00", out: "2012-08-03 18:31:59 +0000"),
            Fixture(in: "2017-07-19 03:21:51+00:00", out: "2017-07-19 03:21:51 +0000"),
            //   yyyy-mm-dd hh:mm:ss.000+00:00 PST
            Fixture(in: "2012-08-03 18:31:59.000+00:00 PST", out: "2012-08-03 18:31:59 +0000 UTC", loc: "America/Los_Angeles"),
            //   yyyy-mm-dd hh:mm:ss +00:00 TZ
            // FIXME: Fixture(in: "2012-08-03 18:31:59 +00:00 UTC", out: "2012-08-03 18:31:59 +0000"),
            Fixture(in: "2012-08-03 13:31:51 -07:00 MST", out: "2012-08-03 14:31:51", loc: "America/Denver"),
            Fixture(in: "2012-08-03 18:31:59.257000000 +00:00 UTC", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-08-03 13:31:51.123 -08:00 PST", out: "2012-08-03 13:31:51.123", format: "yyyy-MM-dd HH:mm:ss.SSS", loc: "America/Los_Angeles"),
            Fixture(in: "2012-08-03 13:31:51.123 +02:00 CEST", out: "2012-08-03 13:31:51.123", format: "yyyy-MM-dd HH:mm:ss.SSS", loc: "Europe/Berlin"),
            Fixture(in: "2012-08-03 8:1:59.257000000 +00:00 UTC", out: "2012-08-03 08:01:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-8-03 18:31:59.257000000 +00:00 UTC", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2012-8-3 18:31:59.257000000 +00:00 UTC", out: "2012-08-03 18:31:59.257 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.123456 +00:00 UTC", out: "2014-04-26 17:24:37.123456 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2014-04-26 17:24:37.12 +00:00 UTC", out: "2014-04-26 17:24:37.12 +0000"),
            Fixture(in: "2014-04-26 17:24:37.1 +00:00 UTC", out: "2014-04-26 17:24:37.1 +0000"),
            //   yyyy-mm-ddThh:mm:ss
            Fixture(in: "2009-08-12T22:15:09", out: "2009-08-12 22:15:09 +0000"),
            Fixture(in: "2009-08-08T02:08:08", out: "2009-08-08 02:08:08 +0000"),
            Fixture(in: "2009-08-08T2:8:8", out: "2009-08-08 02:08:08"),
            Fixture(in: "2009-08-12T22:15:09.123", out: "2009-08-12 22:15:09.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2009-08-12T22:15:09.123456", out: "2009-08-12 22:15:09.123456 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "2009-08-12T22:15:09.12", out: "2009-08-12 22:15:09.12 +0000"),
            Fixture(in: "2009-08-12T22:15:09.1", out: "2009-08-12 22:15:09.1 +0000"),
            Fixture(in: "2014-04-26 17:24:37.3186369", out: "2014-04-26 17:24:37.3186369 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSS ZZZ"),
            //   yyyy-mm-ddThh:mm:ss-07:00
            Fixture(in: "2009-08-12T22:15:09-07:00", out: "2009-08-13 05:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:09-03:00", out: "2009-08-13 01:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:9-07:00", out: "2009-08-13 05:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:09.123-07:00", out: "2009-08-13 05:15:09.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2016-06-21T19:55:00+01:00", out: "2016-06-21 18:55:00 +0000"),
            Fixture(in: "2016-06-21T19:55:00.799+01:00", out: "2016-06-21 18:55:00.799 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            //   yyyy-mm-ddThh:mm:ss-0700
            Fixture(in: "2009-08-12T22:15:09-0700", out: "2009-08-13 05:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:09-0300", out: "2009-08-13 01:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:9-0700", out: "2009-08-13 05:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:09.123-0700", out: "2009-08-13 05:15:09.123 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2016-06-21T19:55:00+0100", out: "2016-06-21 18:55:00 +0000"),
            Fixture(in: "2016-06-21T19:55:00.799+0100", out: "2016-06-21 18:55:00.799 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2016-06-21T19:55:00+0100", out: "2016-06-21 18:55:00 +0000"),
            Fixture(in: "2016-06-21T19:55:00-0700", out: "2016-06-22 02:55:00 +0000"),
            Fixture(in: "2016-06-21T19:55:00.799+0100", out: "2016-06-21 18:55:00.799 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "2016-06-21T19:55+0100", out: "2016-06-21 18:55:00 +0000"),
            Fixture(in: "2016-06-21T19:55+0130", out: "2016-06-21 18:25:00 +0000"),
            //   yyyy-mm-ddThh:mm:ssZ
            Fixture(in: "2009-08-12T22:15Z", out: "2009-08-12 22:15:00 +0000"),
            Fixture(in: "2009-08-12T22:15:09Z", out: "2009-08-12 22:15:09 +0000"),
            Fixture(in: "2009-08-12T22:15:09.99Z", out: "2009-08-12 22:15:09.99 +0000"),
            Fixture(in: "2009-08-12T22:15:09.9999Z", out: "2009-08-12 22:15:09.9999 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSS ZZZ"),
            Fixture(in: "2009-08-12T22:15:09.99999999Z", out: "2009-08-12 22:15:09.99999999 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSSS ZZZ"),
            Fixture(in: "2009-08-12T22:15:9.99999999Z", out: "2009-08-12 22:15:09.99999999 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSSS ZZZ"),
            // yyyy.mm
            Fixture(in: "2014.05", out: "2014-05-01 00:00:00 +0000"),
            Fixture(in: "2018.09.30", out: "2018-09-30 00:00:00 +0000"),
            
            //   mm.dd.yyyy
            Fixture(in: "3.31.2014", out: "2014-03-31 00:00:00 +0000"),
            Fixture(in: "3.3.2014", out: "2014-03-03 00:00:00 +0000"),
            Fixture(in: "03.31.2014", out: "2014-03-31 00:00:00 +0000"),
            //   mm.dd.yy
            Fixture(in: "08.21.71", out: "1971-08-21 00:00:00 +0000"),
            //  yyyymmdd and similar
            Fixture(in: "2014", out: "2014-01-01 00:00:00 +0000"),
            Fixture(in: "20140601", out: "2014-06-01 00:00:00 +0000"),
            Fixture(in: "20140722105203", out: "2014-07-22 10:52:03 +0000"),
            
            // all digits:  unix secs, ms etc
            Fixture(in: "1332151919", out: "2012-03-19 10:11:59 +0000"),
            Fixture(in: "1332151919", out: "2012-03-19 10:11:59", loc: "America/Denver"),
            Fixture(in: "1384216367111", out: "2013-11-12 00:32:47.111 +0000", format: "yyyy-MM-dd HH:mm:ss.SSS ZZZ"),
            Fixture(in: "1384216367111222", out: "2013-11-12 00:32:47.111222 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSS ZZZ"),
            Fixture(in: "1384216367111222333", out: "2013-11-12 00:32:47.111222333 +0000", format: "yyyy-MM-dd HH:mm:ss.SSSSSSSSS ZZZ"),
        ]
    }
    
    func testSomeErrors() {
        let parser = AnyDateParser()
        XCTAssertThrowsError(try parser.parse(string: "now"))
        XCTAssertThrowsError(try parser.parse(string: "138421636711122233311111")) // too many digits
        XCTAssertThrowsError(try parser.parse(string: "-1314"))
        XCTAssertEqual(try parser.parse(string: "2014-13-13 08:20:13,787").date(),
                       try parser.parse(string: "2015-01-13 07:20:13.787 +0000").date()) // month 13 overflows!
    }
    
    func testContext() {
        var p = Context(dateStr: "08.21.71",
                        timeZone: TimeZone(identifier: "America/Denver"),
                        preferMonthFirst: true,
                        skipped: 0,
                        trimmed: 0)
        p.setMonth()
        XCTAssertEqual(0, p.moi)
        p.setDay()
        XCTAssertEqual(0, p.dayi)
        p.set(start: -1, value: "not")
        p.set(start: 15, value: "not")
        XCTAssertEqual("08.21.71", p.datestr)
        XCTAssertEqual("08.21.71", String(p.format))
    }
    
    func testParseErrors() {
        _ = [
            Fixture(in: "3", error: true),
            Fixture(in: "hello", error: true),
            Fixture(in: "2009-15-12T22:15Z", error: false),
            Fixture(in: "5,000-9,999", error: true),
            Fixture(in: "xyzq-baad", error: true),
            Fixture(in: "oct.-7-1970", error: true),
            Fixture(in: "septe. 7, 1970", error: true),
            Fixture(in: "SeptemberRR 7th, 1970", error: true),
            Fixture(in: "29-06-2016", error: true),
            // this is just testing the empty space up front
            Fixture(in: " 2018-01-02 17:08:09 -07:00", error: true),
            Fixture(in: "2018-01-02 17:08:09 -07:00", error: false),
        ]
    }
    
    func testParseReferenceLayout() {
        _ = [
        Fixture(in: "oct 7, 1970", reference: "Jan 2, 2006"),
        Fixture(in: "sep. 7, 1970", reference: "Jan. 2, 2006"),
        Fixture(in: "May 05, 2015, 05:05:07", reference: "Jan 02, 2006, 15:04:05"),
        // 03 February 2013
        Fixture(in: "03 February 2013", reference: "02 January 2006"),
        // 13:31:51.999 -07:00 MST
        //   yyyy-mm-dd hh:mm:ss +00:00
        Fixture(in: "2012-08-03 18:31:59 +00:00", reference: "2006-01-02 15:04:05 -07:00"),
        //   yyyy-mm-dd hh:mm:ss +0000 TZ
        // Golang Native Format
        Fixture(in: "2012-08-03 18:31:59 +0000 UTC", reference: "2006-01-02 15:04:05 -0700 MST"),
        //   yyyy-mm-dd hh:mm:ss TZ
        Fixture(in: "2012-08-03 18:31:59 UTC", reference: "2006-01-02 15:04:05 MST"),
        //   yyyy-mm-ddThh:mm:ss-07:00
        Fixture(in: "2009-08-12T22:15:09-07:00", reference: "2006-01-02T15:04:05-07:00"),
        //   yyyy-mm-ddThh:mm:ss-0700
        Fixture(in: "2009-08-12T22:15:09-0700", reference: "2006-01-02T15:04:05-0700"),
        //   yyyy-mm-ddThh:mm:ssZ
        Fixture(in: "2009-08-12T22:15Z", reference: "2006-01-02T15:04Z"),
        ]
    }
    
    func testParseAmbiguous() {
        _ = [
            //   dd-mon-yy  13-Feb-03
            // FIXME: Fixture(ambiguous: "03-03-14"),
            //   mm.dd.yyyy
            Fixture(ambiguous: "3.3.2014"),
            //   mm.dd.yy
            Fixture(ambiguous: "08.09.71"),
            //  mm/dd/yyyy
            Fixture(ambiguous: "3/5/2014"),
            //  mm/dd/yy
            Fixture(ambiguous: "08/08/71"),
            Fixture(ambiguous: "8/8/71"),
            //  mm/dd/yy hh:mm:ss
            Fixture(ambiguous: "04/02/2014 04:08:09"),
            Fixture(ambiguous: "4/2/2014 04:08:09"),
        ]
        XCTAssertFalse(try! AnyDateParser().parse(string: "2009-08-12T22:15Z").isAmbiguous)
    }
    
    static var allTests = [
        ("testUTC", testUTC),
        ("testInvalid", testInvalid),
        ("testValid", testValid),
        ("testMany", testMany),
        ("testSomeErrors", testSomeErrors),
        ("testContext", testContext),
        ("testParseErrors", testParseErrors),
        ("testParseReferenceLayout", testParseReferenceLayout),
        ("testParseAmbiguous", testParseAmbiguous),
    ]
}
