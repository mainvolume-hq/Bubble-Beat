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
    
    alphaDecay = 0.005;
    radiusSwell = 0.5;
    bubbles = [[NSMutableArray alloc]init];
    [self makeBubbleWithSize:20];
}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    glClearColor(0.1, 0.5, 0.5, 1);
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self updateBubbles];
 
}

-(void)glkViewControllerUpdate:(GLKViewController *)controller{
    
    
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
    float transparency = 1;
    float x_vel = 4;
    float y_vel = arc4random() % 2 - 1;
    
    TREEllipse *ellipse = [[TREEllipse alloc] init];
    [ellipse setRadius:radius];
    [ellipse setColor:GLKVector4Make(1, 1, 1, transparency)];
    [ellipse setPosition:GLKVector2Make(self.view.frame.size.height-150, self.view.frame.size.width-140)];
    //[ellipse setPosition:GLKVector2Make(100, 100)];
    ellipse.left = 0.0;
    ellipse.top = 0.0;
    ellipse.bottom = self.view.frame.size.width;
    ellipse.right = self.view.frame.size.height;
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
