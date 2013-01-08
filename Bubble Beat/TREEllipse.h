//
//  TREEllipse.h
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "TREShape.h"
#import <GLKit/GLKit.h>

@interface TREEllipse : TREShape
{
    float radius;
    float y_velocity;
    float x_velocity;
}

@property float radius;
@property float x_velocity, y_velocity;

@end