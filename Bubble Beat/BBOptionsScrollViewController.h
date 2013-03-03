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

@interface BBOptionsScrollViewController : UIViewController <MPMediaPickerControllerDelegate>
{
    int mic;
    int music;

    MPMediaPickerController* mediaPicker;
    NSURL* previousSong;
    NSURL* currentSong;
    NSOperationQueue* queue;
    
    float* mediaBuffer;                     // audio buffer for the iTunes song
    int mediaBufferSize;
    int writePosition;
    int readPosition;
    
    BOOL playing;                           // YES = audio currently playing, NO = not playing
    BOOL initialRead;                       //
    BOOL loadingInBackground;               // YES = loading audio file in background, NO = yeah you get it
    BOOL importFlag;                        // YES = currently importing, NO = not importing
    BOOL earlyFinish;
    BOOL restart;
    BOOL fileSelected;
    BOOL playButtonState;                   // YES = Playing, NO = Paused
}

@property (nonatomic, weak) UIViewController* parentViewController;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *musicLibraryButton;

- (IBAction)valueChanged:(UISegmentedControl *)sender;

- (IBAction)transportButtonPressed:(UIButton *)sender;

- (IBAction)musicLibraryPressed:(UIButton *)sender;

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection;
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker;

@end
