//
//  Bubble.m
//  Bubble Beat
//
//  Created by Scott McCoid on 5/9/13.
//
//

#import "Bubble.h"

@implementation Bubble

@synthesize burst;
@synthesize burstAlpha;
@synthesize popped;

-(id)initWithColor:(GLKVector4)initColor
{
    self = [super init];
    if (self)
    {
        burst = NO;
        popped = NO;
        burstAlpha = 1.0;
        
        [self setUseConstantColor:NO];
        [self setColor:initColor];
        
        position = GLKVector2Make(0,0);
        scale = GLKVector2Make(1.0, 1.0);
        depth = 0.0;
        
        popUpdateCounter = 0;

    }
    return self;
}

-(void)setColor:(GLKVector4)_color
{
    if (burst)
    {
        burstAlpha -= 0.18;
        self.vertexColors[0] = GLKVector4Make(_color.r, _color.g,_color.b, burstAlpha);
        for (int i = 1; i < self.numVertices; i++)
        {
            self.vertexColors[i] = GLKVector4Make(_color.r, _color.g,_color.b, burstAlpha + 0.3);
        }
    }
    else
    {
        //self.vertexColors[0] = GLKVector4Make(_color.r, _color.g,_color.b, _color.a);
        for (int i = 0; i < self.numVertices; i++)
        {
            self.vertexColors[i] = _color;
        }
    }
    
    color = _color;
}

-(GLKVector4)color
{
    return color;
}

-(void)setRadius:(float)_radius
{
    if (burst)
    {
        if (popUpdateCounter < POP_THRESHOLD)
        {
            [super setRadius:_radius * 0.8];
        }
        else
        {
            [super setRadius:_radius * 1.1];
        }
        
        popUpdateCounter++;
        
        if (popUpdateCounter > POP_THRESHOLD + 2)
        {
            popped = YES;
        }
        
    }
    else
    {
        [super setRadius:_radius];
    }
}

-(float)radius
{
    return super.radius;
}


-(void)setBurst:(BOOL)_burst
{
    if (!burst)
    {
        burstAlpha = color.a;
    }
    burst = _burst;
}

-(BOOL)burst
{
    return burst;
}

- (BOOL)isInside:(GLKVector2)press
{
    // TODO: only check x?
    GLKVector2 canonicalPosition = self.position;
    if (self.position.x <= 0.0)
    {
        float diffFromThresh = 0.0 - canonicalPosition.x;
        canonicalPosition.x = self.position.x + diffFromThresh;
        //press.x = press.x + diffFromThresh;
    }
    else
    {
        canonicalPosition = self.position;
    }
    
    GLKVector2 difference = GLKVector2Subtract(canonicalPosition, press);
    float distance = sqrt(GLKVector2DotProduct(difference, difference));
    
    if (distance < radius + 2.0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

@end
