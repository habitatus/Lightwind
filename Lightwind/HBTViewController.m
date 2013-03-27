//
//  HBTViewController.m
//  Lightwind
//
//  Created by Beroš Jurica on 11/8/11.
//  Copyright (c) 2011 Habitatus. All rights reserved.
//

#import "HBTViewController.h"

#define kSettingShouldListen @"ShouldListen"

@implementation HBTViewController
@synthesize lightButton;
@synthesize backgroundView;
@synthesize buttonBack;
@synthesize settingsView;
@synthesize switchButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lightOn:) name:kNotificationLightOn object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lightOff:) name:kNotificationLightOff object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self resetListener];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[recorder stop];
	if(levelTimer) {
		[levelTimer invalidate];
	}
}

- (void)viewDidUnload
{
	[self setLightButton:nil];
	[self setBackgroundView:nil];
	[self setButtonBack:nil];
	[self setSettingsView:nil];
	[self setSwitchButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)changedSoundActivation:(id)sender {
	BOOL newState = switchButton.on;;
	
	[[NSUserDefaults standardUserDefaults] setBool:newState forKey:kSettingShouldListen];
}

- (IBAction)switchView:(id)sender {
	switchButton.on = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingShouldListen];
	
	[UIView transitionFromView:self.view 
						toView:settingsView 
					  duration:0.7 
					   options:UIViewAnimationOptionTransitionFlipFromRight
					completion:^(BOOL finished){
						
					}];
}

- (IBAction)switchBack:(id)sender {
	[UIView transitionFromView:settingsView 
						toView:self.view 
					  duration:0.7 
					   options:UIViewAnimationOptionTransitionFlipFromLeft
					completion:^(BOOL finished){
						//[self resetListener];
					}];
}

- (IBAction)buttonPressed:(id)sender {
}

- (IBAction)buttonReleased:(id)sender {
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMainButton object:self];
}


- (void)lightOn:(NSNotification *)notification {
	[lightButton setImage:[UIImage imageNamed:@"ButtonOn.png"] forState:UIControlStateNormal];
	
	[UIView animateWithDuration:0.2 
					 animations:^{
						 backgroundView.alpha = 0.0f;
						 lightButton.alpha = 0.1f;
						 buttonBack.alpha = 1.0f;
					 }];
}
- (void)lightOff:(NSNotification *)notification {
	[lightButton setImage:[UIImage imageNamed:@"ButtonNormal.png"] forState:UIControlStateNormal];	
	[UIView animateWithDuration:0.2 
					 animations:^{
						 backgroundView.alpha = 1.0f;
						 lightButton.alpha = 1.0f;
						 buttonBack.alpha = 0.0f;
					 }];
}


- (void)resetListener {
	
	if(levelTimer) 
		[levelTimer invalidate];
	
	if(recorder)
		[recorder stop];
	
	BOOL shouldListen = [[NSUserDefaults standardUserDefaults] boolForKey:kSettingShouldListen];
	if(shouldListen) {

		NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
		NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
								  [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
								  [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
								  [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
								  [NSNumber numberWithInt: AVAudioQualityMedium],      AVEncoderAudioQualityKey,
								  nil];
		
		NSError *error;
		recorder = [[AVAudioRecorder alloc] initWithURL:url settings:settings error:&error];
		
		if (recorder) {
			[recorder prepareToRecord];
			recorder.meteringEnabled = YES;
			[recorder record];
			highPassResults = 0.0f;
			levelTimer = [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(levelTimerCallback:) userInfo: nil repeats: YES];
		} else
			NSLog(@"Recorder error: %@", [error description]);
	}
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
	
	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
	const double ALPHA = 0.02f;
	const double DELTA = 0.75f;

	highPassResults = (1.0f - ALPHA) * highPassResults;

	//NSLog(@"Peak: %f, Low pass result: %f", peakPowerForChannel, lowPassResults);
	if(peakPowerForChannel - DELTA > highPassResults) {
		[self buttonReleased:nil];
		//NSLog(@"High pass result: %f", highPassResults);
		highPassResults = peakPowerForChannel;
	}
}

@end
