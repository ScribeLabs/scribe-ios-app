//
//  RSStopReadDataCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/18/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSFileCmd.h"

@interface RSStopReadDataCmd : RSFileCmd

@property (nonatomic, assign) uint versionMajor;
@property (nonatomic, assign) uint versionMinor;

@end
