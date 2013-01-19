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
@synthesize parentViewController;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        queue = [[NSOperationQueue alloc] init];
    }
    return self;
}

- (void)dealloc
{
    free(mediaBuffer);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mediaBufferSize = 44100 * 8;
    mediaBuffer = (float *)malloc(mediaBufferSize * sizeof(float));
    
	mic = 1;
    music = 0;
    importFlag = NO;
    playing = NO;
    loadingInBackground = NO;
    initialRead = NO;
    earlyFinish = NO;
    
    writePosition = 0;
    readPosition = 0;
    
    [[BBAudioModel sharedAudioModel] setMicrophoneInput];
    [[BBAudioModel sharedAudioModel] setupMediaBuffers:mediaBuffer position:&readPosition size:mediaBufferSize];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)valueChanged:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == music)
    {
        [self pickSong];
        [[BBAudioModel sharedAudioModel] setMusicInput];
    }
    else if (sender.selectedSegmentIndex == mic)
    {
        [[BBAudioModel sharedAudioModel] setMicrophoneInput];
    }
}

#pragma mark - Song Related Methods -

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title withArtist:(NSString*)artist
{    
    currentSong = assetURL;
	
	[BBAudioModel sharedAudioModel].canReadMusicFile = NO;
    
	writePosition = 0;
	readPosition = 0;
	initialRead = NO;
	
	for (int i = 0; i < mediaBufferSize; ++i)
		mediaBuffer[0] = 0.0; //zero out contents of buffer
	
	playing = YES;
	NSInvocationOperation *operation = [[NSInvocationOperation alloc]
										initWithTarget:self
										selector:@selector(loadAudioFile)
										object:nil];
	[queue addOperation:operation];
}

- (void)audioFileProblem
{
    NSAssert(NO, @"There was a problem");
}

- (void)loadAudioFile
{
	
	loadingInBackground = YES;
	
	//http://developer.apple.com/library/ios/#documentation/AudioVideo/Conceptual/AVFoundationPG/Articles/05_MediaRepresentations.html
	NSDictionary* options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
	
	AVURLAsset* asset = [AVURLAsset URLAssetWithURL:currentSong options:options];
	
	NSError *error = nil;
	AVAssetReader* filereader= [AVAssetReader assetReaderWithAsset:(AVAsset *)asset error:&error];
    
	if (error == nil)
    {
        @autoreleasepool
        {
		
            //http://objective-audio.jp/2010/09/avassetreaderavassetwriter.html
            NSDictionary *audioSetting = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithFloat:44100.0],AVSampleRateKey,
									  [NSNumber numberWithInt:2],AVNumberOfChannelsKey,
									  [NSNumber numberWithInt:32],AVLinearPCMBitDepthKey,
									  [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
									  [NSNumber numberWithBool:YES], AVLinearPCMIsFloatKey,
									  [NSNumber numberWithBool:0], AVLinearPCMIsBigEndianKey,
									  [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
									  [NSData data], AVChannelLayoutKey, nil];
		
		
            //should only be one track anyway
            AVAssetReaderAudioMixOutput* readAudioFile = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:(asset.tracks) audioSettings:audioSetting];
		
            if ([filereader canAddOutput:(AVAssetReaderOutput *)readAudioFile] == NO)
                [self audioFileProblem];
		
            [filereader addOutput:(AVAssetReaderOutput *)readAudioFile];
            
            if ([filereader startReading] == NO)
                [self audioFileProblem];
		
            importFlag = NO;
		
            //take large chunks of data at a time
            //http://osdir.com/ml/coreaudio-api/2009-10/msg00030.html
            BOOL finished = NO;
		
            // Iteratively read data from the input file and write to output
            for(;;)
            {
                if(earlyFinish == YES)
                {
                    earlyFinish = NO;
                    break;
                }
                if (restart == YES)
                {
                    [BBAudioModel sharedAudioModel].canReadMusicFile = NO;
                    initialRead = NO;
				
                    //a lot of repeat to code to restart: should really encapsulate in a class
                    [filereader cancelReading];
                    filereader = [AVAssetReader assetReaderWithAsset:(AVAsset *)asset error:&error];
				
                    if (error != nil)
                        [self audioFileProblem];
				
                    readAudioFile = [AVAssetReaderAudioMixOutput assetReaderAudioMixOutputWithAudioTracks:(asset.tracks) audioSettings:audioSetting];
				
                    if ([filereader canAddOutput:(AVAssetReaderOutput *)readAudioFile] == NO)
                        [self audioFileProblem];
				
                    [filereader addOutput:(AVAssetReaderOutput *)readAudioFile];
				
                    if ([filereader startReading] == NO)
                        [self audioFileProblem];
				
                    restart = NO;
                    finished = NO;
				
                    //thread safety
                    writePosition = (readPosition + 1024) % mediaBufferSize;
                }
			
                int readTest = readPosition;
			
                //test where readpos_ is; while within 2 seconds (half of buffer) must continue to fill up
                // god, this is an ugly expression
                int diff = readTest <= writePosition?(writePosition - readTest):(writePosition +mediaBufferSize - readTest);
			
                if ((diff < (mediaBufferSize / 2)) && (finished == NO))
                {
                    CMSampleBufferRef ref = [readAudioFile copyNextSampleBuffer];
                    if (ref != NULL)
                    {
                        //finished?
                        if (CMSampleBufferDataIsReady(ref) == NO)
                            [self audioFileProblem];
					
                        CMItemCount countsamp= CMSampleBufferGetNumSamples(ref);
                        UInt32 frameCount = countsamp;

                        CMBlockBufferRef blockBuffer;
                        AudioBufferList audioBufferList;
					
                        //allocates new buffer memory
                        CMSampleBufferGetAudioBufferListWithRetainedBlockBuffer(ref, NULL, &audioBufferList, sizeof(audioBufferList),NULL, NULL, 0, &blockBuffer);
					
                        float* buffer = (float *)audioBufferList.mBuffers[0].mData;
					
                        for (int i = 0; i < 2*frameCount; ++i)
                        {
                            mediaBuffer[writePosition] = buffer[i];
                            writePosition = (writePosition + 1) % mediaBufferSize;
                        }
					
                        CFRelease(ref);
                        CFRelease(blockBuffer);
					
                        // If no frames were returned, conversion is finished
                        if(frameCount == 0)
                            finished = YES;
                    }
                    else
                    {
                        finished = YES;
                    }
				
                }
                else
                {
                    if (!initialRead)
                    {
                        initialRead = YES;
                        [BBAudioModel sharedAudioModel].canReadMusicFile = YES;
                    }
                    else
                    {
                        usleep(100); //1000 = 1 msec
                    }
				
                }
            }
        }
			
		//any cleanup?
		//for later, to tell main thread done...?
		//performSelectorOnMainThread
		[filereader cancelReading];
		loadingInBackground = NO;
		
		return;
    }
	
}


#pragma mark - Display Media Picker -

- (void)showMediaPicker {
	
	mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	mediaPicker.delegate = self;
    [mediaPicker setAllowsPickingMultipleItems:NO];
	[parentViewController presentViewController:mediaPicker animated:YES completion:NULL];
}

- (void)pickSong
{
    if (importFlag == NO)
    {
        importFlag = YES;
        [self freeAudio];
        [self showMediaPicker];
    }
}

- (void)freeAudio
{
    if (playing == YES)
    {
        [[BBAudioModel sharedAudioModel] setCanReadMusicFile:NO];
        playing = NO;
    }
    //stop background loading thread
	if(loadingInBackground == YES)
		earlyFinish = YES;
	
	while(loadingInBackground == YES)
	{
		usleep(5000); //wait for file thread to finish
	}
}

#pragma mark - Media Picking Delegate Methods -

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
	for (MPMediaItem* item in mediaItemCollection.items)
    {
		NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
		NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
		//NSNumber* dur = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
		//NSTimeInterval is a double
		
        //duration_ = [dur doubleValue];
		
		//MPMediaItemPropertyArtist
		NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
		if (nil == assetURL) {
			/**
			 * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
			 * in question is protected by DRM. (old m4p files)
			 */
			return;
		}
        
		[self exportAssetAtURL:assetURL withTitle:title withArtist:artist];
	}
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)inputMediaPicker
{
    [inputMediaPicker dismissViewControllerAnimated:YES completion:NULL];
}


@end
