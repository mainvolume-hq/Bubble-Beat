//
//  TREEllipse.m
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "TREEllipse.h"

#define EE_ELLIPSE_RESOLUTION 64
#define M_TAU (2*M_PI)

@implementation TREEllipse
@synthesize x_velocity,y_velocity;

-(int)numVertices 
{
    return EE_ELLIPSE_RESOLUTION;
}

-(void)updateVertices 
{
    for (int i = 0; i < EE_ELLIPSE_RESOLUTION; i++)
    {
        float theta = ((float)i) / EE_ELLIPSE_RESOLUTION * M_TAU;
        self.vertices[i] = GLKVector2Make(cos(theta) * radius, sin(theta) * radius);
    }
}

-(float)radius 
{
    return radius;
}

-(void)setRadius:(float)_radius
{
    radius = _radius;
    [self updateVertices];
}

@end
