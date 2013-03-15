//
//  IAATaskChanges.m
//  Tasks
//
//  Created by Tomas Vana on 3/15/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAATaskChanges.h"
#import "IAADataAccess.h"

@implementation IAATaskChanges

- (id)initWithTask:(IAATask *)task
{
    self = [super init];
    if (self) {
        self.name = task.name;
        self.notes = task.notes;
        self.reminderImportant = task.reminderImportant;
        self.reminderDate = task.reminderDate;
        self.categories = task.categories;
    }
    return self;
}

@end
