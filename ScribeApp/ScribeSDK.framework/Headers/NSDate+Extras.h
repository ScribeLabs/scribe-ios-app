//
// MIT License
//
// Copyright (c) 2016 Scribe Labs Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extras)

/*
 Scribe epoch is midnight, December 31, 1989, UTC.
 */
+ (NSDate *)scribeEpoch;

/*
 Finds the time between Scribe epoch and the specified date in seconds
 */
+ (NSTimeInterval)timeSinceScribeEpoch:(NSDate *)date;

/*
 Constructs a date object based upon a Scribe time, which is the number of
 seconds since midnight, December 31, 1989 UTC
 */
+ (NSDate *)dateFromScribeTime:(NSTimeInterval)scribeTime;

+ (NSDate *)dateBySecondOffset:(NSInteger)offset;

+ (NSDate *)dateByDayOffset:(NSInteger)offset fromDate:(NSDate *)date;

/** 
 Formats Time as 00:00:00 (HOURS:MINUTES:SECONDS)
 if hideHoursIfZero == YES it will hide the hours portion if under 1 hour 00:00 (MINUTES:SECONDS)
 */
+ (NSString *)formatSeconds:(NSInteger)seconds hideHoursIfZero:(BOOL)hideHours;

/**
 Formats Time as 0h 0m (Hours, Minutes)
 if hideHoursIfZero == YES it will hide the hours portion if under 1 hour 0m (MINUTES)
 */
+ (NSString *)formatMinutesAsHrsMinutes:(NSUInteger)minutes hideHoursIfZero:(BOOL)hideHours;

/** 
 Returns a fuzzy date (relative time)
 */
+ (NSString*)relativeTime:(NSDate*)date;

+ (BOOL)isSameWeekAsDate:(NSDate *)aDate andDate:(NSDate *)bDate;

+ (BOOL)isLastWeek:(NSDate *)bDate;

+ (BOOL)isSameMonthAsDate:(NSDate *)aDate andDate:(NSDate *)bDate;

/**
 Returns NSDate objects that represent all the days in a calendar week
 based off of self as the reference date
 */
-(NSArray*)daysInThisWeek;

/**
 Returns NSDate objects that represent all the days in a calendar month
 based off of self as the reference date
 */
-(NSArray*)daysInThisMonth;

- (NSDate *)dateAtBeginningOfDay;

@end
