//
//  Cmput3DLayer.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk  2012. All rights reserved.
//

#import "Cmput3DLayer.h"
#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"

@interface Cmput3DLayer (TemplateMethods)
-(void)addBackButton;
-(void)addPlusMinusButton;
-(void)addDecisionButtons;
-(void)initializeControls;
-(BOOL) handleTouch: (UITouch*) touch ofType: (uint) touchType;

@property (nonatomic, readonly) Cmput3DWorld* cmputWorld;

@end

@implementation Cmput3DLayer
- (void)dealloc {    
    [super dealloc];
    
    backButton = nil;
    plusButton = nil;
    leftButton = nil;
    rightButton = nil;
}

-(void) initializeControls {
    
    windowSize = (CGSize)[[CCDirector sharedDirector] winSize];
    
    [self addBackButton];   
    // [self addPlusMinusButton];
    [self addDecisionButtons];
    self.isTouchEnabled = YES;
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
    [back setPosition:CGPointMake(windowSize.width-(windowSize.width-BTN_OFFSET_LEFT), 
                                  windowSize.height-BTN_OFFSET_TOP)];
    
    [self addChild:back];
}

-(void)addPlusMinusButton{
    
    plusButton = [CCMenuItemImage itemFromNormalImage:@"ZoomButton48x48.png" 
                                        selectedImage:@"ZoomButton48x48.png" 
                                               target:self
                                             selector:@selector(increaseNodes:)];
    
    CCMenu *plus = [CCMenu menuWithItems:plusButton, nil];
    [plus setPosition:CGPointMake(windowSize.width-BTN_OFFSET_TOP, windowSize.height-BTN_OFFSET_TOP)];
    
    [self addChild:plus];
}

-(void)addDecisionButtons {
    
    leftButton = [CCMenuItemFont itemFromString:@"LEFT"
                                        target:self 
                                      selector:@selector(chooseLeft:)];
    
    
    rightButton = [CCMenuItemFont itemFromString:@"RIGHT"
                                         target:self
                                       selector:@selector(chooseRight:)];
    
    
    CCMenu *slide = [CCMenu menuWithItems: nil];
    [slide addChild:leftButton z:0 tag:11];
    [slide addChild:rightButton z:0 tag:33];
    
    [slide setPosition:CGPointMake(windowSize.width/2, 20)];
    [slide alignItemsHorizontallyWithPadding:100];
    
    [self addChild:slide];
    
}

-(void) backToMenu: (CCMenuItem*) menuItem {
    
    [[CCDirector sharedDirector] replaceScene:
        [CCTransitionFade transitionWithDuration:0.5f scene:[Cmput3DMenuLayer scene]]];
    
    LogInfo(@"the back button was selected");
}

-(void)increaseNodes: (CCMenuItem*) menuItem{
    LogInfo(@"Add Node");
   //[self.cmputWorld increaseNodeByOne: CGPointMake(0.0, 0.0)];
}

/*
 *Menu times for the user selection
 */
-(void)chooseLeft: (CCMenuItem*) menuItem {
    
    LogInfo(@"LEFT CHOICE");
    [self.cmputWorld calculateGameLogic: LEFT_NODE];
    [self.cmputWorld nextRound];
}


-(void)chooseRight: (CCMenuItem*) menuItem {
    
    LogInfo(@"RIGHT CHOICE");
    [self.cmputWorld calculateGameLogic: RIGHT_NODE];
    [self.cmputWorld nextRound];
}


//-(BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
//    return YES;
//}
//
//-(void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
//    CGPoint location = [self convertTouchToNodeSpace:touch];
//    
//    [self.cmputWorld increaseNodeByOne: location];
//   // LogInfo(@"%f, %f",location.x, location.y);
//        
//}

 // The ccTouchMoved:withEvent: method is optional for the <CCTouchDelegateProtocol>.
 // The event dispatcher will not dispatch events for which there is no method
 // implementation. Since the touch-move events are both voluminous and seldom used,
 // the implementation of ccTouchMoved:withEvent: has been left out of the default
 // CC3Layer implementation. To receive and handle touch-move events for object
 // picking,uncomment the following method implementation. To receive touch events,
 // you must also set the isTouchEnabled property of this instance to YES.

 // Handles intermediate finger-moved touch events. 
-(void) ccTouchMoved: (UITouch *)touch withEvent: (UIEvent *)event {
	[self handleTouch: touch ofType: kCCTouchMoved];
}

@end
