//
//  BBFlipsideViewController.h
//  Bubble Beat
//
//  Created by Scott McCoid on 12/4/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BBFlipsideViewController;

@protocol BBFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(BBFlipsideViewController *)controller;
@end

@interface BBFlipsideViewController : UIViewController

@property (weak, nonatomic) id <BBFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
