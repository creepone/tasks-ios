//
//  IAAErrorManager.h
//  Tasks
//
//  Created by Tomas Vana on 3/2/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAAErrorManager : NSObject

/**
 Check whether the given error object is non-nil. If so, writes the error into log and 
 displays a view for the user with the details of the error.
 */
+ (BOOL)checkError:(NSError *)error;

@end
