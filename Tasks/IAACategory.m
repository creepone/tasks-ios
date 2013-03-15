//
//  IAACategory.m
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "IAACategory.h"
#import "IAATask.h"


@implementation IAACategory

@dynamic name;
@dynamic order;
@dynamic tasks;

+ (void)renumberAll:(NSArray *)allCategories
{
    for (int i = 0; i < [allCategories count]; i++) {
        IAACategory *category = [allCategories objectAtIndex:i];
        category.order = i + 1;
    }
}

@end
