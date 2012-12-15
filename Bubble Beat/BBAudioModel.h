//
//  BBAudioModel.h
//  Bubble Beat
//
//  author: scott
//  [sonic apps union]
//
//  description: This is a static/singleton class that deals with
//  all the audio processing in the application

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface BBAudioModel : NSObject
{
    AudioUnit bbUnit;                   // This is the actual audio unit instance variable
    
    int       blockSize;
    int       sampleRate;
}

+ (BBAudioModel *)sharedAudioModel;
- (void)setupAudioUnit;
- (void)setupAudioSession;

// TODO: make properties for set-able values (blocksize, sr, etc...)

@end
