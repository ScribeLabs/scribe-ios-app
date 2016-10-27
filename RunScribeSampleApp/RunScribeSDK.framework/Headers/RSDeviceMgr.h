//
//  RSDeviceMgr.h
//  Runscribe
//
//  Created by Adam Hamel on 4/29/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "RSDevice.h"

typedef void (^RSDeviceConnectCallback)(RSDevice *device, NSError *error);

// Notifications
extern NSString * const RSDeviceConnectedNotification;
extern NSString * const RSDeviceConnectFailedNotification;
extern NSString * const RSDeviceConnectTimeoutNotification;
extern NSString * const RSDeviceDisconnectedNotification;
extern NSString * const RSDeviceDiscoveredNotification;
extern NSString * const RSDFUDeviceDiscoveredNotification;
extern NSString * const RSDeviceScanStoppedNotification;
extern NSString * const RSDeviceScanTimedOutNotification;
extern NSString * const RSDeviceMgrBluetoothPoweredOnNotification;
extern NSString * const RSDeviceMgrBluetoothPoweredOffNotification;
extern NSString * const RSDeviceConfigReadNotification;

// Notification Keys
extern NSString * const kRSDevice;
extern NSString * const kRSDFUDevice;
extern NSString * const kRSDeviceOperationModeKey;
// Services
extern NSString * const kRSServiceId;

extern int const kDefaultPeripheralScanSeconds;

@interface RSDeviceMgr : NSObject

+ (RSDeviceMgr *)sharedInstance;

// ---------------------------------------------------------------------------------
// Perform a wireless scan for runScribe devices nearby
// RSDeviceDiscoveredNotification - with kRSDevice key in dictionary
// RSDeviceScanTimedOutNotification - when scanSeconds has been reached
// RSDeviceScanStoppedNotification - if scan was stopped before timeout
// Setting force == YES will cause any existing scans to be stopped
//
// ** MAX scanSeconds is 60 seconds
// ** Note: RSDeviceDiscoveredNotification notification may fire more than once for
//    a single device as it changes during discovery. e.g. RSSI values change etc...
// ---------------------------------------------------------------------------------
- (void)scanForRunscribes:(int)scanSeconds force:(BOOL)force;

// ---------------------------------------------------------------------------------
// Stops any current device scans that are in progress
// RSDeviceScanStoppedNotification - will fire if scan was actually taking place
// ---------------------------------------------------------------------------------
- (void)stopScanning;

// ---------------------------------------------------------------------------------
// Accpets a RSDevice object and attempts to use it's peripheral property to make
// a connection. Typically you would receive a RSDevice from a scan and then call
// connectToDevic and pass in the device you were handed.
// ---------------------------------------------------------------------------------
- (void)connectToDevice:(RSDevice *)device;

// ---------------------------------------------------------------------------------
// Device UUID's can be saved, then used to re-connect at a later date. Use this
// to connect to a previously saved device.
// ---------------------------------------------------------------------------------
- (void)connectToDeviceWithUUID:(NSString *)uuid;

// ---------------------------------------------------------------------------------
// Device UUID's can be saved, then used to re-connect at a later date. Use this
// to connect to a previously saved device.
// ---------------------------------------------------------------------------------
// NOT YET IMPLEMENTED
//- (void)connectToDeviceWithUUID:(NSString *)uuid timeout:(int)timeout withCallback:(RSDeviceConnectCallback)callback;

// ---------------------------------------------------------------------------------
// Disconnects all connected runScibe devices.
// ---------------------------------------------------------------------------------
- (void)disconnectAllDevices;

// ---------------------------------------------------------------------------------
// Disconnects the specific runScibe device.
// ---------------------------------------------------------------------------------
- (void)disconnectDevice:(RSDevice *)device;

// ---------------------------------------------------------------------------------
// RSDeviceMgr keeps an in memory list of RSDevices. If we find a device with the
// passed in UUID we will return it.
// ---------------------------------------------------------------------------------
- (RSDevice *)deviceByUUID:(NSString *)uuid;

// ---------------------------------------------------------------------------------
// Returns the current central bluetooth state
// ---------------------------------------------------------------------------------
- (CBCentralManagerState)centralState;

// ---------------------------------------------------------------------------------
// Returns a list of RSDevice objects that are currently connected
// ---------------------------------------------------------------------------------
- (NSArray *)connectedDevices;

// ---------------------------------------------------------------------------------
// Returns a list of RSDevice objects that are currently connected
// And need DMP calibration
// ---------------------------------------------------------------------------------
- (NSArray *)connectedDevicesNeedingDMPCalibration;

// ---------------------------------------------------------------------------------
// Returns a list of all known RSDevice(s)
// ---------------------------------------------------------------------------------
- (NSArray *)allDevices;

@end
