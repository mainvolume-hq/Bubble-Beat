//
//  BBOptionsScrollViewController.m
//  Bubble Beat
//
//  Created by Scott McCoid on 1/18/13.
//
//

#import "BBOptionsScrollViewController.h"

@interface BBOptionsScrollViewController ()

@end

@implementation BBOptionsScrollViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	mic = 1;
    music = 0;
    [[BBAudioModel sharedAudioModel] setMicrophoneInput];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == music)
        [[BBAudioModel sharedAudioModel] setMusicInput];
    else if (sender.selectedSegmentIndex == mic)
        [[BBAudioModel sharedAudioModel] setMicrophoneInput];
}


@end
