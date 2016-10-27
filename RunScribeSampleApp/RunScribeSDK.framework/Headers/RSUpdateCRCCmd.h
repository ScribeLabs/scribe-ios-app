//
//  RSUpdateCRCCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/30/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

@interface RSUpdateCRCCmd : RSCmd

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;
@property (nonatomic, assign) uint blockSize;
@property (nonatomic, assign) uint fileSize;
@property (nonatomic, assign) uint filePointReg;
@property (nonatomic, assign) uint crcHigh;
@property (nonatomic, assign) uint crcLow;

@end
