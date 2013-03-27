//
//  HBTAppDelegate.h
//  Lightwind
//
//  Created by Beroš Jurica on 8/29/11.
//  Copyright (c) 2011 Habitatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class HBTViewController;

@interface HBTAppDelegate : UIResponder <UIApplicationDelegate> {
	BOOL flashlightOn;
}

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) HBTViewController *viewController;

@property (nonatomic, retain) AVCaptureSession *AVSession;

- (void)toggleFlashlight:(BOOL)state;
- (void)didTouch:(NSNotification *)notification;

@end
