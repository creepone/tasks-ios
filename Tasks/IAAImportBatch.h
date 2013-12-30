//
//  IAAImportBatch.h
//  Tasks
//
//  Created by Tomas Vana on 30/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAADataAccess;

@interface IAAImportBatch : NSObject

- (id)initWithDataAccess:(IAADataAccess *)dataAccess andData:(NSDictionary *)data;

- (BOOL)importAll:(NSError **)error;

@end
