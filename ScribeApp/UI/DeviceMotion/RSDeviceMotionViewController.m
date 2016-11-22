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

#import "RSDeviceMotionViewController.h"
#import "RSDeviceRequestsHelper.h"
#import "RSCoreXYZGraph.h"
#import "GLGravityView.h"
#import "RSSensorSample.h"
#import "RSDeviceMgr.h"

@interface RSDeviceMotionViewController ()

@property (nonatomic, assign) RSPollingMPUDataMode currentMode;
@property (nonatomic, strong) RSCoreXYZGraph *graph;

@property (nonatomic, weak) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, weak) IBOutlet GLGravityView *glGravityView1;
@property (nonatomic, weak) IBOutlet GLGravityView *glGravityView2;

@property (nonatomic, weak) IBOutlet UIButton *accelButton;
@property (nonatomic, weak) IBOutlet UIButton *gyroButton;
@property (nonatomic, weak) IBOutlet UIButton *compassButton;

@property (nonatomic, weak) IBOutlet UITextField *pitchMinTextField;
@property (nonatomic, weak) IBOutlet UITextField *pitchCurrentTextField;
@property (nonatomic, weak) IBOutlet UITextField *pitchMaxTextField;
@property (nonatomic, weak) IBOutlet UITextField *rollMinTextField;
@property (nonatomic, weak) IBOutlet UITextField *rollCurrentTextField;
@property (nonatomic, weak) IBOutlet UITextField *rollMaxTextField;
@property (nonatomic, weak) IBOutlet UITextField *yawMinTextField;
@property (nonatomic, weak) IBOutlet UITextField *yawCurrentTextField;
@property (nonatomic, weak) IBOutlet UITextField *yawMaxTextField;

@end

@implementation RSDeviceMotionViewController

#define AVG_SAMPLE 9
short xDataArray[AVG_SAMPLE], yDataArray[AVG_SAMPLE], zDataArray[AVG_SAMPLE];
double pitchMin, pitchMax;
double rollMin, rollMax;
double yawMin, yawMax;

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        memset(xDataArray, 0, sizeof xDataArray);
        memset(yDataArray, 0, sizeof yDataArray);
        memset(zDataArray, 0, sizeof zDataArray);
        pitchMin = 0;
        pitchMax = 0;
        rollMin = 0;
        rollMax = 0;
        yawMin = 0;
        yawMax = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:26.0 / 255.0 green:26.0 / 255.0 blue:26.0 / 255.0 alpha:1.0];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnected:) name:RSDeviceConnectedNotification object:nil];
    
    self.glGravityView1.rotAngle = 0.0;
    self.glGravityView2.rotAngle = 90.0;
    
    [self.glGravityView1 startAnimation];
    [self.glGravityView2 startAnimation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareAccelGraph];
    [self activateButtonForMode:kRSMPUModeAccel];
    [self enableStreamingData:kRSMPUModeAccel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self disableStreamingData:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.glGravityView1 stopAnimation];
    [self.glGravityView2 stopAnimation];
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
            [strongSelf deactivateButtonForMode:strongSelf.currentMode];
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
            [strongSelf activateButtonForMode:mode];
            
            [strongSelf enableStreamingData:mode];
        });
    }];
}

- (void)enableStreamingData:(RSPollingMPUDataMode)mode
{
    self.currentMode = mode;
    
    __weak RSDeviceMotionViewController *weakSelf = self;
    RSMotionDataStreamCallback callback = ^(RSMotionData *motionData) {
        RSDeviceMotionViewController *strongSelf = weakSelf;
        if (strongSelf.currentMode != motionData.mpuDataModeIndex)
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
                
                [strongSelf displaySample:[[RSSensorSample alloc] initWithX:@(accelXSum / AVG_SAMPLE / 2048.0)
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
                
                [strongSelf displaySample:[[RSSensorSample alloc] initWithX:@(gyroXSum / AVG_SAMPLE / 16.0)
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
                
                [strongSelf displaySample:[[RSSensorSample alloc] initWithX:@(compassXSum / AVG_SAMPLE / 32.0)
                                                                          y:@(compassYSum / AVG_SAMPLE / 32.0)
                                                                          z:@(compassZSum / AVG_SAMPLE / 32.0)]];
                break;
            }
        }
        
        double rawQuaternion[4] = {motionData.quaternion1, motionData.quaternion2, motionData.quaternion3, motionData.quaternion4};
        double quat[4];
        for (int i = 0; i < 4; i++)
        {
            if (rawQuaternion[i] > 32767)
            {
                rawQuaternion[i] -= 65536;
            }
            quat[i] = rawQuaternion[i] / 16384.0;
        }
        
        [strongSelf.glGravityView1 updateQuat0:quat[0]
                                         quat1:quat[1]
                                         quat2:quat[2]
                                         quat3:quat[3]];
        
        [strongSelf.glGravityView2 updateQuat0:quat[0]
                                         quat1:quat[1]
                                         quat2:quat[2]
                                         quat3:quat[3]];
        
        double pitch = atan2((2.0 * (quat[0] * quat[1] + quat[2] * quat[3])), (1.0 - 2.0 * (quat[1] * quat[1] + quat[2] * quat[2])));
        double roll = asin((2.0 * (quat[0] * quat[2] - quat[3] * quat[1])));
        double yaw = atan2((2.0 * (quat[0] * quat[3] + quat[1] * quat[2])), (1.0 - 2.0 * (quat[2] * quat[2] + quat[3] * quat[3])));
        
        pitch = pitch * 180.0 / M_PI;
        roll = roll * 180.0 / M_PI;
        yaw = yaw * 180.0 / M_PI;
        
        yaw = -yaw;
        if (yaw < 0)
        {
            yaw += 180.0;
        }
        else
        {
            yaw -= 180.0;
        }
        
        dispatch_async(dispatch_get_main_queue(),^{
            [strongSelf updatePitchValue:pitch];
            [strongSelf updateRollValue:roll];
            [strongSelf updateYawValue:yaw];
        });
    };
    
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

#pragma mark - UI

- (void)prepareAccelGraph
{
    NSSignedRange yAxisRange;
    yAxisRange.location = -6;
    yAxisRange.length = 12;
    self.graph = [[RSCoreXYZGraph alloc] initWithHostingView:self.hostView
                                                       theme:[CPTTheme themeNamed:kCPTDarkGradientTheme]
                                                  yAxisRange:yAxisRange];
}

- (void)prepareGyroGraph
{
    NSSignedRange yAxisRange;
    yAxisRange.location = -1000;
    yAxisRange.length = 2000;
    self.graph = [[RSCoreXYZGraph alloc] initWithHostingView:self.hostView
                                                       theme:[CPTTheme themeNamed:kCPTDarkGradientTheme]
                                                  yAxisRange:yAxisRange];
}

- (void)prepareCompassGraph
{
    NSSignedRange yAxisRange;
    yAxisRange.location = -20;
    yAxisRange.length = 40;
    self.graph = [[RSCoreXYZGraph alloc] initWithHostingView:self.hostView
                                                       theme:[CPTTheme themeNamed:kCPTDarkGradientTheme]
                                                  yAxisRange:yAxisRange];
}

- (void)deactivateButtonForMode:(RSPollingMPUDataMode)mode
{
    UIButton *button;
    switch (mode) {
        case kRSMPUModeAccel:
            button = self.accelButton;
            break;
        case kRSMPUModeGyro:
            button = self.gyroButton;
            break;
        case kRSMPUModeCompass:
            button = self.compassButton;
            break;
    }
    
    [button setEnabled:YES];
    [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

- (void)activateButtonForMode:(RSPollingMPUDataMode)mode
{
    UIButton *button;
    switch (mode) {
        case kRSMPUModeAccel:
            button = self.accelButton;
            break;
        case kRSMPUModeGyro:
            button = self.gyroButton;
            break;
        case kRSMPUModeCompass:
            button = self.compassButton;
            break;
    }
    
    [button setEnabled:NO];
    [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
}

- (void)displaySample:(RSSensorSample *)sample
{
    dispatch_async(dispatch_get_main_queue(),^{
        [self.graph addNewData:sample];
    });
}

- (void)updatePitchValue:(double)pitch
{
    if (pitch < pitchMin)
    {
        pitchMin = pitch;
        self.pitchMinTextField.text = [NSString stringWithFormat:@"%02.1F", pitchMin];
    }
    
    if (pitch > pitchMax)
    {
        pitchMax = pitch;
        self.pitchMaxTextField.text = [NSString stringWithFormat:@"%02.1F", pitchMax];
    }
    
    self.pitchCurrentTextField.text = [NSString stringWithFormat:@"%02.1F", pitch];
}

- (void)updateRollValue:(double)roll
{
    if (roll < rollMin)
    {
        rollMin = roll;
        self.rollMinTextField.text = [NSString stringWithFormat:@"%02.1F", rollMin];
    }
    
    if (roll > rollMax)
    {
        rollMax = roll;
        self.rollMaxTextField.text = [NSString stringWithFormat:@"%02.1F", rollMax];
    }
    
    self.rollCurrentTextField.text = [NSString stringWithFormat:@"%02.1F", roll];
}

- (void)updateYawValue:(double)yaw
{
    if (yaw < yawMin)
    {
        yawMin = yaw;
        self.yawMinTextField.text = [NSString stringWithFormat:@"%02.1F", yawMin];
    }
    
    if (yaw > yawMax)
    {
        yawMax = yaw;
        self.yawMaxTextField.text = [NSString stringWithFormat:@"%02.1F", yawMax];
    }
    
    self.yawCurrentTextField.text = [NSString stringWithFormat:@"%02.1F", yaw];
}

#pragma mark - Notifications

- (void)deviceConnected:(NSNotification *)note
{
    id obj = [note.userInfo valueForKey:kRSDevice];
    if ([obj isKindOfClass:[RSDevice class]])
    {
        RSDevice *connectedDevice = (RSDevice *)obj;
        if (connectedDevice == self.device)
        {
            [self enableStreamingData:self.currentMode];
        }
    }
}

@end
