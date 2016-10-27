//
//  RSFileInfoCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/12/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSFileCmd.h"

@interface RSFileInfoCmd : RSFileCmd

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;
@property (nonatomic, assign) uint blockSize;
@property (nonatomic, assign) uint fileIndex;
@property (nonatomic, assign) uint fileSize;
@property (nonatomic, assign) uint filePointReg;
@property (nonatomic, assign) uint voltage;

@end
