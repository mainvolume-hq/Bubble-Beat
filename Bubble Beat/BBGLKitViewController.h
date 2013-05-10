//
//  BBGLKitViewController.h
//  Bubble Beat
//
//  Created by Jason Clark on 1/7/13.
//
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "TREEllipse.h"
#import "Bubble.h"

@interface BBGLKitViewController : GLKViewController <GLKViewDelegate, GLKViewControllerDelegate>{
    
    float alphaDecay;
    float radiusSwell;
    bool backgroundDirection;
    float backgroundColor;
}

@property (nonatomic,strong) NSMutableArray *bubbles;
@property (nonatomic,strong) NSMutableArray *removeBubbleArray;

-(void)makeBubbleWithSize:(float) bubbleSize andTransparency:(float)trans;

@end
