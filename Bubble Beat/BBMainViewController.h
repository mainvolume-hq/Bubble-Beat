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

@interface BBMainViewController : UIViewController{
    
    IBOutlet UIView *scrollView;
    IBOutlet UIButton *optionsButton;
    BBAudioModel* audioModel;
    UIImageView *splashView;
}
    
@property (nonatomic,strong) UIView *optionsView;
@property (nonatomic,strong) UIView *optionsScrollView;
@property (nonatomic,strong) UIImageView *splashView;
@property (nonatomic,strong) BBGLKitViewController *bubbleFactory;
@property (nonatomic,strong) BBOptionsScrollViewController* optionsScrollViewController;

-(IBAction) optionsButtonPressed;
-(IBAction) backButtonPressed;
-(IBAction) bubbleButtonPressed;

@end
