//
//  IAASyncBatch.h
//  Tasks
//
//  Created by Tomas Vana on 30/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAASyncBatch;

@protocol IAASyncBatchDelegate <NSObject>

- (void)syncBatch:(IAASyncBatch *)batch completedWithError:(NSError *)error;

@end

@interface IAASyncBatch : NSObject

@property (nonatomic, weak) id<IAASyncBatchDelegate> delegate;

- (void)start;

@end
