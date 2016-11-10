//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSConfiguration.h"
#import "RSDevice.h"
#import "RSCmd.h"
#import "RSEraseDataCmd.h"
#import "RSSetModeCmd.h"

@interface RSDeviceRequestsHelper : NSObject

/**
 *  Lights up LED on the device using the specified RGB values.
 */
+ (void)lightUpLEDWithRed:(NSInteger)red
                    green:(NSInteger)green
                     blue:(NSInteger)blue
                   device:(RSDevice *)device
          completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Dims LED on the specified device.
 */
+ (void)dimLED:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Lights up LED on the specified device using his own default LED color.
 */
+ (void)displayDefaultLedColor:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Performs erasing on the device using the specified erase type.
 */
+ (void)erase:(RSDevice *)device eraseType:(RSEraseTypes)eraseType completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Turns on/off the specified mode on the device.
 */
+ (void)setMode:(RSDevice *)device
        command:(RSScribeModeCommand)command
          state:(RSScribeModeCommandStatus)state
completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Reads the device status.
 */
+ (void)readStatus:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Reads the device configuration.
 */
+ (void)readConfiguration:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Writes the configuration to the device.
 */
+ (void)writeConfiguration:(RSConfiguration *)configuration
                  toDevice:(RSDevice *)device
           completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Reads the device system time.
 */
+ (void)readDeviceTime:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Sets current date and time on the device.
 */
+ (void)setDeviceTime:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Reads the list of files stored on the device.
 *  The list also includes files that are marked as those that should be removed when the device is ready.
 */
+ (void)readFileList:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Reads information about the file with specified index.
 */
+ (void)readFileInformation:(NSInteger)fileIndex device:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

@end
