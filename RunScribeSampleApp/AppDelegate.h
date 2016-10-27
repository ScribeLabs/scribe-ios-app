//
//  AppDelegate.h
//  RunScribeSampleApp
//
//  Created by Vitaliy Parashchak on 10/27/16.
//  Copyright © 2016 RunScribe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

