//
//  NSDate+Extras.h
//  Runscribe
//
//  Created by Adam Hamel on 4/9/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extras)

/*
 RunScribe epoch is midnight, December 31, 1989, UTC.
 */
+ (NSDate *)runscribeEpoch;

/*
 Finds the time between RunScribe epoch and the specified date in seconds
 */
+ (NSTimeInterval)timeSinceRunscribeEpoch:(NSDate *)date;

/*
 Constructs a date object based upon a RunScribe time, which is the number of 
 seconds since midnight, December 31, 1989 UTC
 */
+ (NSDate *)dateFromRunScribeTime:(NSTimeInterval)runscribeTime;

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
