//
//  IAALogging.h
//  Tasks
//
//  Created by Tomas Vana on 23/03/14.
//  Copyright (c) 2014 iOS Apps Austria. All rights reserved.
//

#import <DDLog.h>

#if DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_ERROR;
#endif

@interface IAALogging : NSObject

/**
 Sets up the logging for the whole application. This should be called in the applicationDidFinishLaunching method.
 */
+ (void)setupLogging;

/**
 Archives all the log files into a single zip files.
 @return The full path to the generated zip archive.
 */
+ (NSString *)archiveLogs;

@end
