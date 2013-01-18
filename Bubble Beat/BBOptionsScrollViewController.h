//
//  BBOptionsScrollViewController.h
//  Bubble Beat
//
//  Created by Scott McCoid on 1/18/13.
//
//

#import <UIKit/UIKit.h>
#import "BBAudioModel.h"

@interface BBOptionsScrollViewController : UIViewController
{
    int mic;
    int music; 
}

- (IBAction)valueChanged:(UISegmentedControl *)sender;

@end
