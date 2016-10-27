//
//  RSReadDiagnosticsResultsCmd.h
//  Runscribe
//
//  Created by Mark Handel on 10/23/15.
//  Copyright © 2015 Runscribe. All rights reserved.
//

#import "RSCmd.h"

@interface RSReadDiagnosticsResultsCmd : RSCmd

@property (nonatomic, assign) uint totalPackets;
@property (nonatomic, assign) uint packetOffset;
@property (nonatomic, strong) NSString *message;

@end
