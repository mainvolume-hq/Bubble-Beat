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
    importFlag = NO;
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
    {
        [self showMediaPicker];
        [[BBAudioModel sharedAudioModel] setMusicInput];
    }
    else if (sender.selectedSegmentIndex == mic)
        [[BBAudioModel sharedAudioModel] setMicrophoneInput];
}

#pragma mark - Song Related Methods -

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title withArtist:(NSString*)artist {
    
	//release previous
//	[outURL release];
//	//need to retain?
//	outURL = assetURL;
//	[outURL retain];
	
	[BBAudioModel sharedAudioModel].canReadMusicFile = NO;
    
	writePosition = 0;
	readPosition = 0;
	initialRead = NO;
	
	for (int i = 0; i < mediaBufferSize; ++i)
		mediaBuffer[0] = 0.0; //zero out contents of buffer
	
//	playingflag_ =1;
	
	NSOperationQueue *queue = [NSOperationQueue new];
	NSInvocationOperation *operation = [[NSInvocationOperation alloc]
										initWithTarget:self
										selector:@selector(loadAudioFile)
										object:nil];
	[queue addOperation:operation];
}

#pragma mark - Display Media Picker -

- (void)showMediaPicker {
	
	mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
	mediaPicker.delegate = self;
	[parentViewController presentViewController:mediaPicker animated:NO completion:NULL];
}

#pragma mark - Media Picking Delegate Methods -

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection
{
	//[self dismissModalViewControllerAnimated:YES];
    
	for (MPMediaItem* item in mediaItemCollection.items)
    {
		NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
		NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
		NSNumber* dur = [item valueForProperty:MPMediaItemPropertyPlaybackDuration];
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
		//[self exportAssetAtURL:assetURL withTitle:title withArtist:artist];
	}
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)inputMediaPicker
{
    [inputMediaPicker dismissViewControllerAnimated:NO completion:NULL];
}


@end
