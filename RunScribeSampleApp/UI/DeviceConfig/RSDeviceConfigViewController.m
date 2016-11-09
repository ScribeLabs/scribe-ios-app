//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSDeviceConfigViewController.h"
#import "MBProgressHUD.h"
#import "RSCommandFactory.h"
#import "RSConfigCmd.h"
#import "RSReadTimeCmd.h"
#import "RSSetTimeCmd.h"
#import "RSDeviceRequestsHelper.h"

NSInteger const kRSPickerViewPlacementTag = 0;
NSInteger const kRSPickerViewSideTag = 1;
NSInteger const kRSPickerViewRGBTag = 2;

NSString * const kRSPlacementHeelTitle = @"Heel";
NSString * const kRSPlacementLacesTitle = @"Laces";

NSString * const kRSSideLeftTitle = @"Left";
NSString * const kRSSideRightTitle = @"Right";

@interface RSDeviceConfigViewController () <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSArray *placementTitles;
@property (nonatomic, strong) NSArray *sideTitles;
@property (nonatomic, strong) NSMutableArray *rgbTitles;

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSTimeInterval deviceSystemTime;
@property (nonatomic, strong) NSDateFormatter *deviceDateFormatter;

@property (nonatomic, weak) IBOutlet UITextField *placementTextField;
@property (nonatomic, weak) IBOutlet UITextField *sideTextField;
@property (nonatomic, weak) IBOutlet UITextField *recordingTimeoutField;
@property (nonatomic, weak) IBOutlet UITextField *strideRateField;
@property (nonatomic, weak) IBOutlet UITextField *scaleFactorAField;
@property (nonatomic, weak) IBOutlet UITextField *scaleFactorBField;
@property (nonatomic, weak) IBOutlet UITextField *minRecordingVoltageField;
@property (nonatomic, weak) IBOutlet UITextField *deepSleepVoltageField;
@property (nonatomic, weak) IBOutlet UITextField *defaultRedColorField;
@property (nonatomic, weak) IBOutlet UITextField *defaultGreenColorField;
@property (nonatomic, weak) IBOutlet UITextField *defaultBlueColorField;
@property (nonatomic, weak) IBOutlet UITextField *deviceTimeField;

@end

@implementation RSDeviceConfigViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.placementTitles = @[kRSPlacementHeelTitle, kRSPlacementLacesTitle];
        self.sideTitles = @[kRSSideLeftTitle, kRSSideRightTitle];
        
        self.rgbTitles = [NSMutableArray array];
        for (int i = 0; i < 256; i++)
        {
            [self.rgbTitles addObject:@(i)];
        }
        
        self.deviceDateFormatter = [[NSDateFormatter alloc] init];
        [self.deviceDateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    return self;
}

- (void)viewDidLoad
{
    [self addDoneButtonOnKeyboardforTextField:self.placementTextField];
    self.placementTextField.inputView = [self createPickerViewWithTag:kRSPickerViewPlacementTag];
    
    [self addDoneButtonOnKeyboardforTextField:self.sideTextField];
    self.sideTextField.inputView = [self createPickerViewWithTag:kRSPickerViewSideTag];

    UIPickerView *rgbPickerView = [self createPickerViewWithTag:kRSPickerViewRGBTag];
    self.defaultRedColorField.inputView = rgbPickerView;
    self.defaultGreenColorField.inputView = rgbPickerView;
    self.defaultBlueColorField.inputView = rgbPickerView;
    
    [self addDoneButtonOnKeyboardforTextField:self.defaultRedColorField];
    [self addDoneButtonOnKeyboardforTextField:self.defaultGreenColorField];
    [self addDoneButtonOnKeyboardforTextField:self.defaultBlueColorField];
    [self addDoneButtonOnKeyboardforTextField:self.recordingTimeoutField];
    [self addDoneButtonOnKeyboardforTextField:self.strideRateField];
    [self addDoneButtonOnKeyboardforTextField:self.scaleFactorAField];
    [self addDoneButtonOnKeyboardforTextField:self.scaleFactorBField];
    [self addDoneButtonOnKeyboardforTextField:self.minRecordingVoltageField];
    [self addDoneButtonOnKeyboardforTextField:self.deepSleepVoltageField];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self readConfiguration];
    [self readDeviceTime];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTimer];
}

- (void)updateUI:(RSConfigCmd *)configResponse
{
    [self setLocationText:configResponse.placement];
    [self setSideText:configResponse.side];
    [self.recordingTimeoutField setText:[NSString stringWithFormat:@"%i", configResponse.timeOut]];
    [self.strideRateField setText:[NSString stringWithFormat:@"%i", configResponse.strideRate]];
    [self.scaleFactorAField setText:[NSString stringWithFormat:@"%i", configResponse.scaleFactorA]];
    [self.scaleFactorBField setText:[NSString stringWithFormat:@"%i", configResponse.scaleFactorB]];
    [self.minRecordingVoltageField setText:[NSString stringWithFormat:@"%i", configResponse.recordingVoltageThreshold]];
    [self.deepSleepVoltageField setText:[NSString stringWithFormat:@"%i", configResponse.sleepVoltageThreshold]];
    [self setLEDColorTextWithRed:configResponse.ledRed green:configResponse.ledGreen blue:configResponse.ledBlue];
}

#pragma mark - Actions

/**
 *  Reads the device configuration such as location, side, recording timeout, voltage thresholds, etc.
 *  The received values are shown in the specific text fields.
 */
- (void)readConfiguration
{
    __weak RSDeviceConfigViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [RSDeviceRequestsHelper readConfiguration:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceConfigViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to read the device configuration. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Error occurred while reading the device configuration. Please, try again."];
            }
            else
            {
                RSConfigCmd *configResponse = (RSConfigCmd *)sourceCmd;
                [strongSelf updateUI:configResponse];
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - successfully read the device configuration", strongSelf.device.name]];
            }
        });
    }];
}

/**
 *  Writes the configuration to the device based on data from the specific text fields.
 */
- (void)writeConfiguration
{
    __weak RSDeviceConfigViewController *weakSelf = self;
    
    RSConfiguration *config = [[RSConfiguration alloc] init];
    config.placement = [self getPlacement:self.placementTextField.text];
    config.side = [self getSide:self.sideTextField.text];
    config.timeOut = [self getIntegerFromTextField:self.recordingTimeoutField];
    config.strideRate = [self getIntegerFromTextField:self.strideRateField];
    config.scaleFactorA = [self getIntegerFromTextField:self.scaleFactorAField];
    config.scaleFactorB = [self getIntegerFromTextField:self.scaleFactorBField];
    config.recordingVoltageThreshold = [self getIntegerFromTextField:self.minRecordingVoltageField];
    config.sleepVoltageThreshold = [self getIntegerFromTextField:self.deepSleepVoltageField];
    config.ledRed = [self getIntegerFromTextField:self.defaultRedColorField];
    config.ledGreen = [self getIntegerFromTextField:self.defaultGreenColorField];
    config.ledBlue = [self getIntegerFromTextField:self.defaultBlueColorField];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    [RSDeviceRequestsHelper writeConfiguration:config toDevice:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceConfigViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error == nil)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - successfully written the device configuration", strongSelf.device.name]];
            }
            else
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to write the configuration to the device. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Error occurred while writting configuration to the device. Please, try again."];
            }
        });
    }];
}

/**
 *  Reads the device system time and displays it in the specific text field.
 *  The field is updating every second.
 */
- (void)readDeviceTime
{
    __weak RSDeviceConfigViewController *weakSelf = self;
    [RSDeviceRequestsHelper readDeviceTime:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceConfigViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to read the device system time. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Error occurred while reading the device system time. Please, try again."];
            }
            else
            {
                RSReadTimeCmd *readTimeResponse = (RSReadTimeCmd *)sourceCmd;
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - successfully read the device system time", strongSelf.device.name]];
                strongSelf.deviceSystemTime = readTimeResponse.systemTime.timeIntervalSince1970;
                [strongSelf startTimer];
            }
        });
    }];
}

/**
 *  Sets current date and time on the device.
 */
- (void)setDeviceTime
{
    __weak RSDeviceConfigViewController *weakSelf = self;
    [RSDeviceRequestsHelper setDeviceTime:self.device completionBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceConfigViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            if (error)
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - failed to set date and time on the device. Error: %@", strongSelf.device.name, error]];
                [strongSelf showAlertWithTitle:@"Error" message:@"Error occurred while setting the system time on the device. Please, try again."];
            }
            else
            {
                [strongSelf writeMessage:[NSString stringWithFormat:@"[%@] - successfully set the device system time", strongSelf.device.name]];
                strongSelf.deviceSystemTime = [[NSDate date] timeIntervalSince1970];
            }
        });
    }];
}

#pragma mark - View setters

- (void)setLocationText:(RSDevicePlacement)location
{
    NSString *locationTitle = [self getPlacementString:location];
    [self.placementTextField setText:locationTitle];
    UIPickerView *pickerView = ((UIPickerView *)self.placementTextField.inputView);
    [pickerView selectRow:[self.placementTitles indexOfObject:locationTitle] inComponent:0 animated:NO];
}

- (void)setSideText:(RSDeviceSide)side
{
    NSString *sideTitle = [self getSideString:side];
    [self.sideTextField setText:sideTitle];
    UIPickerView *pickerView = ((UIPickerView *)self.sideTextField.inputView);
    [pickerView selectRow:[self.sideTitles indexOfObject:sideTitle] inComponent:0 animated:NO];
}

- (void)setLEDColorTextWithRed:(NSInteger)red green:(NSInteger)green blue:(NSInteger)blue
{
    [self.defaultRedColorField setText:[NSString stringWithFormat:@"%li", (long)red]];
    [self.defaultGreenColorField setText:[NSString stringWithFormat:@"%li", (long)green]];
    [self.defaultBlueColorField setText:[NSString stringWithFormat:@"%li", (long)blue]];
    
    UIPickerView *pickerView = ((UIPickerView *)self.defaultRedColorField.inputView);
    [pickerView selectRow:red inComponent:0 animated:NO];
    [pickerView selectRow:green inComponent:1 animated:NO];
    [pickerView selectRow:blue inComponent:2 animated:NO];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (pickerView.tag == kRSPickerViewRGBTag)
    {
        return 3;
    }
    else
    {
        return 1;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (pickerView.tag) {
        case kRSPickerViewPlacementTag:
            return self.placementTitles.count;
            
        case kRSPickerViewSideTag:
            return self.sideTitles.count;
            
        case kRSPickerViewRGBTag:
            return self.rgbTitles.count;
            
        default:
            return 0;
    }
}

#pragma mark - UIPickerViewDelegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (pickerView.tag) {
        case kRSPickerViewPlacementTag:
            return self.placementTitles[row];
            
        case kRSPickerViewSideTag:
            return self.sideTitles[row];
            
        case kRSPickerViewRGBTag: {
            NSString *title;
            switch (component) {
                case 0:
                    title = @"R";
                    break;
                case 1:
                    title = @"G";
                    break;
                case 2:
                    title = @"B";
                    break;
            }
            return [NSString stringWithFormat:@"%@: %@", title, self.rgbTitles[row]];
        }
            
        default:
            return @"";
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (pickerView.tag) {
        case kRSPickerViewPlacementTag:
            [self.placementTextField setText:self.placementTitles[row]];
            break;
            
        case kRSPickerViewSideTag:
            [self.sideTextField setText:self.sideTitles[row]];
            break;
            
        case kRSPickerViewRGBTag: {
            NSNumber *value = self.rgbTitles[row];
            switch (component) {
                case 0:
                    [self.defaultRedColorField setText:[NSString stringWithFormat:@"%@", value]];
                    break;
                case 1:
                    [self.defaultGreenColorField setText:[NSString stringWithFormat:@"%@", value]];
                    break;
                case 2:
                    [self.defaultBlueColorField setText:[NSString stringWithFormat:@"%@", value]];
                    break;
            }
            break;
        }
    }
}

#pragma mark - IBAction

- (IBAction)saveButtonClicked:(id)sender
{
    [self writeConfiguration];
    [self setDeviceTime];
}

#pragma mark - Timer

- (void)startTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

- (void)timerTick:(NSTimer *)sender
{
    self.deviceSystemTime++;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:self.deviceSystemTime];
    [self.deviceTimeField setText:[NSString stringWithFormat:@"%@",[self.deviceDateFormatter stringFromDate:date]]];
}

- (void)stopTimer
{
    if (self.timer)
    {
        [self.timer invalidate];
    }
}

#pragma mark - Extra

/**
 *  Returns string representation of the specified placement
 */
- (NSString *)getPlacementString:(RSDevicePlacement)placement
{
    switch (placement) {
        case kRSDevicePlacementHeel:
            return kRSPlacementHeelTitle;
        case kRSDevicePlacementLaces:
            return kRSPlacementLacesTitle;
        case kRSDevicePlacementUnknown:
            return @"Unknown";
    }
}

/**
 *  Returns an integer representation of the specified placement string. This value we can send to the device.
 */
- (RSDevicePlacement)getPlacement:(NSString *)placementString
{
    if ([placementString isEqualToString:kRSPlacementHeelTitle])
    {
        return kRSDevicePlacementHeel;
    }
    else if ([placementString isEqualToString:kRSPlacementLacesTitle])
    {
        return kRSDevicePlacementLaces;
    }
    else
    {
        return kRSDevicePlacementUnknown;
    }
}

/**
 *  Returns string representation of the specified side
 */
- (NSString *)getSideString:(RSDeviceSide)side
{
    switch (side) {
        case kRSDeviceSideLeftFoot:
            return kRSSideLeftTitle;
        case kRSDeviceSideRightFoot:
            return kRSSideRightTitle;
        case kRSDeviceSideUnknown:
            return @"Unknown";
    }
}

/**
 *  Returns an integer representation of the specified side string. This value we can send to the device.
 */
- (RSDeviceSide)getSide:(NSString *)sideString
{
    if ([sideString isEqualToString:kRSSideLeftTitle])
    {
        return kRSDeviceSideLeftFoot;
    }
    else if ([sideString isEqualToString:kRSSideRightTitle])
    {
        return kRSDeviceSideRightFoot;
    }
    else
    {
        return kRSDeviceSideUnknown;
    }
}

/**
 *  Creates a picker view with specified tag
 */
- (UIPickerView *)createPickerViewWithTag:(NSInteger)tag
{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    pickerView.dataSource = self;
    pickerView.delegate = self;
    pickerView.showsSelectionIndicator = YES;
    pickerView.tag = tag;
    return pickerView;
}

/**
 *  Adds toolbar with Done button to keyboard.
 */
- (void)addDoneButtonOnKeyboardforTextField:(UITextField *)textField
{
    UIToolbar *toolBarbutton = [[UIToolbar alloc] init];
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonClicked)];
    toolBarbutton.items = @[barBtnItem, done];
    [toolBarbutton sizeToFit];
    textField.inputAccessoryView = toolBarbutton;
}

/**
 *  Reacts on Done button click that is placed above the keyboard
 */
- (void)doneButtonClicked
{
    [self.view endEditing:YES];
}

/**
 *  Converts text from the specified text field into an integer value
 */
- (NSInteger)getIntegerFromTextField:(UITextField *)textField
{
    if (textField == nil || textField.text.length == 0)
    {
        return 0;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [numberFormatter numberFromString:textField.text].integerValue;
}

@end
