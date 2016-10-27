//
//  RSReadDataCmd.h
//  Runscribe
//
//  Created by Mark Handel on 5/14/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import "RSMultipartResponseCmd.h"
#import "RSUpdateCRCCmd.h"

@interface RSReadDataCmd : RSMultipartResponseCmd

@property (nonatomic, assign) uint fileIndex;
@property (nonatomic, assign) uint fileSize;
@property (nonatomic, assign) uint blockSize; // always 16
@property (nonatomic, assign) uint filePointReg;
@property (nonatomic, strong) NSData *fileData;
@property (nonatomic, assign) uint8_t crcHigh;
@property (nonatomic, assign) uint8_t crcLow;
@property (nonatomic, assign) uint16_t crc16;
@property (nonatomic, assign) uint16_t crc16Reference;
@property (nonatomic, assign) uint32_t crc32;
@property (nonatomic, strong) RSUpdateCRCCmd *crcCmd;
@property (nonatomic, assign) BOOL performCRCIntegrityCheck;

@end
