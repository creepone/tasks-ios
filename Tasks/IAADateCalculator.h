//
//  IAADateCalculator.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAADateCalculator : NSObject

+ (IAADateCalculator *)sharedCalculator;
- (NSCalendar *)calendar;

- (NSDate *)today;
- (NSDate *)datePart:(NSDate *)date;
- (NSDate *)timePart:(NSDate *)date;
- (NSDate *)dateWithDate:(NSDate *)date timePart:(NSDate *)time;
- (NSDate *)dateWithDate:(NSDate *)date daysLater:(int)days;

- (NSDate *)gmtDateWithLocalDate:(NSDate *)date;
- (NSDate *)localDateWithGmtDate:(NSDate *)date;

@end
