//
//  Cmput3DLayer.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "Cmput3DLayer.h"
#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"
#import "CC3World.h"
#import "CC3PerformanceStatistics.h"


@interface Cmput3DLayer (TemplateMethods)
-(void)addBackButton;
-(void)addPlusMinusButton;
-(void)addSlider;
-(void)initializeControls;

@property (nonatomic, readonly) Cmput3DWorld* cmputWorld;
@end

@implementation Cmput3DLayer
- (void)dealloc {
    backButton = nil;
    plusButton = nil;
    lowButton = nil;
    medButton = nil;
    highButton = nil;
    [super dealloc];
}

/**
 * Returns the contained CC3World, cast into the appropriate type.
 * This is a convenience method to perform automatic casting when using custom
 * methods
 */
-(Cmput3DWorld*) cmputWorld {
	return (Cmput3DWorld*) cc3World;
}

-(void)addBackButton{
    
    backButton = [CCMenuItemImage itemFromNormalImage:@"back_Label.png" 
                                        selectedImage:@"back_Label_selected.png" 
                                               target:self
                                            selector:@selector(backToMenu:)];
    
    CCMenu *back = [CCMenu menuWithItems:backButton, nil];
    [back setPosition:CGPointMake(40, 460)];
    
    [self addChild:back];
}

-(void)addPlusMinusButton{
    
    plusButton = [CCMenuItemImage itemFromNormalImage:@"ZoomButton48x48.png" 
                                        selectedImage:@"ZoomButton48x48.png" 
                                               target:self
                                             selector:@selector(increaseNodes:)];
    
    CCMenu *plus = [CCMenu menuWithItems:plusButton, nil];
    [plus setPosition:CGPointMake(300, 460)];
    
    [self addChild:plus];
}

-(void)addSlider {
    lowButton = [CCMenuItemImage itemFromNormalImage:@"Icon-Small.png" 
                                       selectedImage:@"Icon-Small-50.png" 
                                              target:self 
                                            selector:@selector(slideLow:)];
    
    
    medButton = [CCMenuItemImage itemFromNormalImage:@"Icon-Small.png"
                                       selectedImage:@"Icon-Small-50.png"
                                              target:self 
                                            selector:@selector(slideMed:)];
    
    highButton = [CCMenuItemImage itemFromNormalImage:@"Icon-Small.png"
                                        selectedImage:@"Icon-Small-50.png"
                                               target:self 
                                             selector:@selector(slideHigh:)];
    
    CCMenu *slide = [CCMenu menuWithItems: nil];
    [slide addChild:lowButton z:0 tag:11];
    [slide addChild:medButton z:0 tag:22];
    [slide addChild:highButton z:0 tag:33];
    
    [slide setPosition:CGPointMake(160, 20)];
    [slide alignItemsHorizontallyWithPadding:100];
    
    [self addChild:slide];
    
}
/**
 * Template method that is invoked automatically during initialization, regardless
 * of the actual init* method that was invoked. Subclasses can override to set up their
 * 2D controls and other initial state without having to override all of the possible
 * superclass init methods.
 *
 * The default implementation does nothing. It is not necessary to invoke the
 * superclass implementation when overriding in a subclass.
 */
-(void) initializeControls {

    [self addBackButton];   
    [self addPlusMinusButton];
    [self addSlider];
    self.isTouchEnabled = YES;
}


-(void)registerWithTouchDispatcher{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

-(void) backToMenu: (CCMenuItem*) menuItem {
    
    [[CCDirector sharedDirector] replaceScene:
        [CCTransitionFade transitionWithDuration:0.5f scene:[Cmput3DMenuLayer scene]]];
    
    NSLog(@"the back button was seleceted");
}

-(void)increaseNodes: (CCMenuItem*) menuItem{
    NSLog(@"Add Node");
   [self.cmputWorld increaseNodeByOne: CGPointMake(0.0, 0.0)];
}

-(void)slideLow: (CCMenuItem*) menuItem {
    NSLog(@"LOW");
}

-(void)slideMed: (CCMenuItem*) menuItem {
    NSLog(@"MEDIUM");
}

-(void)slideHigh: (CCMenuItem*) menuItem {
    NSLog(@"HIGH");
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    [self.cmputWorld increaseNodeByOne: location];
   // NSLog(@"%f, %f",location.x, location.y);
        
}
 // The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 // The event dispatcher will not dispatch events for which there is no method
 // implementation. Since the touch-move events are both voluminous and seldom used,
 // the implementation of ccTouchMoved:withEvent: has been left out of the default
 // CC3Layer implementation. To receive and handle touch-move events for object
 // picking,uncomment the following method implementation. To receive touch events,
 // you must also set the isTouchEnabled property of this instance to YES.
/*
 // Handles intermediate finger-moved touch events. 
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}
*/
@end
