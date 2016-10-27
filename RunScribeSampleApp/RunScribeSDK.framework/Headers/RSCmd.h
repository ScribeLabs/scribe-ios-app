//
//  RSCmd.h
//  Runscribe
//
//  Created by Adam Hamel on 4/12/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSDevice.h"
#import "RSSDKLogging.h"

static NSString * const kRSCmdErrorDomain = @"rsCmdErrorDomain";

typedef void (^RSCmdCompletedCallback)(RSCmd *sourceCmd, NSError *error);
typedef void (^RSCmdStartedCallback)();


typedef NS_ENUM(NSInteger, RSCmdType)
{
    kRSCmdReboot = 0x41,            // 'A' : Reboot
    kRSCmdAnnotateFile = 0x42,      // 'B' : Annotate File
    kRSCmdUpdateCRC = 0x43,         // 'C' : Update the CRC checksum
    kRSCmdFileList = 0x44,          // 'D' : File List
    kRSCmdEraseData = 0x45,         // 'E' : Erase Data
    kRSCmdDFUMode = 0x46,           // 'F' : DFU Mode
    kRSCmdPollingMPUData = 0x47,    // 'G' : Polling MPU (9-Axis) Data
    kRSCmdFileInfo = 0x49,          // 'I' : Get File Information
    kRSCmdSetDefaultLED = 0x4a,     // 'J' : Set Default LED Color
    kRSCmdGetDefaultLED = 0x4b,     // 'K' : Get Default LED Color
    kRSCmdDisplayLED = 0x4c,        // 'L' : LED
    kRSCmdSetMode = 0x4d,           // 'M' : Set Mode
    kRSCmdStopReadData = 0x50,      // 'P' : Stop Read Data
    kRSCmdReadData = 0x52,          // 'R' : Read Data
    kRSCmdStatus = 0x53,            // 'S' : System Status
    kRSCmdSetTime = 0x54,           // 'T' : Set Time
    kRSCmdReadConfig = 0x55,        // 'U' : Read System Config
    kRSCmdWriteConfig = 0x56,       // 'V' : Write System Config
    kRSCmdReadTime = 0x57,          // 'W' : Read Time
    kRSCmdRunDiagnostics = 0x58,    // 'X' : Run Diagnostics
    kRSCmdReadDiagnostics = 0x5A    // 'Z' : Read Diagnostics Result
};

typedef NS_ENUM(NSInteger, RSCmdErrorCode)
{
    /** Command Errors */
    kRSErrorCmdCancelled = 700,
    kRSErrorCmdTimedOut = 701,
    kRSErrorCmdDeviceNotConnected = 702,
    kRSErrorCmdPeripheralCharacteristicInvalid = 704,
    kRSErrorCmdTrasmissionCRCCheckFailure = 705,
    kRSErrorCmdUnrecognizedParameter = 706,
    kRSErrorCmdFileTransferSizeInvalid = 707,
    kRSErrorCmdInvalidResponse = 708,
    kRSErrorCmdIntegrityCRCCheckFailure = 709,
};


@interface RSCmd : NSOperation

@property (nonatomic, assign) int cmdType;
@property (nonatomic, assign) BOOL complete;
@property (nonatomic, strong) NSData *requestPayload;
@property (nonatomic, strong, readonly) RSDevice *device;

@property (nonatomic, copy) RSCmdCompletedCallback completedBlock;
@property (nonatomic, copy) RSCmdStartedCallback startedBlock;

- (BOOL)allowCmdBeforeFullyConnected;

- (id)initWithDevice:(RSDevice *)device;

- (NSError *)processResponse:(NSData *)data;

- (BOOL)hasResponse;

- (NSData *)createRequest;

- (void)padPacket:(NSMutableData *)data;

@end
