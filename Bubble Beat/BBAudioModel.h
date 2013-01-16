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
#import "fft.h"
#import "bark.h"
#import "peak_picker.h"

@interface BBAudioModel : NSObject
{
    AudioUnit bbUnit;                   // This is the actual audio unit instance variable
    
    int       blockSize;
    int       sampleRate;
    int       hopSize;
    int       windowSize;
    
    float*    monoAnalysisBuffer;       // mono signal that we do analysis on
    float*    musicLibraryBuffer;       // An intermediate buffer for audio content from music library
    BOOL      inputType;                // YES = Microphone, NO = Music
    
    FFT*       fft;
    FFT_FRAME* fftFrame;
    
    BARK*     bark;
    PEAK_PICKER* peak_picker;
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
@property float* musicLibraryBuffer;

@end

// C Functions
static float outerEarFilter(float input);
static float middleEarFilter(float input);
