//
//  BBMainViewController.h
//  Bubble Beat
//
//  Created by Scott McCoid on 12/4/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "BBGLKitViewController.h"

@interface BBMainViewController : UIViewController{
    
    IBOutlet UIView *scrollView;
    
}
    
@property (nonatomic,strong) UIView *optionsView;
@property (nonatomic,strong) UIView *optionsScrollView;
@property (nonatomic,strong) BBGLKitViewController *bubbleFactory;

-(IBAction) optionsButtonPressed;
-(IBAction) backButtonPressed;

@end
