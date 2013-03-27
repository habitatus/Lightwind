//
//  HBTAppDelegate.m
//  Lightwind
//
//  Created by Beroš Jurica on 8/29/11.
//  Copyright (c) 2011 Habitatus. All rights reserved.
//

#import "HBTAppDelegate.h"

#import "HBTViewController.h"

@implementation HBTAppDelegate
@synthesize AVSession;
@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
		
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
        if ([device hasTorch] && [device hasFlash]){
			
            if (device.torchMode == AVCaptureTorchModeOff) {
				
                AVCaptureDeviceInput *flashInput = [AVCaptureDeviceInput deviceInputWithDevice:device error: nil];
                AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
				
                AVCaptureSession *session = [[AVCaptureSession alloc] init];
				
				[session beginConfiguration];
                [device lockForConfiguration:nil];
				
                [session addInput:flashInput];
                [session addOutput:output];
				
                [device unlockForConfiguration];
				
				[session commitConfiguration];
				[session startRunning];
				
				dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(queue, ^{
					[self setAVSession:session];
				});
			}	
        }	
    }
	//[self toggleFlashlight:YES];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	[UIApplication sharedApplication].statusBarHidden = YES;
	self.viewController = [[HBTViewController alloc] initWithNibName:@"HBTViewController" bundle:nil];
	self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didTouch:) name:kNotificationMainButton object:nil];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	[self toggleFlashlight:NO];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
	[self toggleFlashlight:NO];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	[self toggleFlashlight:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	//[self toggleFlashlight];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	[self.AVSession stopRunning];
	self.AVSession = nil;
}


- (void)toggleFlashlight:(BOOL)state {
	Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
	if (captureDeviceClass != nil) {
		AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		[device lockForConfiguration:nil];
		
		if(state) {
			[device setTorchMode:AVCaptureTorchModeOn];
			[device setFlashMode:AVCaptureFlashModeOn];
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightOn object:self];
		} else {
			[device setTorchMode:AVCaptureTorchModeOff];
			[device setFlashMode:AVCaptureFlashModeOff];		
			[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLightOff object:self];
		}
		[device unlockForConfiguration];
		
		flashlightOn = state;
	}
}

- (void)didTouch:(NSNotification *)notification {
	[self toggleFlashlight:!flashlightOn];
}

@end
