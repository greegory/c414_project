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
#import "CCTouchDispatcher.h"
#import "CC3World.h"
#import "CC3PerformanceStatistics.h"


@interface Cmput3DLayer (TemplateMethods)
-(void)addBackButton;
-(void)addPlusMinusButton;
-(void)initializeControls;

@property (nonatomic, readonly) Cmput3DWorld* cmputWorld;
@end

@implementation Cmput3DLayer
- (void)dealloc {
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
    
    CCMenuItem *menuItem1 = [CCMenuItemImage itemFromNormalImage:@"back_Label.png" 
                                                   selectedImage:@"back_Label_selected.png" 
                                                          target:self
                                                        selector:@selector(backToMenu:)];
    
    CCMenu *back = [CCMenu menuWithItems:menuItem1, nil];
    [back setPosition:CGPointMake(40, 460)];
    
    [self addChild:back];
}

-(void)addPlusMinusButton{
    
    CCMenuItem *menuItem2 = [CCMenuItemImage itemFromNormalImage:@"ZoomButton48x48.png" 
                                                   selectedImage:@"ZoomButton48x48.png" 
                                                          target:self
                                                        selector:@selector(increaseNodes:)];
    
    CCMenu *plus = [CCMenu menuWithItems:menuItem2, nil];
    [plus setPosition:CGPointMake(300, 460)];
    
    [self addChild:plus];
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
    [self.cmputWorld increaseNodeByOne];
}

-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    return YES;
}

-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    NSLog(@"%f, %f",location.x, location.y);
        
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
