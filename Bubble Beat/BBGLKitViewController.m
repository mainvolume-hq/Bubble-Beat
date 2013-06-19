//
//  BBGLKitViewController.m
//  Bubble Beat
//
//  Created by Jason Clark on 1/7/13.
//
//

#import "BBGLKitViewController.h"
#import "BBAudioModel.h"

#define biggestBubble 200
#define smallestBubble 3

@interface BBGLKitViewController ()

@property (strong, nonatomic) EAGLContext* context;

@end

@implementation BBGLKitViewController
@synthesize context = _context;
@synthesize bubbles;
@synthesize removeBubbleArray;


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
    radiusSwell = 1.01;
    bubbles = [[NSMutableArray alloc]init];
    removeBubbleArray = [[NSMutableArray alloc] init];
    [self.view setFrame:[[UIScreen mainScreen] bounds]];
    
    backgroundColor = arc4random_uniform(1000)/1000.0f;
    backgroundDirection = TRUE;

}

-(void)glkView:(GLKView *)view drawInRect:(CGRect)rect{
    
    glClear(GL_COLOR_BUFFER_BIT);
    [bubbles makeObjectsPerformSelector:@selector(render)];
 
}

-(void)glkViewControllerUpdate:(GLKViewController *)controller
{
    
}

- (void)update
{
    [self updateBackground];
    [self updateBubbles];
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

-(void)updateBubbles
{    
    for(int i = 0; i < [bubbles count]; i++)
    {
        Bubble *bubble = [bubbles objectAtIndex:i];
        
        if (bubble.position.x <= (0.0 - bubble.radius) || bubble.color.a <= 0.0 || bubble.popped == YES)
        {
            [removeBubbleArray addObject:bubble];
        }
        else
        {
            [bubble setPosition:GLKVector2Make(bubble.position.x - bubble.x_velocity, bubble.position.y - bubble.y_velocity)];
            [bubble setColor:GLKVector4Make(bubble.color.r, bubble.color.g, bubble.color.b, bubble.color.a - alphaDecay)];
            //[bubble setColor:GLKVector4Make(bubble.color.r, bubble.color.g, bubble.color.b, bubble.color.a)];
            [bubble setRadius:bubble.radius*radiusSwell];
        }
    }
    
    for (Bubble* index in removeBubbleArray)
    {
        [bubbles removeObject:index];
    }
    
    if ([removeBubbleArray count] > 0)
        [removeBubbleArray removeAllObjects];
}


-(void)makeBubbleWithSize:(float) bubbleSize andTransparency:(float) trans{
    
    float radius = bubbleSize;
    if (radius<smallestBubble) radius=smallestBubble;
    if (radius>biggestBubble) radius = biggestBubble;
    float transparency = trans;
    if (transparency > 1) transparency = 1;
    float x_vel = 8 + arc4random_uniform(100)/500.0f - 1;
    float y_vel = arc4random_uniform(1000)/125.0f - 2;
    
    UIColor *color = [UIColor colorWithHue:arc4random_uniform(1000)/1000.f saturation:1 brightness:1 alpha:1];
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha = 0.0;
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    Bubble* newBubble = [[Bubble alloc] initWithColor:GLKVector4Make(red, green, blue, transparency)];
    [newBubble setUseConstantColor:NO];
    [newBubble setRadius:radius];
    [newBubble setPosition:GLKVector2Make([[UIScreen mainScreen] bounds].size.height - 115 - radius, [[UIScreen mainScreen] bounds].size.width - 140)];
    
    newBubble.left = 0;
    newBubble.top = 0;
    newBubble.bottom = [[UIScreen mainScreen] bounds].size.width;
    newBubble.right = [[UIScreen mainScreen] bounds].size.height;

    [newBubble setX_velocity:x_vel];
    [newBubble setY_velocity:y_vel];
    
    [bubbles addObject:newBubble];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Touch Callbacks -


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet* beginTouches = [event allTouches];
    for (UITouch* touch in beginTouches)
    {
        CGPoint touchLocation = [touch locationInView:self.view];
        GLKVector2 press = GLKVector2Make(touchLocation.x, touchLocation.y);
        
        // need to get the top bubble, which is the last rendered one obviously
        for (int b = bubbles.count - 1; b >= 0; b--)
        {
            if ([bubbles[b] isInside:press])
            {
                [bubbles[b] setBurst:YES];
                break;
            }
        }
    }
}


@end
