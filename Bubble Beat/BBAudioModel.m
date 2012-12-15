//
//  BBAudioModel.m
//  Bubble Beat
//
//  Created by Scott McCoid on 12/15/12.
//
//

#import "BBAudioModel.h"

@implementation BBAudioModel

#pragma mark - Audio Render Callback -
static OSStatus renderCallback(void *inRefCon,
                               AudioUnitRenderActionFlags *ioActionFlags,
                               const AudioTimeStamp *inTimeStamp,
                               UInt32 inBusNumber,
                               UInt32 inNumberFrames,
                               AudioBufferList *ioData)
{
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

    }
    
    return self;
}

@end
