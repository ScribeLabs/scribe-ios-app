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

#import "RSDeviceRequestsHelper.h"
#import "RSCommandFactory.h"
#import "RSDisplayLEDCmd.h"
#import "RSDefaultLEDColorCmd.h"
#import "RSStatusCmd.h"
#import "RSConfigCmd.h"
#import "RSReadTimeCmd.h"
#import "RSSetTimeCmd.h"
#import "RSFileListCmd.h"
#import "RSFileInfoCmd.h"
#import "RSEnterDFUModeCmd.h"
#import "RSRebootCmd.h"
#import "RSRunDiagnosticsCmd.h"
#import "RSStopReadDataCmd.h"

@implementation RSDeviceRequestsHelper

+ (void)lightUpLEDWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue device:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSDisplayLEDCmd *displayLEDCmd = (RSDisplayLEDCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdDisplayLED forDevice:device];
        displayLEDCmd.red = red;
        displayLEDCmd.green = green;
        displayLEDCmd.blue = blue;
        displayLEDCmd.pattern = kRSLEDPatternConnected;
        displayLEDCmd.cycles = 30; // keep it on for a minute -- ie, 30 cycles of 2 second animations.
        [displayLEDCmd setCompletedBlock:callback];
        [device runCmd:displayLEDCmd];
    }
}

+ (void)dimLED:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSDisplayLEDCmd *displayLEDCmd = (RSDisplayLEDCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdDisplayLED forDevice:device];
        displayLEDCmd.pattern = kRSLEDPatternCancel;
        [displayLEDCmd setCompletedBlock:callback];
        [device runCmd:displayLEDCmd];
    }
}

+ (void)displayDefaultLedColor:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSDefaultLEDColorCmd *getDefaultLedColorCmd = (RSDefaultLEDColorCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdGetDefaultLED
                                                                                                                     forDevice:device];
        [getDefaultLedColorCmd setCompletedBlock:^(RSCmd *sourceCmd, NSError *error) {
            if (!error)
            {
                RSDefaultLEDColorCmd *defaultLEDColorResponse = (RSDefaultLEDColorCmd *)sourceCmd;
                
                // we've got default LED color. Let's light up LED using this color.
                [RSDeviceRequestsHelper lightUpLEDWithRed:defaultLEDColorResponse.red
                                                    green:defaultLEDColorResponse.green
                                                     blue:defaultLEDColorResponse.blue
                                                   device:device
                                          completionBlock:^(RSCmd *sourceCmd, NSError *error) {
                                              if (callback)
                                              {
                                                  callback(sourceCmd, error);
                                              }
                                          }];
            }
            else
            {
                if (callback)
                {
                    callback(sourceCmd, error);
                }
            }
        }];
        [device runCmd:getDefaultLedColorCmd];
    }
}

+ (void)erase:(RSDevice *)device eraseType:(RSEraseTypes)eraseType completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSEraseDataCmd *eraseDataCmd = (RSEraseDataCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdEraseData forDevice:device];
        eraseDataCmd.blockTillCleared = YES;
        eraseDataCmd.eraseType = eraseType;
        [eraseDataCmd setCompletedBlock:callback];
        [device runCmd:eraseDataCmd];
    }
}

+ (void)setMode:(RSDevice *)device command:(RSScribeModeCommand)command state:(RSScribeModeCommandStatus)state completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSSetModeCmd *setModeCmd = (RSSetModeCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdSetMode forDevice:device];
        setModeCmd.command = command;
        setModeCmd.state = state;
        [setModeCmd setCompletedBlock:callback];
        [device runCmd:setModeCmd];
    }
}

+ (void)readStatus:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSStatusCmd *statusCmd = (RSStatusCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdStatus forDevice:device];
        [statusCmd setCompletedBlock:callback];
        [device runCmd:statusCmd];
    }
}

+ (void)readConfiguration:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSConfigCmd *readConfigCmd = (RSConfigCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdReadConfig forDevice:device];
        readConfigCmd.configPoint = kRSScribeConfig;
        [readConfigCmd setCompletedBlock:callback];
        [device runCmd:readConfigCmd];
    }
}

+ (void)writeConfiguration:(RSConfiguration *)configuration toDevice:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSConfigCmd *writeConfigCmd = (RSConfigCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdWriteConfig forDevice:device];
        writeConfigCmd.configPoint = kRSScribeConfig;
        writeConfigCmd.placement = (uint)configuration.placement;
        writeConfigCmd.side = (uint)configuration.side;
        writeConfigCmd.timeOut = (uint)configuration.timeOut;
        writeConfigCmd.strideRate = (uint)configuration.strideRate;
        writeConfigCmd.scaleFactorA = (uint)configuration.scaleFactorA;
        writeConfigCmd.scaleFactorB = (uint)configuration.scaleFactorB;
        writeConfigCmd.recordingVoltageThreshold = (uint)configuration.recordingVoltageThreshold;
        writeConfigCmd.sleepVoltageThreshold = (uint)configuration.sleepVoltageThreshold;
        writeConfigCmd.ledRed = (uint)configuration.ledRed;
        writeConfigCmd.ledGreen = (uint)configuration.ledGreen;
        writeConfigCmd.ledBlue = (uint)configuration.ledBlue;
        [writeConfigCmd setCompletedBlock:callback];
        [device runCmd:writeConfigCmd];
    }
}

+ (void)readDeviceTime:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSReadTimeCmd *readTimeCmd = (RSReadTimeCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdReadTime forDevice:device];
        [readTimeCmd setCompletedBlock:callback];
        [device runCmd:readTimeCmd];
    }
}

+ (void)setDeviceTime:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSSetTimeCmd *setTimeCmd = (RSSetTimeCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdSetTime forDevice:device];
        setTimeCmd.deviceTime = [NSDate date];
        [setTimeCmd setCompletedBlock:callback];
        [device runCmd:setTimeCmd];
    }
}

+ (void)readFileList:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSFileListCmd *fileListCmd = (RSFileListCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdFileList forDevice:device];
        fileListCmd.fileType = kRSFileTypesAllFiles;
        [fileListCmd setCompletedBlock:callback];
        [device runCmd:fileListCmd];
    }
}

+ (void)readFileInformation:(NSInteger)fileIndex device:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSFileInfoCmd *fileInfoCmd = (RSFileInfoCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdFileInfo forDevice:device];
        fileInfoCmd.fileIndex = (uint)fileIndex;
        [fileInfoCmd setCompletedBlock:callback];
        [device runCmd:fileInfoCmd];
    }
}

+ (void)enterDFUMode:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSEnterDFUModeCmd *enterDFUCmd = (RSEnterDFUModeCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdDFUMode forDevice:device];
        [enterDFUCmd setCompletedBlock:callback];
        [device runCmd:enterDFUCmd];
    }
}

+ (void)rebootDevice:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSRebootCmd *rebootCmd = (RSRebootCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdReboot forDevice:device]; 
        [rebootCmd setCompletedBlock:callback];
        [device runCmd:rebootCmd];
    }
}

+ (void)runDiagnostics:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    if (device != nil && [device isDeviceReady])
    {
        RSRunDiagnosticsCmd *runDiagnosticsCmd = (RSRunDiagnosticsCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdRunDiagnostics forDevice:device];
        runDiagnosticsCmd.mode = kRSDiagnosticsReadMode;
        [runDiagnosticsCmd setCompletedBlock:callback];
        [device runCmd:runDiagnosticsCmd];
    }
}

+ (void)enablePollingMPUData:(RSDevice *)device mode:(RSPollingMPUDataMode)mode streamBlock:(RSMotionDataStreamCallback)streamCallback completionBlock:(RSCmdCompletedCallback)callback
{
    RSPollingMPUDataCmd *pollingMPUDataCmd = (RSPollingMPUDataCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdPollingMPUData forDevice:device];
    pollingMPUDataCmd.mode = mode;
    [pollingMPUDataCmd setMotionDataCallback:streamCallback];
    [pollingMPUDataCmd setCompletedBlock:callback];
    [device runCmd:pollingMPUDataCmd];
}

+ (void)disablePollingMPUData:(RSDevice *)device completionBlock:(RSCmdCompletedCallback)callback
{
    RSStopReadDataCmd *stopReadingDataCmd = (RSStopReadDataCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdStopReadData forDevice:device];
    [stopReadingDataCmd setCompletedBlock:callback];
    [device runCmd:stopReadingDataCmd];
}

@end
