//
//  IAAPatch.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface IAAPatch : NSManagedObject

@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * id;
@property (nonatomic) int16_t operation;
@property (nonatomic, retain) NSString * taskId;
@property (nonatomic) NSTimeInterval timestamp;

@end
