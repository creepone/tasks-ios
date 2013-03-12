//
//  IAADateFormatter.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAADateFormatter : NSObject

+ (IAADateFormatter *)sharedFormatter;

- (NSString *)shortDateStringFromDate:(NSDate *)date;
- (NSString *)shortTimeStringFromDate:(NSDate *)date;
- (NSString *)shortDateTimeStringFromDate:(NSDate *)date;

@end
