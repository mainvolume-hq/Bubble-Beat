//
//  BBOptionsScrollViewController.m
//  Bubble Beat
//
//  Created by Scott McCoid on 1/18/13.
//
//

#import "BBOptionsScrollViewController.h"

#define MIC 0
#define MUSIC 1

@interface BBOptionsScrollViewController ()

@end

@implementation BBOptionsScrollViewController
@synthesize parentViewController;
@synthesize musicOptionsView;
@synthesize artistLabel;
@synthesize titleLabel;
@synthesize playPauseButton;
@synthesize restartButton;
@synthesize musicLibraryButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
//        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    playButtonState = NO;
    firstLoad = YES;
    fileFinished = YES;
    
    
    [[BBAudioModel sharedAudioModel] setMicrophoneInput];
//    [[BBAudioModel sharedAudioModel] setupMediaBuffers:mediaBuffer position:&readPosition size:mediaBufferSize];
    
    // Keep these hidden at first;
    [artistLabel setText:@""];
    [titleLabel setText:@""];
    [musicOptionsView setAlpha:0.3];
    [musicOptionsView setUserInteractionEnabled:NO];
    [playPauseButton setEnabled:NO];
    [playPauseButton setAlpha:0.3];
    [restartButton setEnabled:NO];
    [restartButton setAlpha:0.3];
    
    // Setup notification center method for changing playback parameters when app is closing
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(applicationClosing)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(mediaPickerFinished)
     name:@"mediaPickerFinished"
     object:nil ];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(songFinished)
     name:@"songFinished"
     object:nil ];
    
    // create media player object
    mediaPlayer = [[BBMediaPlayer alloc] init];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Notification Center Callbacks -
- (void)applicationClosing
{
    [playPauseButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
    [mediaPlayer reset];
    [mediaPlayer pause];            // Ideally, just pause (might need to reset also, TODO: why?)
}

// Notification center callback for when mediapicker finishes
- (void)mediaPickerFinished
{
    [artistLabel setText:mediaPlayer.artist];
    [titleLabel setText:mediaPlayer.title];
    
    if (firstLoad)
    {
        firstLoad = NO;
        [playPauseButton setEnabled:YES];
        [playPauseButton setAlpha:1];
        [restartButton setEnabled:YES];
        [restartButton setAlpha:1];
    }
}

// Once the song's over, change the image back to play, and reset the song.
- (void)songFinished
{
    [self performSelectorOnMainThread:@selector(mainThreadFinished) withObject:nil waitUntilDone:YES];
}

- (void)mainThreadFinished
{
    [playPauseButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
}

#pragma mark - Properties -
- (void)setParentViewController:(UIViewController *)newParentViewController
{
    parentViewController = newParentViewController;
    [mediaPlayer setParentViewController:parentViewController];
}

- (UIViewController *)parentViewController
{
    return parentViewController;
}

#pragma mark - Button Methods -

- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == MUSIC)
    {
        [[BBAudioModel sharedAudioModel] setMusicInput];
        [musicOptionsView setAlpha:1];
        [musicOptionsView setUserInteractionEnabled:YES];

    }
    else if (sender.selectedSegmentIndex == MIC)
    {
        [[BBAudioModel sharedAudioModel] setMicrophoneInput];
        [musicOptionsView setAlpha:0.3];
        [musicOptionsView setUserInteractionEnabled:NO];
    }
}

- (IBAction)transportButtonPressed:(UIButton *)sender
{
    int tag = sender.tag;
    
    switch (tag)
    {
        case 1:
            if (mediaPlayer.playing)
            {
                [sender setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];    // set image to play
                [mediaPlayer pause];                                                                        // set player to pause
            }
            else
            {
                [sender setImage:[UIImage imageNamed:@"pauseButton.png"] forState:UIControlStateNormal];    // set the image to pause
                [mediaPlayer play];                                                                         // start playback
                [BBAudioModel sharedAudioModel].canReadMusicFile = YES;
            }
            
            break;
        
        case 2:
            [mediaPlayer reset];
            break;
            
        default:
            break;
    }
}

// Music library pressed from UI and displays the media picker (controlled by mediaPlayer)
- (IBAction)musicLibraryPressed:(UIButton *)sender
{
    [mediaPlayer showMediaPicker];
}


@end
