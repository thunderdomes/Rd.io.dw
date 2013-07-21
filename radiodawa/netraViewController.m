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
#import <Social/Social.h>
@interface netraViewController ()

@end

@implementation netraViewController
@synthesize theAudio, theItem, url;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.view.backgroundColor= [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-today"]];
        // Custom initialization
		self.title=@"Radio Dawah";
		button=[UIButton buttonWithType:UIButtonTypeCustom];
		button.frame=CGRectMake(110, self.view.frame.size.height-165, 100, 100);
		button.backgroundColor=[UIColor clearColor];
		[button addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
		
		artwork=[[UIImageView alloc]init];
		artwork.layer.borderWidth=1;
		artwork.layer.borderColor=[UIColor colorWithRed:0.439 green:0.439 blue:0.439 alpha:1].CGColor;
		[artwork setImage:[UIImage imageNamed:@"artwork"]];
		artwork.layer.shadowColor = [UIColor whiteColor].CGColor;
		artwork.layer.shadowOpacity = 0.7f;
		artwork.layer.shadowOffset = CGSizeMake(10.0f, 10.0f);
		artwork.layer.shadowRadius = 5.0f;
		artwork.layer.masksToBounds = NO;
		
		UIBezierPath *path = [UIBezierPath bezierPathWithRect:artwork.bounds];
		artwork.layer.shadowPath = path.CGPath;
		
		
		if(IS_IPHONE_5)
		{
			artwork.frame=CGRectMake(20, 80, 280, 280);
		}
		else
		{
			// iphone 4 frame
			artwork.frame=CGRectMake(50, 80, 210, 210);
			
		}
		[self.view addSubview:artwork];
		
		
		
		
		
		twitter=[UIButton buttonWithType:UIButtonTypeCustom];
		twitter.frame=CGRectMake(210, self.view.frame.size.height-155, 80, 80);
		[twitter setBackgroundImage:[UIImage imageNamed:@"twitter"] forState:UIControlStateNormal];
		[twitter addTarget:self action:@selector(twitterShare) forControlEvents:UIControlEventTouchUpInside];
		facebook=[UIButton buttonWithType:UIButtonTypeCustom];
		facebook.frame=CGRectMake(30, self.view.frame.size.height-155, 80, 80);
		[facebook addTarget:self action:@selector(facebookShare) forControlEvents:UIControlEventTouchUpInside];
		[facebook setBackgroundImage:[UIImage imageNamed:@"favebook"] forState:UIControlStateNormal];
		
		//[button setBackgroundImage:[UIImage imageNamed:@"playbutton"] forState:UIControlStateNormal];
		title=[[UILabel alloc]initWithFrame:CGRectMake(0, 30, 320, 40)];
		title.text=@"Radio Dawah";
		title.font=[UIFont fontWithName:@"HelveticaNeue" size:24];
		title.textColor=[UIColor whiteColor];
		title.textAlignment=NSTextAlignmentCenter;
		title.backgroundColor=[UIColor clearColor];
		
		[self.view addSubview:button];
		[self.view addSubview:twitter];
		[self.view addSubview:facebook];
		[self.view addSubview:title];
		[self setButtonImageNamed:@"playbutton.png"];
		_playing = NO;
		volumeSlider=[[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-55, 320, 55)];
		volumeSlider.backgroundColor=[UIColor colorWithPatternImage:[UIImage imageNamed:@"volume"]];
		MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(43, 16, 230, 25)];
		UIView *a=[[UIView alloc] init];
		for (UIView *view in [volumeView subviews]) {
			if ([[[view class] description] isEqualToString:@"MPVolumeSlider"]) {
				a=view;
				[(UISlider *)a setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
				[(UISlider *)a setBackgroundColor:[UIColor clearColor]];
				[(UISlider *)a setMinimumTrackImage:[[UIImage imageNamed:@"slider"]stretchableImageWithLeftCapWidth: 8 topCapHeight: 0]  forState:UIControlStateNormal];
				[(UISlider *)a setMaximumTrackImage:[UIImage imageNamed:@"slider_"] forState:UIControlStateNormal];
			}
			
		}
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
    
	if ([imageName isEqual:@"loading"]) {
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
-(void)twitterShare{
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:@"Now Listening @RadioDawah via radio dawah for iphone"];
        [self presentViewController:tweetSheet animated:YES completion:nil];
    }
else{
}
}
-(void)facebookShare{
	if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
		SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:@"Now Listening @RadioDawah via radio dawah for iphone"];
        [self presentViewController:controller animated:YES completion:Nil];
    }

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
			[self spinButton];
           [self setButtonImageNamed:@"stopbutton.png"];
        } else {
            url = [[NSURL alloc] initWithString:@"http://198.105.220.12:9746/;stream.mp3&13740436417&duration=99999"];
            theItem = [AVPlayerItem playerItemWithURL:url];
            [theItem addObserver:self forKeyPath:@"status" options:0 context:nil];
            theAudio = [AVPlayer playerWithPlayerItem:theItem];
			[self setButtonImageNamed:@"loading"];
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
