//
//  Cmput3DMenuLayer.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "Cmput3DMenuLayer.h"
#import "Cmput3DLayer.h"
#import "Cmput3DWorld.h"
#import "CCTouchDispatcher.h"
#import "ccTypes.h"

#import "Cmput3DLayer.h"
#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"
#import "CCTouchDispatcher.h"
#import "CC3World.h"

#import "CC3ActionInterval.h"
#import "CC3MeshNode.h"
#import "CC3PODResourceNode.h"
#import "CC3ParametricMeshNodes.h"


@interface Cmput3DMenuLayer (TemplateMethods)
-(void)initializeControls;

@end
@implementation Cmput3DMenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Cmput3DMenuLayer *layer = [Cmput3DMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

-(void)setUpMenus{
    CCMenuItem *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"circle_Label.png" 
                                                   selectedImage:@"circle_Label_selected.png" 
                                                          target:self
                                                        selector:@selector(worldWithCircle:)];
    
    CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"square_Label.png"
                                                   selectedImage: @"square_Label_selected.png"
                                                          target:self
                                                        selector:@selector(worldWithSquare:)];
    
    
	CCMenuItemImage * menuItem3 = [CCMenuItemImage itemFromNormalImage:@"complex_Label.png"
                                                         selectedImage: @"complex_Label_selected.png"
                                                                target:self
                                                              selector:@selector(worldWithComplex:)];
    
    // Create a menu and add menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
    
	// Arrange the menu items vertically
	[myMenu alignItemsVertically];
    
	// add the menu to the scene
	[self addChild:myMenu];
}

// on "init" you need to initialize instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(150, 108, 227, 255)])) {
        
		[self initializeControls];
        [self setUpMenus];
        // register to receive targeted touch events
        [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                         priority:0
                                                  swallowsTouches:YES];
        
	}
	return self;
}

//
//-(BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
//    return YES;
//}
//
//-(void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
//    
//}

-(void)registerWithTouchDispatcher{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}


//Creates the Layer and World where the 3D rendering will be done and calls
//the director to set it
-(void) worldWith: (NSString*) kname{
    
    int idx = 0;
    if (kname == kDieCubeName)
        idx = 2;
    else if (kname == kBoxName)
        idx = 1;
        
    
    CC3Layer* cc3Layer = [Cmput3DLayer layerWithColor: ccc4(100, 120, 220, 255)];
	[cc3Layer scheduleUpdate];
	
	// Create the customized 3D world, attach it to the layer, and start it playing.
    Cmput3DWorld *cWorld = [Cmput3DWorld world];
    
	cc3Layer.cc3World = cWorld;
    [cWorld setSelectedObject:idx];
    
	ControllableCCLayer* mainLayer = cc3Layer;
    
    CCScene *scene = [CCScene node];
	[scene addChild: mainLayer];
    
	[[CCDirector sharedDirector] replaceScene: 
        [CCTransitionFade transitionWithDuration:0.5f scene: scene]];
}


//Menu items
- (void) worldWithCircle: (CCMenuItem  *) menuItem {
    
    [self worldWith:kBeachBallName];
	NSLog(@"The Circle menu was called");
}

- (void) worldWithSquare: (CCMenuItem  *) menuItem {
    [self worldWith:kBoxName];
	NSLog(@"The Square menu was called");
}

- (void) worldWithComplex: (CCMenuItem  *) menuItem {
    [self worldWith:kDieCubeName];
	NSLog(@"The Complex menu was called");
}

-(void)dealloc{
    [super dealloc];
}

@end
