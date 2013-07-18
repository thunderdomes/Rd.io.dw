//
//  netraViewController.m
//  radiodawa
//
//  Created by Arie on 7/18/13.
//  Copyright (c) 2013 netra. All rights reserved.
//

#import "netraViewController.h"
#import <AVFoundation/AVFoundation.h>
#include <AudioToolbox/AudioToolbox.h>
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>
@interface netraViewController ()

@end

@implementation netraViewController
@synthesize theAudio, theItem, url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.view.backgroundColor= [UIColor whiteColor];
        // Custom initialization
		self.title=@"Radio Dawah";
		button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame=CGRectMake(35, 100, 100, 100);
		button.backgroundColor=[UIColor clearColor];
		[button addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
		[button setBackgroundImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
		title=[[UILabel alloc]initWithFrame:CGRectMake(0, 30, 320, 40)];
		title.text=@"Radio Dawah";
		title.font=[UIFont fontWithName:@"AvenirNext-DemiBold" size:24];
		title.textColor=[UIColor blackColor];
		title.textAlignment=NSTextAlignmentCenter;
		title.backgroundColor=[UIColor clearColor];
		
		[self.view addSubview:button];
		[self.view addSubview:title];
		//[self setButtonImageNamed:@"playbutton.png"];
		_playing = NO;
		volumeSlider=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-44, 320, 44)];
		volumeSlider.backgroundColor=[UIColor redColor];
		MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(40, 13, 240, 20)];
		
		[volumeSlider addSubview:volumeView];
		

		[self.view addSubview:volumeSlider];
		
		
		AudioSessionInitialize(NULL, NULL, NULL, NULL);
		UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
		OSStatus err = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,
											   sizeof(sessionCategory),
											   &sessionCategory);
		AudioSessionSetActive(TRUE);
		if (err) {
			NSLog(@"AudioSessionSetProperty kAudioSessionProperty_AudioCategory failed: %ld", err);
		}

    }
    return self;
}
- (void)setButtonImageNamed:(NSString *)imageName
{
	currentImageName = imageName;
	UIImage *image = [UIImage imageNamed:imageName];
	
	[button.layer removeAllAnimations];
	[button setImage:image forState:0];
    
	if ([imageName isEqual:@"loadingbutton.png"]) {
		[self spinButton];
	}
}
- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)finished
{
	if (finished)
	{
		[self spinButton];
	}
}
- (void)spinButton
{
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	CGRect frame = [button frame];
	button.layer.anchorPoint = CGPointMake(0.5, 0.5);
	button.layer.position = CGPointMake(frame.origin.x + 0.5 * frame.size.width, frame.origin.y + 0.5 * frame.size.height);
	[CATransaction commit];
    
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanFalse forKey:kCATransactionDisableActions];
	[CATransaction setValue:[NSNumber numberWithFloat:2.0] forKey:kCATransactionAnimationDuration];
    
	CABasicAnimation *animation;
	animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
	animation.fromValue = [NSNumber numberWithFloat:0.0];
	animation.toValue = [NSNumber numberWithFloat:2 * M_PI];
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
	animation.delegate = self;
	[button.layer addAnimation:animation forKey:@"rotationAnimation"];
    
	[CATransaction commit];
}

- (void)finalize
{
    if(theAudio && _playing) {
        [theAudio stop];
    }
    if(theItem) {
        [theItem removeObserver:self forKeyPath:@"status"];
    }
    [super finalize];
}

-(void)viewWillAppear:(BOOL)animated{
	[self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}
-(void)showInfo:(id)sender{

	
}
- (void)playPause:(id)sender{
	if (!_playing)
	{
		if(theAudio) {
            [theAudio play];
            _playing = YES;
			//[self spinButton];
           //[self setButtonImageNamed:@"stopbutton.png"];
        } else {
            url = [[NSURL alloc] initWithString:@"http://198.105.220.12:9746/;stream.mp3&13740436417&duration=99999"];
            theItem = [AVPlayerItem playerItemWithURL:url];
            [theItem addObserver:self forKeyPath:@"status" options:0 context:nil];
            theAudio = [AVPlayer playerWithPlayerItem:theItem];
        }
	}
	else
	{
        [theAudio pause];
		_playing = NO;
        [self setButtonImageNamed:@"playbutton.png"];
	}

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (object == theItem && [keyPath isEqualToString:@"status"]) {
        if(theItem.status == AVPlayerStatusReadyToPlay) {
            [theAudio play];
            _playing = YES;
            [self setButtonImageNamed:@"stopbutton.png"];
            [theItem removeObserver:self forKeyPath:@"status"];
			
        }
        else if(theItem.status == AVPlayerStatusFailed) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"radiomobile" message:theItem.error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
			[self setButtonImageNamed:@"playbutton.png"];
            _playing = NO;
        }
        else if(theItem.status == AVPlayerStatusUnknown) {
            NSLog(@"unknown");
        }
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
