//
//  IAADateCalculator.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAADateCalculator.h"

@interface IAADateCalculator() {
    NSCalendar *_calendar;
}

@end

@implementation IAADateCalculator

- (id)init
{
    return [self initWithCalendar:[NSCalendar currentCalendar]];
}

- (id)initWithCalendar:(NSCalendar *)calendar
{
    self = [super init];
    if (self) {
        _calendar = calendar;
    }
    return self;
}

+ (IAADateCalculator *)sharedCalculator
{
    static dispatch_once_t once;
    static IAADateCalculator *sharedCalculator;
    dispatch_once(&once, ^ { sharedCalculator = [[self alloc] init]; });
    return sharedCalculator;
}

- (NSCalendar *)calendar
{
    return _calendar;
}

- (NSDate *)today
{
    return [self datePart:[NSDate date]];
}

- (NSDate *)datePart:(NSDate *)date
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *components = [_calendar components:unitFlags fromDate:date];
	components.hour = 0;
	components.minute = 0;
    components.second = 0;
	
	return [_calendar dateFromComponents:components];
}

- (NSDate *)timePart:(NSDate *)date
{
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |  NSSecondCalendarUnit;
	NSDateComponents *components = [_calendar components:unitFlags fromDate:date];
	components.year = 0;
	components.month = 0;
    components.day = 0;
	
	return [_calendar dateFromComponents:components];
}

- (NSDate *)dateWithDate:(NSDate *)date timePart:(NSDate *)time
{
    NSUInteger timeFlags = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *timeComponents = [_calendar components:timeFlags fromDate:time];
    
    NSUInteger dateFlags = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *dateComponents = [_calendar components:dateFlags fromDate:date];
    
    dateComponents.hour = timeComponents.hour;
    dateComponents.minute = timeComponents.minute;
    dateComponents.second = timeComponents.second;
    
    return [_calendar dateFromComponents:dateComponents];
}

- (NSDate *)dateWithDate:(NSDate *)date daysLater:(int)days
{
	NSDateComponents *components = [[NSDateComponents alloc] init];
	components.day = days;
	return [_calendar dateByAddingComponents:components toDate:date options:0];
}

- (NSDate *)gmtDateWithLocalDate:(NSDate *)date
{
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *components = [_calendar components:unitFlags fromDate:date];
    
    NSCalendar *gmtCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gmtCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [gmtCalendar dateFromComponents:components];
}

- (NSDate *)localDateWithGmtDate:(NSDate *)date
{
    NSCalendar *gmtCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gmtCalendar setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
	NSDateComponents *components = [gmtCalendar components:unitFlags fromDate:date];
    return [_calendar dateFromComponents:components];
}


@end
