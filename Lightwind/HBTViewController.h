//
//  HBTViewController.h
//  Lightwind
//
//  Created by Beroš Jurica on 11/8/11.
//  Copyright (c) 2011 Habitatus. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

@interface HBTViewController : UIViewController {
	AVAudioRecorder *recorder;
	NSTimer *levelTimer;
	double highPassResults;
}

@property (weak, nonatomic) IBOutlet UIButton *lightButton;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *buttonBack;
@property (strong, nonatomic) IBOutlet UIView *settingsView;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

- (IBAction)changedSoundActivation:(id)sender;

- (IBAction)switchView:(id)sender;
- (IBAction)switchBack:(id)sender;

- (IBAction)buttonPressed:(id)sender;
- (IBAction)buttonReleased:(id)sender;

- (void)lightOn:(NSNotification *)notification;
- (void)lightOff:(NSNotification *)notification;

- (void)resetListener;
- (void)levelTimerCallback:(NSTimer *)timer;

@end
