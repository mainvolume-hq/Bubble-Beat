//
//  BBMainViewController.h
//  Bubble Beat
//
//  Created by Scott McCoid on 12/4/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//


@interface BBMainViewController : UIViewController{
    
    IBOutlet UIView *scrollView;
    
}
    
@property (nonatomic,retain) UIView *optionsView;
@property (nonatomic,retain) UIView *optionsScrollView;
    

-(IBAction) optionsButtonPressed;
-(IBAction) backButtonPressed;

@end
