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
    BOOL importFlag;                        // YES = currently importing, NO = not importing
    MPMediaPickerController* mediaPicker;
    NSURL* previousSong;
    NSURL* currentSong;
    
    float* mediaBuffer;                     // audio buffer for the iTunes song
    int mediaBufferSize;
    int writePosition;
    int readPosition;
    
    BOOL playing;                           // YES = audio currently playing, NO = not playing
    BOOL initialRead;                       // 
}

@property (nonatomic, weak) UIViewController* parentViewController;

- (IBAction)valueChanged:(UISegmentedControl *)sender;

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection;
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker;

@end
