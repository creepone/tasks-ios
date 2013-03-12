//
//  IAADateFormatter.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAADateFormatter.h"

@interface IAADateFormatter() {
    NSDateFormatter *_formatter;
}

- (void)updateLocale;

@end

@implementation IAADateFormatter

- (id)init {
    self = [super init];
    if (self) {
        _formatter = [[NSDateFormatter alloc] init];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocale) name:NSCurrentLocaleDidChangeNotification object:nil];
    }
    return self;
}

+ (IAADateFormatter *)sharedFormatter {
    static dispatch_once_t once;
    static IAADateFormatter *sharedFormatter;
    dispatch_once(&once, ^ { sharedFormatter = [[self alloc] init]; });
    return sharedFormatter;
}


- (NSString *)shortDateStringFromDate:(NSDate *)date {
    [_formatter setDateStyle:NSDateFormatterShortStyle];
    [_formatter setTimeStyle:NSDateFormatterNoStyle];
    return [_formatter stringFromDate:date];
}

- (NSString *)shortTimeStringFromDate:(NSDate *)date {
    [_formatter setDateStyle:NSDateFormatterNoStyle];
    [_formatter setTimeStyle:NSDateFormatterShortStyle];
    return [_formatter stringFromDate:date];
}

- (NSString *)shortDateTimeStringFromDate:(NSDate *)date {
    [_formatter setDateStyle:NSDateFormatterShortStyle];
    [_formatter setTimeStyle:NSDateFormatterShortStyle];
    return [_formatter stringFromDate:date];
}


- (void)updateLocale {
    _formatter.locale = [NSLocale currentLocale];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
