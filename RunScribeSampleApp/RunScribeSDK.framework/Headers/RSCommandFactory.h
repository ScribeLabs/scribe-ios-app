//
//  RSCommandFactory.h
//  Runscribe
//
//  Created by Mark Handel on 5/7/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSCmd.h"

@interface RSCommandFactory : NSObject

+ (RSCommandFactory *)sharedInstance;

- (RSCmd *)getCmdForType:(RSCmdType)type forDevice:(RSDevice*)device;

@end
