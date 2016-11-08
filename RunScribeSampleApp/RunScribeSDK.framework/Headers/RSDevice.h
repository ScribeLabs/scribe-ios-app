//
//  RSDevice.h
//  Runscribe
//
//  Created by Adam Hamel on 4/9/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

static NSUInteger kMinimumBatteryLevel = 5;

// Protocol versions
extern NSString * const kFirmwareWithNoProtocolVer;
extern NSString * const kProtocolVer1_3;
extern NSString * const kProtocolVer1_4;
extern NSString * const kProtocolVer1_5;
extern NSString * const kProtocolVer1_6;
extern NSString * const kProtocolVer1_7;
extern NSString * const kProtocolVer1_8;
extern NSString * const kProtocolVer1_9;
extern NSString * const kProtocolVer1_10;
extern NSString * const kProtocolVer1_11;
extern NSString * const kProtocolVer1_12;
extern NSString * const kProtocolVer1_13;
extern NSString * const kProtocolVer1_14;
extern NSString * const kProtocolVer1_15;
extern NSString * const kProtocolVer1_16;
extern NSString * const kProtocolVer1_17;
extern NSString * const kProtocolVer1_18;
extern NSString * const kProtocolVer1_19;
extern NSString * const kProtocolVer2_0;
extern NSString * const kProtocolVer2_1;
extern NSString * const kProtocolVer2_2;
extern NSString * const kProtocolVer2_3;
extern NSString * const kProtocolVer2_4;

// Hardware Versions
extern NSString * const kHardwareVer1_0;
extern NSString * const kHardwareVer1_5;
extern NSString * const kHardwareVer2_0;

@class RSCmd;
@interface RSDevice : NSObject

@property (nonatomic, strong, readonly) CBPeripheral *peripheral;
@property (nonatomic, strong, readonly) NSString *uuidString;
@property (nonatomic, strong, readonly) NSString *firmwareVersion;
@property (nonatomic, strong, readonly) NSString *hardwareVersion;
@property (nonatomic, strong, readonly) NSString *softwareVersion;
@property (nonatomic, strong, readonly) NSString *protocolVersion;
@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSString *serialNumber;
@property (nonatomic, assign, readonly) int batteryPct;
@property (nonatomic, assign, readonly) int batteryUsageTime;
@property (nonatomic, assign, readonly) int batteryChargingTime;
@property (nonatomic, assign, readonly) int batteryType;
@property (nonatomic, assign, readonly) int batteryVoltage;
@property (nonatomic, assign, readonly) int rssi;
@property (nonatomic, assign, readonly) int memoryPct;
@property (nonatomic, assign, readonly) int dmpCalibrated;
@property (nonatomic, assign) BOOL autoReconnect;
@property (nonatomic, assign, readonly, getter=isSyncing) BOOL syncing;

- (id)initWithPeripheral:(CBPeripheral *)peripheral;
- (id)initWithUUID:(NSString *)uuid;

// Issue Commands to connected device

- (void)runCmd:(RSCmd *)cmd;
- (void)cancelAllCommands;

/**
 This will return true if the CBPeripheralState is CBPeripheralStateConnecting
 This does not mean the device is ready for communication.
 @see isDeviceReady
 */
- (BOOL)isPeripheralConnecting;

/**
 This will return true if the CBPeripheralState is CBPeripheralStateConnected
 This does not mean the device is ready for communication.
 @see isDeviceReady
 */
- (BOOL)isPeripheralConnected;

/**
 We don't consider the device ready until all the required services
 and characteristics are discovered. As well as a couple requests for
 some key properties like battery level, serial number, etc..
 
 Even though Apple has connected the CBPeripheral we are still going
 to consider the device connecting until the device has completed
 the full discovery and reads. @see isDeviceReady to know when it
 is safe to start communication with the device.
 
 isDeviceConnecting will return true if the peripheral is connected
 but we have not yet fully discovered everything. Once fully discovered
 this will return false and isDeviceReady will return true.
 
 Also RSDeviceConnectedNotification will not fire until device is ready
 */
- (BOOL)isDeviceConnecting;

/**
 We don't consider the device ready until all the required services
 and characteristics are discovered. As well as a couple requests for
 some key properties like battery level, serial number, etc..
 
 Even though Apple has connected the CBPeripheral we are still going
 to consider the device connecting until the device has completed
 the full discovery and reads. @see isDeviceReady to know when it
 is safe to start communication with the device.
 
 isDeviceConnecting will return true if the peripheral is connected
 but we have not yet fully discovered everything. Once fully discovered
 this will return false and isDeviceReady will return true.
 
 Also RSDeviceConnectedNotification will not fire until device is ready
 */
- (BOOL)isDeviceReady;

/**
 Determine if the protocol is at minimum the version that is passed in.
 **/
- (BOOL)isAtProtocolVersion:(NSString *)version;

/**
 Determine if the hardware version is at minimum the version that is passed in.
 **/
- (BOOL)isAtHardwareVersion:(NSString *)version;

@end
