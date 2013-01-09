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
    
    float*    buffer;
    BOOL      inputType;                // YES = Microphone, NO = Music
}

+ (BBAudioModel *)sharedAudioModel;
- (void)setupAudioUnit;
- (void)startAudioUnit;

- (void)setupAudioSession;
- (void)startAudioSession;

- (void)setMicrophoneInput;
- (void)setMusicInput;

@property int blockSize;
@property int sampleRate;
@property float* buffer;

@end
