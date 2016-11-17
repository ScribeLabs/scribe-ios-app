//
// MIT License
//
// Copyright (c) 2016 Scribe Labs Inc
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "RSConfiguration.h"
#import "RSDevice.h"
#import "RSCmd.h"
#import "RSEraseDataCmd.h"
#import "RSPollingMPUDataCmd.h"
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
+ (void)readFileInformation:(NSInteger)fileIndex
                     device:(RSDevice *)device
            completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Sends command to the device in order to enter it into DFU mode.
 */
+ (void)enterDFUMode:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Sends command to the device in order to reboot it.
 */
+ (void)rebootDevice:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Performs diagnostics on the device.
 */
+ (void)runDiagnostics:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Enables streaming data for specified mode.
 */
+ (void)enablePollingMPUData:(RSDevice *)device
                        mode:(RSPollingMPUDataMode)mode
                 streamBlock:(RSMotionDataStreamCallback)streamCallback
             completionBlock:(RSCmdCompletedCallback)callback;

/**
 *  Disables streaming data on the device.
 */
+ (void)disablePollingMPUData:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback;

@end
