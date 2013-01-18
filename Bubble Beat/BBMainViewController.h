//
//  BBMainViewController.h
//  Bubble Beat
//
//  Created by Scott McCoid on 12/4/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "BBGLKitViewController.h"
#import "BBAudioModel.h"
#import "BBOptionsScrollViewController.h"

@class BBOptionsScrollViewController;
@interface BBMainViewController : UIViewController{
    
    IBOutlet UIView *scrollView;
    IBOutlet UIButton *optionsButton;
    BBAudioModel* audioModel;
    UIImageView *splashView;
}

@property (nonatomic,strong) BBOptionsScrollViewController* optionsScrollViewController;
@property (nonatomic,strong) UIView *optionsView;
@property (nonatomic,strong) UIView *optionsScrollView;
@property (nonatomic,strong) UIImageView *splashView;
@property (nonatomic,strong) BBGLKitViewController *bubbleFactory;

-(IBAction) optionsButtonPressed;
-(IBAction) backButtonPressed;
-(IBAction) bubbleButtonPressed;

@end
