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
		self.view.backgroundColor=[UIColor whiteColor];
        // Custom initialization
		self.title=@"Radio Dawah";
		button=[UIButton buttonWithType:UIButtonTypeRoundedRect];
		button.frame=CGRectMake(100, 100, 100, 100);
		[button addTarget:self action:@selector(playPause:) forControlEvents:UIControlEventTouchUpInside];
		
		[self.view addSubview:button];
		_playing = NO;
		
		
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
           // [self setButtonImageNamed:@"stopbutton.png"];
        } else {
            url = [[NSURL alloc] initWithString:@"http://198.105.220.12:9746/;stream.mp3&13740436417&duration=99999"];
            theItem = [AVPlayerItem playerItemWithURL:url];
			
			
            [theItem addObserver:self forKeyPath:@"status" options:0 context:nil];
            theAudio = [AVPlayer playerWithPlayerItem:theItem];
            //theAudio.delegate = self;
            
           // [self setButtonImageNamed:@"loadingbutton.png"];
        }
	}
	else
	{
        [theAudio pause];
		_playing = NO;
        //[self setButtonImageNamed:@"playbutton.png"];
	}

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (object == theItem && [keyPath isEqualToString:@"status"]) {
        if(theItem.status == AVPlayerStatusReadyToPlay) {
            [theAudio play];
            _playing = YES;
            //[self setButtonImageNamed:@"stopbutton.png"];
            [theItem removeObserver:self forKeyPath:@"status"];
			
        }
        else if(theItem.status == AVPlayerStatusFailed) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"radiomobile" message:theItem.error.description delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
           // [self setButtonImageNamed:@"playbutton.png"];
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
