//
//  BBMainViewController.m
//  Bubble Beat
//
//  Created by Scott McCoid on 12/4/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "BBMainViewController.h"
#import "BBAudioModel.h"
#import "MySlider.h"


//#define defaultUpperThresholdScale 0.18 //make sure this is the same as the one in peak_picker.c
//#define maxBubbleScale 3
//#define minBubbleScale 0.05
//#define maxUpperThreshold 0.3
//#define minUpperThreshold 0.001

// Threshold contstants
#define defaultUpperThresholdScale 0.3 //make sure this is the same as the one in peak_picker.c
#define maxUpperThreshold 0.75
#define minUpperThreshold 0.0001

// Bubble scale constants
#define maxBubbleScale 3
#define minBubbleScale 0.05
#define bubbleSizeScaleDefault 1.5

@interface BBMainViewController () {
    float bubbleSizeScale;
    bool firstLoad;
    float upperThreshold;
    
    
}

@end


@implementation BBMainViewController
@synthesize optionsView,optionsScrollView,bubbleFactory,splashView;
@synthesize optionsScrollViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    firstLoad = YES;
    [self setUpOptionsView];
    
    bubbleFactory = [[BBGLKitViewController alloc] initWithNibName:@"BBGLKitView" bundle:[NSBundle mainBundle]];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [bubbleFactory.view setFrame:rect];
    [self.view insertSubview:bubbleFactory.view atIndex:0];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(onsetDetected:)
     name:@"onsetDetected"
     object:nil ];
    
    [[BBAudioModel sharedAudioModel] setupAudioSession];
    [[BBAudioModel sharedAudioModel] setupAudioUnit];
    [[BBAudioModel sharedAudioModel] startAudioUnit];
    [[BBAudioModel sharedAudioModel] startAudioSession];
    
    upperThreshold = defaultUpperThresholdScale;
    
    [self animateSplashScreens];
    
}

-(void)animateSplashScreens{
    
    int device = 0;
    
    // 1 = low res iphone / ipod
    // 2 = retina iphone
    // 3 = iphone 5
    
    int deviceHeight = [[UIScreen mainScreen]bounds].size.height;
    if (deviceHeight == 480) {
        
        if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] == YES && [[UIScreen mainScreen] scale] == 2.00) {
            // RETINA DISPLAY
            device = 2;
        }
        else device = 1;
    }
    else if (deviceHeight == 568){
        device = 3;
    }
    
    switch (device) {
        case 1:
            splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 480, 320)];
            [splashView setImage:[UIImage imageNamed:@"Splash2_3G.png"]];
            break;
        case 2:
            splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 480, 320)];
            [splashView setImage:[UIImage imageNamed:@"Splash2_4.png"]];
            break;
        case 3:
            splashView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 568, 320)];
            [splashView setImage:[UIImage imageNamed:@"Splash2_5.png"]];
            break;
        default:
            break;
    }
    
    [self.view addSubview:splashView];
    [self.view bringSubviewToFront:splashView];
    
    [UIView animateWithDuration: 2.0
                          delay: 2.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{[splashView setAlpha:0.0];}
                     completion:^(BOOL finished){
                         [splashView setHidden:YES];
                         ;
                     }];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - Options View Methods -

-(void)setUpOptionsView{
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"OptionsView" owner:self options:nil];
    optionsView = [subviewArray objectAtIndex:0];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [optionsView setFrame:rect];
    [optionsView setAlpha:0];
    [optionsView setHidden:YES];
    
    [self setUpSliders];
    [self.view addSubview:optionsView];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:NO];
    if (firstLoad) {
        firstLoad = NO;
    [self setUpScrollView];
    }
}

-(void)setUpScrollView{
    
    optionsScrollViewController = [[BBOptionsScrollViewController alloc] initWithNibName:@"OptionsScrollView" bundle:[NSBundle mainBundle]];
    optionsScrollView = optionsScrollViewController.view;
    CGRect rect = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [optionsScrollView setFrame:rect];
    [scrollView addSubview:optionsScrollView];
    [optionsScrollViewController setParentViewController:self];
    
}

-(void)setUpSliders{
    
    //-- Default and max/min values --//
    bubbleSizeScale = bubbleSizeScaleDefault;
    
    //-- Layout -//
    float upperLowerPadding = 50; //pixels either side
    float leftRightPadding = 50; //pixels to edge
    
    float height = optionsView.frame.size.width-2*upperLowerPadding;
    
    //size slider
    CGRect frame = CGRectMake(-height/2+leftRightPadding, optionsView.frame.size.width/2+20, height, 10.0);
    MySlider *sizeSlider = [[MySlider alloc] initWithFrame:frame];
    [sizeSlider addTarget:self action:@selector(sizeChanged:) forControlEvents:UIControlEventValueChanged];
    [sizeSlider setBackgroundColor:[UIColor clearColor]];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
    sizeSlider.transform = trans;
    [sizeSlider setMaximumValue:maxBubbleScale];
    [sizeSlider setMinimumValue:minBubbleScale];
    [sizeSlider setValue:bubbleSizeScale];
    [sizeSlider setThumbImage: [UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [sizeSlider setThumbImage: [UIImage imageNamed:@"thumb.png"] forState:UIControlStateHighlighted];
    [sizeSlider setMinimumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateNormal];
    [sizeSlider setMinimumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateHighlighted];
    [sizeSlider setMaximumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateNormal];
    [sizeSlider setMaximumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateHighlighted];
    [optionsView addSubview:sizeSlider];
    
    //quantity slider
    CGRect frame2 = CGRectMake(optionsView.frame.size.height-height/2-leftRightPadding, optionsView.frame.size.width/2+20, height, 10.0);
    MySlider *quantitySlider = [[MySlider alloc] initWithFrame:frame2];
    [quantitySlider addTarget:self action:@selector(quantityChanged:) forControlEvents:UIControlEventValueChanged];
    [quantitySlider setBackgroundColor:[UIColor clearColor]];
    quantitySlider.transform = trans;
    [quantitySlider setMaximumValue:maxUpperThreshold];
    [quantitySlider setMinimumValue:minUpperThreshold];
    [quantitySlider setValue:defaultUpperThresholdScale];
    [quantitySlider setThumbImage: [UIImage imageNamed:@"thumb.png"] forState:UIControlStateNormal];
    [quantitySlider setThumbImage: [UIImage imageNamed:@"thumb.png"] forState:UIControlStateHighlighted];
    [quantitySlider setMinimumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateNormal];
    [quantitySlider setMinimumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateHighlighted];
    [quantitySlider setMaximumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateNormal];
    [quantitySlider setMaximumTrackImage:[UIImage imageNamed:@"track.png"] forState:UIControlStateHighlighted];
    
    [optionsView addSubview:quantitySlider];
    
}

-(void)sizeChanged:(id) sender{
    UISlider *tempSlider = sender;
    bubbleSizeScale = tempSlider.value;
}

-(void)quantityChanged:(id) sender{
    UISlider *tempSlider = sender;
    upperThreshold = maxUpperThreshold + minUpperThreshold - tempSlider.value;
    NSNumber *newUpperThresholdScale = [NSNumber numberWithFloat:maxUpperThreshold + minUpperThreshold - tempSlider.value];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"upper_threshold"
     object:newUpperThresholdScale];
    
    //NSLog(@"Slider: %f, Threshold: %f", tempSlider.value, upperThreshold);
    
}

-(IBAction)bubbleButtonPressed{
    
    //[bubbleFactory makeBubbleWithSize:20.0];
    //[bubbleFactory MakeBubbleBackground];
}


#pragma mark - Navigation -

-(IBAction)optionsButtonPressed{
    
    [self animateOptionsView:YES];
    
}

-(IBAction)backButtonPressed{
 
    [self animateOptionsView:NO];
    
}

-(void)animateOptionsView:(bool)inTRUEoutFALSE{
    
    switch ([[NSNumber numberWithBool:inTRUEoutFALSE] integerValue]) {
        case TRUE: //Fade In
        {
            [optionsView setHidden:NO];
            [UIView animateWithDuration: 1.0
                             animations:^{[optionsView setAlpha:1.0];
                                 [optionsButton setAlpha:0.0];}
                             completion:^(BOOL finished){
                                 ;}];
            break;
        }
        case FALSE: //Fade Out
        {
            [UIView animateWithDuration: 1.0
                             animations:^{[optionsView setAlpha:0.0];
                                 [optionsButton setAlpha:0.3];}
                             completion:^(BOOL finished){[optionsView setHidden:YES];
                                 ;
                             }];
            break;
        }
    }
}

-(void)onsetDetected: (NSNotification *) notification
{
    float salience = [[[notification userInfo]valueForKey:@"salience"]floatValue];    
    //float size = powf(((salience * bubbleSizeScale) + 2), 2.0);
    float size = powf(salience, bubbleSizeScale) * 15 + 5;

    
    float transparency = ((salience-1) - upperThreshold)*3;
    
    [bubbleFactory makeBubbleWithSize:size andTransparency:transparency];
    
}


@end
