//
//  RSDevicePrivate.h
//  Runscribe
//
//  Created by Adam Hamel on 5/2/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//
@class RSCmd;

@interface RSDevice (Private)

@property (nonatomic, strong, readwrite) CBPeripheral *peripheral;
@property (nonatomic, strong, readwrite) NSString *name;
@property (nonatomic, assign, readwrite, getter=isSyncing) BOOL syncing;
@property (nonatomic, assign, readwrite) int rssi;
@property (nonatomic, assign, readwrite) int dmpCalibrated;

- (void)writeCmd:(RSCmd *)cmd;

// Callbacks from RSDeviceMgr
- (void)didStartPeripheralConnect;
- (BOOL)didDiscoverPeripheral:(NSDictionary *)advInfo rssi:(NSNumber *)rssi;
- (void)didConnectPeripheral;
- (void)didFailToConnectPeripheral;
- (void)didDisconnectPeripheral;

@end
