//
//  IAATaskChanges.h
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAATask;

@interface IAATaskChanges : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate * reminderDate;
@property (nonatomic) BOOL reminderImportant;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSSet *categories;

- (id)initWithTask:(IAATask *)task;

@end


