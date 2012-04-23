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
	[layer addChild:labelLayer];
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void) dealloc{
    [super dealloc];
    
    menuButton = nil;
    resultsButton = nil;
    labelLayer = nil;
    
    [selectionTracker release];
    [complexityTracker release];
    [depthTracker release];
}

-(void) initializeControls
{
    windowSize = (CGSize)[[CCDirector sharedDirector] winSize];        
    
    labelLayer = [[CCLayer alloc] init];
    
    [self addBackButton];
    [self addLabels];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                     priority:0
                                              swallowsTouches:YES];

}

-(void) initWithResults: (NSMutableArray*) selectionTrack 
                  depth: (NSMutableArray*) depthTrack
                   name: (NSMutableArray*) complexityTrack{

    self.selectionTracker = selectionTrack;
    self.depthTracker = depthTrack;
    self.complexityTracker = complexityTrack;
    
    [self results];
    
}

-(void)addLabels{
    CCLabelBMFont *label;
    CGFloat x = 0.00, y = 260;
    CGFloat y_pos = 0.0;
    
    for (int i = 0; i < TEST_LENGTH; ++i) {
        
        label = [self addStatsLabel:@"" tag:i];
        
        label.position = ccp(x, y + y_pos);
        [label setColor: ccYELLOW];
        [label setScale:0.9];
        
        if (i == 14){
            x = windowSize.width/2;
            y = 260;
            y_pos = 0.0;
        }
        else
            y_pos -= 20;
    }
}

// Creates a label to be used for statistics, adds it as a child, and returns it.
-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText tag: (uint) aTag{
    CCLabelBMFont* aLabel = [CCLabelBMFont labelWithString: labelText fntFile:@"arial-16.fnt"];
	[aLabel setAnchorPoint: ccp(0.0, 0.0)];
	[labelLayer addChild: aLabel z:0 tag:aTag];
	return aLabel;
}

// Add several labels that display performance statistics.
-(void) results {
	CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
	[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA4444];
	
    NSString *sLabel;
        
    for (int i = 0; i < TEST_LENGTH; ++i) {
        sLabel = [[NSString alloc] init];
        //sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"%i.", i]];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"%@ ", [complexityTracker objectAtIndex:i]]];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Answer:%@ ", [selectionTracker objectAtIndex:i]]];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Depth:%@", [depthTracker objectAtIndex:i]]];
        LogInfo(@"%@", sLabel);
        [(CCLabelBMFont*)[labelLayer getChildByTag:i] setString:sLabel];
        
        [sLabel release];
    }
    
	[CCTexture2D setDefaultAlphaPixelFormat: currentFormat];

}

-(void)showResults{
    
    for (int i = 0; i < TEST_LENGTH; ++i) {
       
        LogInfo(@"%@, Answer: %@ Depth: %@\n\n",
                [complexityTracker objectAtIndex: i],
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
    
    menuButton = [CCMenuItemImage itemFromNormalImage:@"back_Label_selected.png" 
                                        selectedImage:@"back_Label.png" 
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
