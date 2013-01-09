//
//  BBMainViewController.m
//  Bubble Beat
//
//  Created by Scott McCoid on 12/4/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "BBMainViewController.h"

@interface BBMainViewController ()

@end


@implementation BBMainViewController
@synthesize optionsView,optionsScrollView,bubbleFactory;


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self setUpOptionsView];
    
    bubbleFactory = [[BBGLKitViewController alloc] initWithNibName:@"BBGLKitView" bundle:[NSBundle mainBundle]];
    CGRect rect = [[UIScreen mainScreen] bounds];
    [bubbleFactory.view setFrame:rect];
    [self.view insertSubview:bubbleFactory.view atIndex:0];
    
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
    
    NSArray *subviewArray = [[NSBundle mainBundle] loadNibNamed:@"OptionsScrollView" owner:self options:nil];
    optionsScrollView = [subviewArray objectAtIndex:0];
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
    CGRect frame = CGRectMake(-height/2+leftRightPadding, optionsView.frame.size.width/2, height, 10.0);
    UISlider *sizeSlider = [[UISlider alloc] initWithFrame:frame];
    [sizeSlider addTarget:self action:@selector(sizeChanged:) forControlEvents:UIControlEventValueChanged];
    [sizeSlider setBackgroundColor:[UIColor clearColor]];
    CGAffineTransform trans = CGAffineTransformMakeRotation(M_PI * -0.5);
    sizeSlider.transform = trans;
    [sizeSlider setMaximumValue:maxBubbleScale];
    [sizeSlider setMinimumValue:minBubbleScale];
    [sizeSlider setValue:defaultBubbleScale];
    [optionsView addSubview:sizeSlider];
    
    //quantity slider
    CGRect frame2 = CGRectMake(optionsView.frame.size.height-height/2-leftRightPadding, optionsView.frame.size.width/2, height, 10.0);
    UISlider *quantitySlider = [[UISlider alloc] initWithFrame:frame2];
    [quantitySlider addTarget:self action:@selector(quantityChanged:) forControlEvents:UIControlEventValueChanged];
    [quantitySlider setBackgroundColor:[UIColor clearColor]];
    quantitySlider.transform = trans;
    [sizeSlider setMaximumValue:maxUpperThreshold];
    [sizeSlider setMinimumValue:minUpperThreshold];
    [quantitySlider setValue:defaultUpperThresholdScale];
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


#pragma mark - Navigation -

-(IBAction)optionsButtonPressed{
    
    //[self animateOptionsView:YES];
    [bubbleFactory makeBubbleWithSize:20.0];
    
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
                             animations:^{[optionsView setAlpha:1.0];}
                             completion:^(BOOL finished){;}];
            break;
        }
        case FALSE: //Fade Out
        {
            [UIView animateWithDuration: 1.0
                             animations:^{[optionsView setAlpha:0.0];}
                             completion:^(BOOL finished){[optionsView setHidden:YES];}];
            break;
        }
    }
}


@end
