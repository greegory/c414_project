//
//  Cmput3DMenuLayer.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright 2012 Greg Jaciuk . All rights reserved.
//

#import "Cmput3DMenuLayer.h"
#import "Cmput3DResultsLayer.h"

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
    CGSize window = (CGSize)[[CCDirector sharedDirector] winSize];
    
//    CCMenuItem *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"circle_Label.png" 
//                                                   selectedImage:@"circle_Label_selected.png" 
//                                                          target:self
//                                                        selector:@selector(worldWithCircle:)];
//    
//    CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"square_Label.png"
//                                                   selectedImage: @"square_Label_selected.png"
//                                                          target:self
//                                                        selector:@selector(worldWithSquare:)];
//    
//    
//	CCMenuItemImage * menuItem3 = [CCMenuItemImage itemFromNormalImage:@"complex_Label.png"
//                                                         selectedImage: @"complex_Label_selected.png"
//                                                                target:self
//                                                              selector:@selector(worldWithComplex:)];
    
    CCMenuItem *menuItem1 = [CCMenuItemFont itemFromString:@"Bunny" 
                                                    target:self 
                                                  selector:@selector(worldWithBeachBall:)];
    
    CCMenuItem *menuItem2 = [CCMenuItemFont itemFromString:@"Budda" 
                                                    target:self 
                                                  selector:@selector(worldWithBuddha:)];
    
    CCMenuItem *menuItem3 = [CCMenuItemFont itemFromString:@"Dinosaur" 
                                                    target:self 
                                                  selector:@selector(worldWithDieCube:)];
    
    // Create a menu and add menu items to it
	CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, nil];
    
	// Arrange the menu items vertically
	[myMenu alignItemsVertically];
    
    [myMenu setPosition: CGPointMake(window.width/2, window.height/2)];
    
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
    
    if (kname == kDinoName0)
        idx = 2;
    else if (kname == kBuddhaName0)
        idx = 1;
    else
        idx = 0;
        
    
    Cmput3DLayer* myLayer = [Cmput3DLayer layerWithColor: ccc4(100, 120, 220, 255)];
	[myLayer scheduleUpdate];
	
    Cmput3DWorld *cWorld = [Cmput3DWorld world];
    
	myLayer.cc3World = cWorld;
    [cWorld setSelectedObject:idx];
    
    CCScene *scene = [CCScene node];
	[scene addChild: myLayer];
    
	[[CCDirector sharedDirector] replaceScene: 
        [CCTransitionFade transitionWithDuration:0.5f scene: scene] ];
    
}


//Menu items
- (void) worldWithBeachBall: (CCMenuItem  *) menuItem {
	LogInfo(@"The Bunny menu was called");    
    [self worldWith:kBunnyName3];
}

- (void) worldWithBuddha: (CCMenuItem  *) menuItem {
	LogInfo(@"The Buddha menu was called");
    [self worldWith:kBuddhaName0];
}

- (void) worldWithDieCube: (CCMenuItem  *) menuItem {
    LogInfo(@"The Dinosaur menu was called");
    [self worldWith:kDinoName0];
}

-(void)dealloc{
    [super dealloc];
}

@end
