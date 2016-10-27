//
//  RSDFUConstants.h
//  Runscribe
//
//  Created by Adam Hamel on 6/4/15.
//  Copyright (c) 2015 Runscribe. All rights reserved.
//

typedef NS_ENUM(NSInteger, kDFUError)
{
    kDFUErrorDiscovery,
    kDFUErrorCommunicating,
    kDFUErrorFailedConnect,
    kDFUErrorDisconnect,
    kDFUErrorDeviceNotFound,
    kDFUErrorCentralNotPoweredOn,
    kDFUErrorCentralPoweredOff,
    kDFUErrorBTLENotSupported,
    kDFUErrorCancelled,
    kDFUErrorInvlidBinFile,
    kDFUErrorResettingSystem
};