//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSDeviceMotionViewController.h"
#import "RSDeviceRequestsHelper.h"
#import "RSCoreXYZGraph.h"
#import "RSSensorSample.h"

@interface RSDeviceMotionViewController ()

@property (nonatomic, assign) RSPollingMPUDataMode currentMode;
@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) RSCoreXYZGraph *graph;

@end

@implementation RSDeviceMotionViewController

#define AVG_SAMPLE 9
short xDataArray[AVG_SAMPLE], yDataArray[AVG_SAMPLE], zDataArray[AVG_SAMPLE];

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self prepareAccelGraph];
    [self enableStreamingData:kRSMPUModeAccel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self disableStreamingData:nil];
}

#pragma mark - IBActions

- (IBAction)accelButtonClicked:(id)sender
{
    [self switchStreamingMode:kRSMPUModeAccel];
}

- (IBAction)gyroButtonClicked:(id)sender
{
    [self switchStreamingMode:kRSMPUModeGyro];
}

- (IBAction)compassButtonClicked:(id)sender
{
    [self switchStreamingMode:kRSMPUModeCompass];
}

#pragma mark - Actions

- (void)switchStreamingMode:(RSPollingMPUDataMode)mode
{
    if (mode == self.currentMode)
    {
        return;
    }
    
    __weak RSDeviceMotionViewController *weakSelf = self;
    [self disableStreamingData:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceMotionViewController *strongSelf = weakSelf;
        if (error)
        {
            [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to stop streaming data. Switching mode anyway. Error: %@", strongSelf.device.name, error]];
        }
        else
        {
            [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - Streaming: OFF", strongSelf.device.name]];
        }
        
        memset(xDataArray, 0, sizeof xDataArray);
        memset(yDataArray, 0, sizeof yDataArray);
        memset(zDataArray, 0, sizeof zDataArray);
        
        dispatch_async(dispatch_get_main_queue(),^{
            switch (mode) {
                case kRSMPUModeAccel:
                    [strongSelf prepareAccelGraph];
                    break;
                case kRSMPUModeGyro:
                    [strongSelf prepareGyroGraph];
                    break;
                case kRSMPUModeCompass:
                    [strongSelf prepareCompassGraph];
                    break;
            }
            
            [strongSelf enableStreamingData:mode];
        });
    }];
}

- (void)prepareAccelGraph
{
    NSSignedRange yAxisRange;
    yAxisRange.location = -6;
    yAxisRange.length = 12;
    self.graph = [[RSCoreXYZGraph alloc] initWithHostingView:self.hostView
                                                       theme:[CPTTheme themeNamed:kCPTDarkGradientTheme]
                                                       title:@"Accel"
                                                  yAxisRange:yAxisRange];
}

- (void)prepareGyroGraph
{
    NSSignedRange yAxisRange;
    yAxisRange.location = -1000;
    yAxisRange.length = 2000;
    self.graph = [[RSCoreXYZGraph alloc] initWithHostingView:self.hostView
                                                       theme:[CPTTheme themeNamed:kCPTDarkGradientTheme]
                                                       title:@"Gyro"
                                                  yAxisRange:yAxisRange];
}


- (void)prepareCompassGraph
{
    NSSignedRange yAxisRange;
    yAxisRange.location = -20;
    yAxisRange.length = 40;
    self.graph = [[RSCoreXYZGraph alloc] initWithHostingView:self.hostView
                                                       theme:[CPTTheme themeNamed:kCPTDarkGradientTheme]
                                                       title:@"Compass"
                                                  yAxisRange:yAxisRange];
}


- (void)enableStreamingData:(RSPollingMPUDataMode)mode
{
    self.currentMode = mode;
    RSMotionDataStreamCallback callback = ^(RSMotionData *motionData) {
        if (self.currentMode != motionData.mpuDataModeIndex)
        {
            return;
        }
        
        // Compute the average values and add them to the graph
        switch (motionData.mpuDataModeIndex) {
            case kRSMPUModeAccel:
            {
                for (int i = (AVG_SAMPLE - 1); i > 0; i--)
                {
                    xDataArray[i] = xDataArray[i - 1];
                    yDataArray[i] = yDataArray[i - 1];
                    zDataArray[i] = zDataArray[i - 1];
                }
                
                xDataArray[0] = motionData.accelX;
                yDataArray[0] = motionData.accelY;
                zDataArray[0] = motionData.accelZ;
                
                long accelXSum = 0;
                long accelYSum = 0;
                long accelZSum = 0;
                
                for (int i = 0; i < AVG_SAMPLE; i++)
                {
                    accelXSum += xDataArray[i];
                    accelYSum += yDataArray[i];
                    accelZSum += zDataArray[i];
                }
                
                [self displaySample:[[RSSensorSample alloc] initWithX:@(accelXSum / AVG_SAMPLE / 2048.0)
                                                                    y:@(accelYSum / AVG_SAMPLE / 2048.0)
                                                                    z:@(accelZSum / AVG_SAMPLE / 2048.0)]];
                break;
            }
            case kRSMPUModeGyro:
            {
                for (int i = (AVG_SAMPLE - 1); i > 0; i--)
                {
                    xDataArray[i] = xDataArray[i - 1];
                    yDataArray[i] = yDataArray[i - 1];
                    zDataArray[i] = zDataArray[i - 1];
                }
                
                xDataArray[0] = motionData.gyroX;
                yDataArray[0] = motionData.gyroY;
                zDataArray[0] = motionData.gyroZ;
                
                long gyroXSum = 0;
                long gyroYSum = 0;
                long gyroZSum = 0;
                
                for (int i = 0; i < AVG_SAMPLE; i++)
                {
                    gyroXSum += xDataArray[i];
                    gyroYSum += yDataArray[i];
                    gyroZSum += zDataArray[i];
                }
                
                [self displaySample:[[RSSensorSample alloc] initWithX:@(gyroXSum / AVG_SAMPLE / 16.0)
                                                                    y:@(gyroYSum / AVG_SAMPLE / 16.0)
                                                                    z:@(gyroZSum / AVG_SAMPLE / 16.0)]];
                break;
            }
            case kRSMPUModeCompass:
            {
                for (int i = (AVG_SAMPLE - 1); i > 0; i--)
                {
                    xDataArray[i] = xDataArray[i - 1];
                    yDataArray[i] = yDataArray[i - 1];
                    zDataArray[i] = zDataArray[i - 1];
                }
                
                xDataArray[0] = motionData.compassX;
                yDataArray[0] = motionData.compassY;
                zDataArray[0] = motionData.compassZ;
                
                long compassXSum = 0;
                long compassYSum = 0;
                long compassZSum = 0;
                
                for (int i = 0; i < AVG_SAMPLE; i++)
                {
                    compassXSum += xDataArray[i];
                    compassYSum += yDataArray[i];
                    compassZSum += zDataArray[i];
                }
                
                [self displaySample:[[RSSensorSample alloc] initWithX:@(compassXSum / AVG_SAMPLE / 32.0)
                                                                    y:@(compassYSum / AVG_SAMPLE / 32.0)
                                                                    z:@(compassZSum / AVG_SAMPLE / 32.0)]];
                break;
            }
        }
    };
    
    __weak RSDeviceMotionViewController *weakSelf = self;
    [RSDeviceRequestsHelper enablePollingMPUData:self.device mode:mode streamBlock:callback completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceMotionViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to enable streaming data. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Failed to enable streaming data. Please, try again."];
            }
            else
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - Streaming: ON", strongSelf.device.name]];
            }
        });
    }];
}

- (void)disableStreamingData:(RSCmdCompletedCallback)callback
{
    // The command which enables streaming data on the device is executing at this time.
    // We have to cancel all commands to be able to execute others (do not stick in a queue)
    [self.device cancelAllCommands];
    
    if (!callback)
    {
        __weak RSDeviceMotionViewController *weakSelf = self;
        callback = ^(RSCmd *sourceCmd, NSError *error) {
            RSDeviceMotionViewController *strongSelf = weakSelf;
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to disable streaming data. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Failed to disable streaming data. Please, try again."];
            }
            else
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - Streaming: OFF", strongSelf.device.name]];
            }
        };
    }
    
    [RSDeviceRequestsHelper disablePollingMPUData:self.device completionBlock:callback];
}

- (void)displaySample:(RSSensorSample *)sample
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.graph addNewData:sample];
    });
}

@end
