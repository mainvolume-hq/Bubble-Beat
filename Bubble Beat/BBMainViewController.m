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

@interface BBMainViewController ()

@end


@implementation BBMainViewController
@synthesize optionsView,optionsScrollView,bubbleFactory,splashView;
@synthesize optionsScrollViewController;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setUpOptionsView];
    
    bubbleFactory = [[BBGLKitViewController alloc] initWithNibName:@"BBGLKitView" bundle:[NSBundle mainBundle]];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [bubbleFactory.view setFrame:rect];
    [self.view insertSubview:bubbleFactory.view atIndex:0];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(eventHandler:)
     name:@"onsetDetected"
     object:nil ];
    
    audioModel = [[BBAudioModel alloc] init];
    [audioModel setupAudioSession];
    [audioModel setupAudioUnit];
    [audioModel startAudioUnit];
    [audioModel startAudioSession];
    
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
    [self setUpScrollView];
    [self.view addSubview:optionsView];
    
}

-(void)setUpScrollView{
    
//    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"OptionsScrollView" owner:self options:nil];
//    optionsScrollView = [subviewArray objectAtIndex:0];
    
    optionsScrollViewController = [[BBOptionsScrollViewController alloc] initWithNibName:@"OptionsScrollView" bundle:[NSBundle mainBundle]];
    optionsScrollView = optionsScrollViewController.view;
    CGRect rect = CGRectMake(0, 0, scrollView.frame.size.width, scrollView.frame.size.height);
    [optionsScrollView setFrame:rect];
    [scrollView addSubview:optionsScrollView];
    
}

-(void)setUpSliders{
    
    //-- Default and max/min values --//
    float defaultBubbleScale = 0.5;
    float defaultUpperThresholdScale = 0.5;
    float maxBubbleScale = 1;
    float minBubbleScale = 0;
    float maxUpperThreshold = 1;
    float minUpperThreshold = 0;
    
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
    [sizeSlider setValue:defaultBubbleScale];
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
    float newBubbleSizeScale = tempSlider.value;
    //use newBubbleSizeScale to set the new bubble scaling factor
    
    //supress the unused warning for now
    #pragma unused(newBubbleSizeScale)
    
}

-(void)quantityChanged:(id) sender{
    UISlider *tempSlider = sender;
    float newUpperThresholdScale = tempSlider.value;
    //use newUpperThresholdScale to scale the upper threshold
    
    //supress the unused warning for now
    #pragma unused(newUpperThresholdScale)
    
}

-(IBAction)bubbleButtonPressed{
    
    [bubbleFactory makeBubbleWithSize:20.0];
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

-(void)eventHandler: (NSNotification *) notification
{
    [bubbleFactory makeBubbleWithSize:20];
}


@end
