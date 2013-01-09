//
//  BBGLKitViewController.m
//  Bubble Beat
//
//  Created by Jason Clark on 1/7/13.
//
//

#import "BBGLKitViewController.h"


@interface BBGLKitViewController ()

@property (strong, nonatomic) EAGLContext* context;

@end

@implementation BBGLKitViewController
@synthesize context = _context;
@synthesize bubbles;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setFrame: super.view.frame];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!self.context)
        NSLog(@"Failed to create ES context.");
    
    GLKView* view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.multipleTouchEnabled = YES;
    
    alphaDecay = 0.008;
    radiusSwell = 0.75;
    bubbles = [[NSMutableArray alloc]init];
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    backgroundColor = arc4random_uniform(1000)/1000.0f;
    backgroundDirection = TRUE;

}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    [self updateBackground];
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self updateBubbles];

 
}

-(void)glkViewControllerUpdate:(GLKViewController *)controller{
    
    
}

-(void)updateBackground{
    
    if (backgroundColor >= 1) {
        backgroundDirection = FALSE;
    }
    else if (backgroundColor <= 0){
        backgroundDirection = TRUE;
    }
    
    backgroundColor += backgroundDirection ? 0.001 : -0.001;
    UIColor *color = [UIColor colorWithHue:backgroundColor saturation:0.15 brightness:1 alpha:1];
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];

    glClearColor(red, green, blue, 1);
}

-(void)updateBubbles{
    
    for(int i=0;i<[bubbles count];i++){
        TREEllipse *bubble = [bubbles objectAtIndex:i];
        
        if (bubble.position.x<0-bubble.radius | bubble.color.a <0)
        {[bubbles removeObjectAtIndex:i];
        }
        else{
        [bubble setPosition:GLKVector2Make(bubble.position.x - bubble.x_velocity, bubble.position.y - bubble.y_velocity)];
        [bubble setColor:GLKVector4Make(bubble.color.r, bubble.color.g, bubble.color.b, bubble.color.a - alphaDecay)];
        [bubble setRadius:bubble.radius+radiusSwell];
        [bubble render];
        }
    }
    
    
}

-(void)makeBubbleWithSize:(float) bubbleSize{
    
    float radius = bubbleSize;
    float transparency = 0.75;
    float x_vel = 8;
    float y_vel = arc4random_uniform(1000)/125.0f - 2;
    
    UIColor *color = [UIColor colorWithHue:arc4random_uniform(1000)/1000.f saturation:1 brightness:1 alpha:1];
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    TREEllipse *ellipse = [[TREEllipse alloc] init];
    [ellipse setRadius:radius];
    [ellipse setColor:GLKVector4Make(red, green, blue, transparency)];
    [ellipse setPosition:GLKVector2Make([[UIScreen mainScreen] bounds].size.height - 115 - radius, [[UIScreen mainScreen] bounds].size.width - 140)];
    ellipse.left = 0;
    ellipse.top = 0;
    ellipse.bottom = [[UIScreen mainScreen] bounds].size.width;
    ellipse.right = [[UIScreen mainScreen] bounds].size.height;
    
    [ellipse setDrawingStyle:GL_TRIANGLE_FAN];
    [ellipse setX_velocity:x_vel];
    [ellipse setY_velocity:y_vel];
     
    [bubbles addObject:ellipse];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
