//
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import "RSDeviceConfigViewController.h"
#import "MBProgressHUD.h"
#import "RSCommandFactory.h"
#import "RSConfigCmd.h"

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

#pragma mark - Device requests

- (void)readConfiguration
{
    __weak RSDeviceConfigViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    RSConfigCmd *configCmd = (RSConfigCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdReadConfig forDevice:self.device];
    configCmd.configPoint = (uint)kRSScribeConfig;
    [configCmd setCompletedBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceConfigViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error == nil)
            {
                RSConfigCmd *cCmd = (RSConfigCmd *)sourceCmd;
                [self updateUI:cCmd];
                [self writeMessage:[NSString stringWithFormat:@"Successfully read configuration of %@", self.device.name]];
            }
            else
            {
                [self writeMessage:[NSString stringWithFormat:@"Failed to read configuration of %@. Error: %@", self.device.name, error]];
                [self showAlertWithTitle:@"Error" message:@"Error occurred while reading device configuration. Please, try again."];
            }
        });
    }];
    [self.device runCmd:configCmd];
}

- (void)writeConfiguration
{
    __weak RSDeviceConfigViewController *weakSelf = self;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    
    RSConfigCmd *writeConfigCmd = (RSConfigCmd *)[[RSCommandFactory sharedInstance] getCmdForType:kRSCmdWriteConfig forDevice:self.device];
    writeConfigCmd.configPoint = kRSScribeConfig;
    writeConfigCmd.placement = [self getPlacement:self.placementTextField.text];
    writeConfigCmd.side = [self getSide:self.sideTextField.text];
    
    writeConfigCmd.timeOut = [self getUnsignedIntFromTextField:self.recordingTimeoutField];
    writeConfigCmd.strideRate = [self getUnsignedIntFromTextField:self.strideRateField];
    
    writeConfigCmd.scaleFactorA = [self getUnsignedIntFromTextField:self.scaleFactorAField];
    writeConfigCmd.scaleFactorB = [self getUnsignedIntFromTextField:self.scaleFactorBField];
    
    writeConfigCmd.recordingVoltageThreshold = [self getUnsignedIntFromTextField:self.minRecordingVoltageField];
    writeConfigCmd.sleepVoltageThreshold = [self getUnsignedIntFromTextField:self.deepSleepVoltageField];
    
    writeConfigCmd.ledRed = [self getUnsignedIntFromTextField:self.defaultRedColorField];
    writeConfigCmd.ledGreen = [self getUnsignedIntFromTextField:self.defaultGreenColorField];
    writeConfigCmd.ledBlue = [self getUnsignedIntFromTextField:self.defaultBlueColorField];
    
    [writeConfigCmd setCompletedBlock:^(RSCmd *sourceCmd, NSError *error) {
        RSDeviceConfigViewController *strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(),^{
            [MBProgressHUD hideHUDForView:strongSelf.view animated:YES];
            if (error == nil)
            {
                [self writeMessage:[NSString stringWithFormat:@"Successfully write configuration to %@", self.device.name]];
            }
            else
            {
                [self writeMessage:[NSString stringWithFormat:@"Failed to write configuration to %@. Error: %@", self.device.name, error]];
                [self showAlertWithTitle:@"Error" message:@"Error occurred while writting device configuration. Please, try again."];
            }
        });
    }];

    [self.device runCmd:writeConfigCmd];
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
 *  Converts text from specified text field into a unsigned int value
 */
- (uint)getUnsignedIntFromTextField:(UITextField *)textField
{
    if (textField == nil || textField.text.length == 0)
    {
        return 0;
    }
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    return [numberFormatter numberFromString:textField.text].intValue;
}

@end
