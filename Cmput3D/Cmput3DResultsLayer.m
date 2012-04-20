//
//  Cmput3DResultsLayer.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-04-17.
//  Copyright 2012  Greg Jaciuk. All rights reserved.
//

#import "Cmput3DResultsLayer.h"
#import "Cmput3DLayer.h"
#import "Cmput3DMenuLayer.h"
#import "CCLabelBMFont.h"

@implementation Cmput3DResultsLayer

@synthesize selectionTracker;
@synthesize depthTracker;
@synthesize complexityTracker;


-(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Cmput3DResultsLayer *layer = [Cmput3DResultsLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) dealloc{
    [super dealloc];
    
    menuButton = nil;
    resultsButton = nil;
    
    [selectionTracker release];
    [complexityTracker release];
    [depthTracker release];
}

-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(150, 108, 227, 255)])) {
        windowSize = (CGSize)[[CCDirector sharedDirector] winSize];
        
        [self addBackButton];
        [self getResultsButton];
        [self results];
        
        // register to receive targeted touch events
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                         priority:0
                                                  swallowsTouches:YES];
        
	}
	return self;
}

-(Cmput3DResultsLayer*) initWithResults: (NSMutableArray*) selectionTrack 
                                  depth: (NSMutableArray*) depthTrack
                                   name: (NSMutableArray*) complexityTrack{
    
    //if( (self=[super initWithColor:ccc4(150, 108, 227, 255)])) {
        self.selectionTracker = [[selectionTrack copy] retain];
        self.depthTracker = [[depthTrack copy] retain];
        self.complexityTracker = [[complexityTrack copy] retain];
        
    //}
    for (int i = 0; i < TEST_LENGTH; ++i) {
        LogInfo(@"%@, Answer: %@ Depth: %@\n\n",
                [self.complexityTracker objectAtIndex: i],
                [self.selectionTracker objectAtIndex: i], 
                [self.depthTracker objectAtIndex: i]);
    }
    return self;
}

// Creates a label to be used for statistics, adds it as a child, and returns it.
-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText {
	CCLabelBMFont* aLabel = [CCLabelBMFont labelWithString: labelText fntFile:@"arial16.fnt"];
	[aLabel setAnchorPoint: ccp(0.0, 0.0)];
	[self addChild: aLabel];
	return aLabel;
}

// Add several labels that display performance statistics.
-(void) results {
	CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
	[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA4444];
	
    CCLabelBMFont *label;
    NSString *sLabel;
    
    CGFloat x = -0.05, y = -0.0;
    CGFloat x_pos = 0.0, y_pos = -12.4;
    
    for (int i = 0; i < /*TEST_LENGTH*/30; ++i) {
        
        sLabel = [[NSString alloc] init];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"%d. ", i]];
        sLabel = [sLabel stringByAppendingString:@"buddha "];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Answer: %d ", i]];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Depth: %d", i]];
        
        label = [self addStatsLabel: sLabel];
        label.anchorPoint = ccp(x + x_pos, y + y_pos);
        [label setColor: ccYELLOW];
        
        if (i == 14){
            x_pos = -1.1;
            y_pos = -12.4;
        }
        else
            y_pos += 0.8;
        
        [sLabel release];
    }
    
	[CCTexture2D setDefaultAlphaPixelFormat: currentFormat];
}

-(void)showResults: (CCMenuItem*) menuItem{
    
    //uint x = 0, y = 0;
    
    for (int i = 0; i < TEST_LENGTH; ++i) {
//        nameLabel = [CCLabelBMFont labelWithString:@"[complexityTracker objectAtIndex:0]" 
//                                           fntFile:@"arial16.fnt"];
//        resultLabel = [CCLabelBMFont labelWithString:@"[selectionTracker objectAtIndex:i]" 
//                                             fntFile:@"arial16.fnt"];
//        depthLabel = [CCLabelBMFont labelWithString:@"[depthTracker objectAtIndex:i]" 
//                                            fntFile:@"arial16.fnt"];
//            
//        [nameLabel setAnchorPoint:ccp(windowSize.width/2,windowSize.height/2)];
//        [resultLabel setAnchorPoint:ccp(x+10,y)];
//        [depthLabel setAnchorPoint:ccp(x+20,y)];
//
//        [self addChild:nameLabel];
//        [self addChild:resultLabel];
//        [self addChild:depthLabel];
//        
//        x += 20;
//        y += 20;
        LogInfo(@"%@, Answer: %@ Depth: %@\n\n",[complexityTracker objectAtIndex: i],
                                                [selectionTracker objectAtIndex: i], 
                                                [depthTracker objectAtIndex: i]);

    }
    
}
-(void)getResultsButton{
    resultsButton = [CCMenuItemImage itemFromNormalImage:@"back_Label.png" 
                                        selectedImage:@"back_Label_selected.png" 
                                               target:self
                                             selector:@selector(showResults:)];
    
    CCMenu *menu = [CCMenu menuWithItems:resultsButton, nil];
    [menu setPosition:CGPointMake(windowSize.width-(windowSize.width-BTN_OFFSET_LEFT), 
                                  windowSize.height-BTN_OFFSET_TOP -30)];
    
    [self addChild:menu];
}

-(void)addBackButton{
    
    menuButton = [CCMenuItemImage itemFromNormalImage:@"back_Label.png" 
                                        selectedImage:@"back_Label_selected.png" 
                                               target:self
                                             selector:@selector(backToMenu:)];
    
    CCMenu *menu = [CCMenu menuWithItems:menuButton, nil];
    [menu setPosition:CGPointMake(windowSize.width-(windowSize.width-BTN_OFFSET_LEFT), 
                                  windowSize.height-BTN_OFFSET_TOP)];
    
    [self addChild:menu];
}

-(void)backToMenu: (CCMenuItem*) menuItem{
    LogInfo(@"Selected Menu Button");
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionFade transitionWithDuration:0.5f scene:[Cmput3DMenuLayer scene]]];
}

@end
