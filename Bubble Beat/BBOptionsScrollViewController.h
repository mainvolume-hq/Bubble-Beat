//
//  BBOptionsScrollViewController.h
//  Bubble Beat
//
//  Created by Scott McCoid on 1/18/13.
//
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "BBAudioModel.h"
#import "BBMainViewController.h"
#import "BBMediaPlayer.h"

@interface BBOptionsScrollViewController : UIViewController
{
    BBMediaPlayer* mediaPlayer;
    
    BOOL playButtonState;                   // YES = Playing, NO = Paused
    BOOL firstLoad;
    BOOL fileFinished;                      // YES = file reached end of playback, NO = file has not reached end
}

@property (nonatomic, weak) UIViewController* parentViewController;
@property (weak, nonatomic) IBOutlet UIView *musicOptionsView;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *musicLibraryButton;

- (IBAction)valueChanged:(UISegmentedControl *)sender;
- (IBAction)transportButtonPressed:(UIButton *)sender;
- (IBAction)musicLibraryPressed:(UIButton *)sender;

@end
