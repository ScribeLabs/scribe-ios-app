//
//  RSMultipartResponseCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/24/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

typedef void (^RSCmdProgessCallback)(NSInteger progress);

@interface RSMultipartResponseCmd : RSCmd

@property (nonatomic, copy) RSCmdProgessCallback progressBlock;
@property (nonatomic, assign) NSInteger progress;

@end
