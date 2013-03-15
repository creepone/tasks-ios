//
//  IAALog.h
//  Tasks
//
//  Created by Tomas Vana on 3/14/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import "DDLog.h"

#if DEBUG
    static int ddLogLevel __attribute__((unused)) = LOG_LEVEL_VERBOSE;
#else
    static int ddLogLevel __attribute__((unused)) = LOG_LEVEL_ERROR;
#endif
