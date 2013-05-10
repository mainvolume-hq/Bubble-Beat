//
//  Bubble.h
//  Bubble Beat
//
//  Created by Scott McCoid on 5/9/13.
//
//

#import <Foundation/Foundation.h>
#import "TREEllipse.h"

@interface Bubble : TREEllipse
{
    BOOL burst;                 // NO = middle vertex same color
    float burstAlpha;
    
}

@property BOOL burst;
@property float burstAlpha;

-(id)initWithColor:(GLKVector4)initColor;
-(BOOL)isInside:(GLKVector2)press;

@end
