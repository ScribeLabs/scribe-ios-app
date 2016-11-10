//
//  Copyright © 2016 RunScribe. All rights reserved.
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

@end
