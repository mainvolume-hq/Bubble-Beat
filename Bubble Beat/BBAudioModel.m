//
//  BBAudioModel.m
//  Bubble Beat
//
//  author: scott
//  [sonic apps union]
//
//  description: This is a static/singleton class that deals with
//  all the audio processing in the application. 

#import "BBAudioModel.h"
#define NUM_SECONDS 8           // This is 2 * number of seconds in buffer 8 = 4 seconds of stereo audio

@implementation BBAudioModel

@synthesize blockSize;
@synthesize sampleRate;
@synthesize buffer;

#pragma mark - Audio Render Callback -
static OSStatus renderCallback(void *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData)
{
    BBAudioModel* model = (__bridge BBAudioModel*)inRefCon;
    AudioUnitRender(model->bbUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
    
    // Left channel = ioData->mBuffers[0];
    // Right channel = ioData->mBuffers[1];
    
    for (int channel = 0; channel < ioData->mNumberBuffers; channel++)
    {
        // Get reference to buffer for channel we're on
        Float32* output = (Float32 *)ioData->mBuffers[channel].mData;
        
        // Loop through the blocksize
        for (int frame = 0; frame < inNumberFrames; frame++)
        {

        }
    }
    
    return noErr;
}

#pragma mark - Audio Model Init -

+ (BBAudioModel *)sharedAudioModel
{
    static BBAudioModel *sharedAudioModel = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedAudioModel = [[BBAudioModel alloc] init];
    });
    
    return sharedAudioModel;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        sampleRate = 44100;
        blockSize = 512;
        buffer = (float *)malloc(NUM_SECONDS * sampleRate * sizeof(float));
    }
    
    return self;
}


#pragma mark - Audio Model Dealloc -
- (void)dealloc
{
    free(buffer);
}


#pragma mark - Audio Unit Setup -

- (void)setupAudioUnit
{
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    
    // Find and assign default output unit
    AudioComponent defaultOutput = AudioComponentFindNext(NULL, &defaultOutputDescription);
    NSAssert(defaultOutput, @"-- Can't find a default output. --");
    
    // Create new audio unit that we'll use for output
    OSErr err = AudioComponentInstanceNew(defaultOutput, &bbUnit);
    NSAssert1(bbUnit, @"Error creating unit: %hd", err);
    
    // Enable IO for playback
    UInt32 flag = 1;
    err = AudioUnitSetProperty(bbUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 0, &flag, sizeof(flag));
    NSAssert1(err == noErr, @"Error setting output IO", err);
    
    // Enable IO for input / recording
    UInt32 enableInput = 1;
    AudioUnitElement inputBus = 1;
    AudioUnitSetProperty(bbUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, inputBus, &enableInput, sizeof(enableInput));
    
    // set format to 32 bit, single channel, floating point, linear PCM
    const int fourBytesPerFloat = 4;
    const int eightBitsPerByte = 8;
    
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate =       44100;
    streamFormat.mFormatID =         kAudioFormatLinearPCM;
    streamFormat.mFormatFlags =      kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved;
    streamFormat.mBytesPerPacket =   fourBytesPerFloat;
    streamFormat.mFramesPerPacket =  1;
    streamFormat.mBytesPerFrame =    fourBytesPerFloat;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mBitsPerChannel =   fourBytesPerFloat * eightBitsPerByte;
    
    // set format for output (bus 0)
    err = AudioUnitSetProperty(bbUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &streamFormat, sizeof(AudioStreamBasicDescription));
    
    // set format for input (bus 1) 
    err = AudioUnitSetProperty(bbUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &streamFormat, sizeof(AudioStreamBasicDescription));
    NSAssert1(err == noErr, @"Error setting stream format: %hd", err);
    
    // Output
    // Setup rendering function on the unit
    AURenderCallbackStruct input;
    input.inputProc = renderCallback;
    input.inputProcRefCon = (__bridge void *)self;
    
    // This sets the audio unit render callback
    err = AudioUnitSetProperty(bbUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Global, 0, &input, sizeof(input));
    NSAssert1(err == noErr, @"Error setting callback: %hd", err);
    
    // Input
    // Setup audio input handling function
    // AUInputSample
    
}

- (void)setupAudioSession
{
    OSStatus status;
    Float32 bufferDuration = (blockSize + 0.5) / sampleRate;           // add 0.5 to blockSize, need to so bufferDuration is correct value
    UInt32 category = kAudioSessionCategory_PlayAndRecord;
    
    status = AudioSessionInitialize(NULL, NULL, NULL, (__bridge void *)self);
    status = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
    status = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(sampleRate), &sampleRate);
    status = AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(bufferDuration), &bufferDuration);
    
    // TODO: Check where this should be set-able
    status = AudioSessionSetActive(true);
    
    //--------- Check everything
    Float64 audioSessionProperty64 = 0;
    Float32 audioSessionProperty32 = 0;
    UInt32 audioSessionPropertySize64 = sizeof(audioSessionProperty64);
    UInt32 audioSessionPropertySize32 = sizeof(audioSessionProperty32);
    
    status = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, &audioSessionPropertySize64, &audioSessionProperty64);
    NSLog(@"AudioSession === CurrentHardwareSampleRate: %.0fHz", audioSessionProperty64);
    
    sampleRate = audioSessionProperty64;
    
    status = AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, &audioSessionPropertySize32, &audioSessionProperty32);
    int blockSizeCheck = lrint(audioSessionProperty32 * audioSessionProperty64);
    NSLog(@"AudioSession === CurrentHardwareIOBufferDuration: %3.2fms", audioSessionProperty32 * 1000.0f);
    NSLog(@"AudioSession === block size: %i", blockSizeCheck);
    
}

- (void)setMicrophoneInput
{
    inputType = YES;
}

- (void)setMusicInput
{
    inputType = NO;
}

- (void)startAudioSession
{
    AudioSessionSetActive(true);
    
    // Start playback
    OSErr err = AudioOutputUnitStart(bbUnit);
    NSAssert1(err == noErr, @"Error starting unit: %hd", err);
}

- (void)startAudioUnit
{
    OSErr err = AudioUnitInitialize(bbUnit);
    NSAssert1(err == noErr, @"Error initializing unit: %hd", err);
}

@end
