//
//  TREEllipse.m
//  TRE
//
//  Created by Scott McCoid on 10/11/12.
//  Copyright (c) 2012 Georgia Institute of Technology. All rights reserved.
//

#import "TREEllipse.h"

#define EE_ELLIPSE_RESOLUTION 65
#define M_TAU (2*M_PI)

@implementation TREEllipse
@synthesize x_velocity,y_velocity;

-(int)numVertices 
{
    return EE_ELLIPSE_RESOLUTION;
}

-(void)updateVertices 
{
    self.vertices[0] = GLKVector2Make(0, 0);
    
    for (int i = 1; i < EE_ELLIPSE_RESOLUTION; i++)
    {
        float theta = ((float)i) / (EE_ELLIPSE_RESOLUTION - 2) * M_TAU;
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
