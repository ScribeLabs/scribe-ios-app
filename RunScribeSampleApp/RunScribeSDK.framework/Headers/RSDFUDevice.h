//
//  RSDFUDevice.h
//  Runscribe
//
//  Created by Adam Hamel on 5/30/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RSDFUFile.h"
#import "RSDFUConstants.h"

static int const kPacketNotificationInterval = 10;
static int const kPacketSize = 20;

typedef NS_ENUM(NSInteger, kInitPacket)
{
    kStartInitPacket = 0x00,
    kEndInitPacket = 0x01
};

struct DFUResponse
{
    uint8_t responseCode;
    uint8_t requestedCode;
    uint8_t responseStatus;
    uint32_t payload;
};

typedef NS_ENUM(NSInteger, kDFUOperationStatus)
{
    kOperationSuccessfulResponse = 0x01,
    kOperationInvalidResponse = 0x02,
    kOperationNotSupportedResponse = 0x03,
    kDataSizeExceedsLimitResponse = 0x04,
    kCrcErrorResponse = 0x05,
    kOperationFailedResponse = 0x06
};

typedef NS_ENUM(NSInteger, kDFUOperations)
{
    kStartDFURequest = 0x01,
    kInitializeDFUParametersRequest = 0x02,
    kReceiveFirmwareImageRequest = 0x03,
    kValidateFirmwareImageRequest = 0x04,
    kActivateAndResetRequest = 0x05,
    kResetSytem = 0x06,
    kReceivedImageSizeRequest = 0x07,
    kPacketReceiptNotificationRequest = 0x08,
    kResponseCode = 0x10,
    kPacketReceiptNotificationResponse = 0x11
};

typedef NS_ENUM(NSInteger, kDFUFirmwareTypes)
{
    kSoftDevice = 0x01,
    kBootloader = 0x02,
    kSoftDeviceAndBootloader = 0x03,
    kApplication = 0x04
};

static NSString * const dfuServiceUUID = @"00001530-1212-EFDE-1523-785FEABCD123";
static NSString * const dfuControlPointCharUUID = @"00001531-1212-EFDE-1523-785FEABCD123";
static NSString * const dfuPacketCharUUID = @"00001532-1212-EFDE-1523-785FEABCD123";

@protocol RSDFUDeviceDelegate;

@interface RSDFUDevice : NSObject

@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong, readonly) NSString *uuidString;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, weak) id<RSDFUDeviceDelegate>deviceDelegate;
@property struct DFUResponse dfuResponse;
@property (nonatomic, assign) int rssi;

- (id)initWithUUID:(NSString *)uuidString;
- (id)initWithPeripheral:(CBPeripheral *)peripheral file:(RSDFUFile *)file;

- (void)didDiscoverPeripheral;
- (void)didConnectPeripheral;
- (void)didFailToConnectToPeripheral;
- (void)didDisconnectPeripheral;
- (void)startFirmwareUpdate;
- (void)cancelFirmwareUpdate;

@end

@protocol RSDFUDeviceDelegate <NSObject>

- (void)deviceConnected;
- (void)firmwareUpdateComplete:(NSError *)error;
- (void)failedDiscovery:(NSError *)error;
- (void)failedCharacteristicReadWrite:(NSError *)error;
- (void)fileTransferPercentage:(int)percent;
- (void)fileTransferStarted;

@end
