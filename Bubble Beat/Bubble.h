//
//  Bubble.h
//  Bubble Beat
//
//  Created by Scott McCoid on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import "TREEllipse.h"

#define POP_THRESHOLD 2

@interface Bubble : TREEllipse
{
    BOOL burst;                         // NO = middle vertex same color
    float burstAlpha;
    
    int popUpdateCounter;               // this is a counter that's used to determine if the radius should decay or increase
}

@property BOOL burst;                   // go through bursting animation
@property BOOL popped;                  // done bursting
@property float burstAlpha;

-(id)initWithColor:(GLKVector4)initColor;
-(BOOL)isInside:(GLKVector2)press;

@end
