//
//  RSSetTimeCmd.h
//  Runscribe
//
//  Created by Mark Handel on 7/10/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

@interface RSSetTimeCmd : RSCmd

@property (nonatomic, strong) NSDate *deviceTime;
@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;

@end
