//
//  IAALogging.m
//  Tasks
//
//  Created by Tomas Vana on 23/03/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import "IAALogging.h"
#import <DDTTYLogger.h>
#import <DDASLLogger.h>
#import <DDFileLogger.h>
#import <SSZipArchive.h>

@implementation IAALogging

+ (void)setupLogging
{
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setRollingFrequency:60 * 60 * 24]; // roll every day
    [fileLogger setMaximumFileSize:1024 * 1024]; // max 1MB file size
    [fileLogger.logFileManager setMaximumNumberOfLogFiles:3];
    
    [DDLog addLogger:fileLogger];
    DDLogVerbose(@"Logging is setup (\"%@\")", [fileLogger.logFileManager logsDirectory]);
}

+ (NSString *)archiveLogs
{
    [DDLog flushLog];
    
    DDFileLogger *fileLogger = [self fileLogger];
    if (fileLogger == nil)
        return nil;
    
    NSString *logsDirectory = [fileLogger.logFileManager logsDirectory];
    
    NSString *archivePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"log.zip"];
    [SSZipArchive createZipFileAtPath:archivePath withContentsOfDirectory:logsDirectory];
    return archivePath;
}

+ (DDFileLogger *)fileLogger
{
    NSArray *allLoggers = [DDLog allLoggers];
    NSUInteger indexOfFileLogger = [allLoggers indexOfObjectPassingTest:^(id logger, NSUInteger idx, BOOL* stop) {
        return [logger isKindOfClass:[DDFileLogger class]];
    }];
    
    return indexOfFileLogger == NSNotFound ? nil : [allLoggers objectAtIndex:indexOfFileLogger];
}

@end
