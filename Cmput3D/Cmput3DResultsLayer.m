//
//  Cmput3DResultsLayer.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-04-17.
//  Copyright 2012 Greg Jaciuk. All rights reserved.
//

#import "Cmput3DResultsLayer.h"
#import "Cmput3DLayer.h"
#import "Cmput3DMenuLayer.h"
#import "CCLabelBMFont.h"

@implementation Cmput3DResultsLayer

@synthesize selectionTracker;
@synthesize depthTracker;
@synthesize complexityTracker;


-(CCScene *) scene{
	
    CCScene *scene = [CCScene node];
	Cmput3DResultsLayer *layer = [Cmput3DResultsLayer node];
    
    //add the layer holding the labels to the parent layer Cmput3dResultsLayer
	[layer addChild:labelLayer];
    [scene addChild: layer];
	
	return scene;
}

-(void) dealloc{
    [super dealloc];
    
    menuButton = nil;
    resultsButton = nil;
    labelLayer = nil;
    device = nil;
    
    [selectionTracker release];
    [complexityTracker release];
    [depthTracker release];
}

// ipad width = 2.3375 times bigger
// ipad height = 2.13 times bigger
// ipad is 1024 x 768
// iphone is 480 x 320
-(void) initializeControls{
   
    windowSize = (CGSize)[[CCDirector sharedDirector] winSize];        

    averageDepth = 0.0;
    correctAnswers = 0;
    incorrectAnswers = 0;
    device = [[[UIDevice currentDevice] model] 
                    stringByReplacingOccurrencesOfString:@" Simulator" 
                    withString:@""];
   
    
    if ([device isEqualToString:@"iPhone"]){ 
        label_scale = 0.8;
    }
    else if ([device isEqualToString:@"iPad"]){
        label_scale = 1.9;
    }
    else{
        label_scale = 0.8;       
    }
    
    labelLayer = [[CCLayer alloc] init];
    
    [self addBackButton];
    //[self addLabels];
    
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
//
//-(void)addLabels{
//    CCLabelBMFont *label;
//    CGFloat x = 0.00, y = 260;
//    CGFloat y_pos = 0.0;
//    
//    for (int i = 0; i < TEST_LENGTH; ++i) {
//        
//        label = [self addStatsLabel:@"" tag:i];
//        
//        label.position = ccp(x, y + y_pos);
//        [label setColor: ccYELLOW];
//        [label setScale:0.9];
//        
//        if (i == 14){
//            x = windowSize.width/2;
//            y = 260;
//            y_pos = 0.0;
//        }
//        else
//            y_pos -= 20;
//    }
//}

-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText tag: (uint) aTag{
    CCLabelBMFont* aLabel = [CCLabelBMFont labelWithString: labelText fntFile:@"arial-16.fnt"];
	[aLabel setAnchorPoint: ccp(0.0, 0.0)];
	[labelLayer addChild: aLabel z:0 tag:aTag];
	return aLabel;
}

-(void) results {
	CCTexture2DPixelFormat currentFormat = [CCTexture2D defaultAlphaPixelFormat];
	[CCTexture2D setDefaultAlphaPixelFormat: kCCTexture2DPixelFormat_RGBA4444];
	
    CCLabelBMFont *label;
    NSString *sLabel;
    uint selection = 0;
    CGFloat objectDepth;
    NSString *complx = @"";
    CGFloat x = 0.00, y = 270;
    CGFloat y_pos = 0.0;
    
    if ([device isEqualToString:@"iPad"]){
        y = 648;
    }
    
    for (int i = 0; i < TEST_LENGTH; ++i) {
        sLabel = [[NSString alloc] init];
        
        //build the label string
        objectDepth = [(NSNumber*)[depthTracker objectAtIndex:i] floatValue];
        complx = [NSString stringWithFormat:@"%@ ", [complexityTracker objectAtIndex:i]];
        selection = [(NSNumber*)[selectionTracker objectAtIndex:i] intValue];
        
        sLabel = [sLabel stringByAppendingString: complx];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Answer:%d ", selection]];
        sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Depth:%.1f", objectDepth]];
        
        label = [self addStatsLabel:sLabel tag:i];
        
        label.position = ccp(x, y + y_pos);
        [label setColor: ccYELLOW];
        [label setScale: label_scale];
        
        //At half way reset the y-cooridinate and move the x to half width
        if (i == 14){
            x = windowSize.width/2;
            if ([device isEqualToString:@"iPad"])
                y = 648;
            else
                y = 270;
            
            y_pos = 0.0;
        }
        else {
            if ([device isEqualToString:@"iPad"])
                y_pos -= 30;
            else
                y_pos -= 15;
            
        }
        
        if (selection == 1)
            correctAnswers += 1;
        averageDepth += objectDepth;
        
        sLabel = nil;
    }
    
    incorrectAnswers = TEST_LENGTH - correctAnswers;
    averageDepth = averageDepth/TEST_LENGTH;
    LogInfo(@"c = %d,ic =  %d, ad= %.1f", correctAnswers, incorrectAnswers, averageDepth);
    
    sLabel = [[NSString alloc] init];
    sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Correct: %d   |   ", correctAnswers]];
    sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Incorrect: %d   |   ", incorrectAnswers]];
    sLabel = [sLabel stringByAppendingString: [NSString stringWithFormat:@"Average Depth: %.1f", averageDepth]];
    
    label = [self addStatsLabel:sLabel tag:-1];
    
    x = 40; y = 30;
    label.position = ccp(x, y);
    [label setColor: ccYELLOW];
    
    if ([device isEqualToString:@"iPad"])
        [label setScale:2.5];
    else
        [label setScale:1];
    
	[CCTexture2D setDefaultAlphaPixelFormat: currentFormat];
    
    [sLabel release];
}

-(void)showResults{
    
    for (int i = 0; i < TEST_LENGTH; ++i) {
       
        LogInfo(@"%@, Answer: %@ Depth: %@\n\n",
                [complexityTracker objectAtIndex: i],
                [selectionTracker objectAtIndex: i], 
                [depthTracker objectAtIndex: i]);
        
    }
}

//-(void)getResultsButton{
//    resultsButton = [CCMenuItemImage itemFromNormalImage:@"back_Label.png" 
//                                           selectedImage:@"back_Label_selected.png" 
//                                                  target:self
//                                                selector:@selector(showResults:)];
//    
//    CCMenu *menu = [CCMenu menuWithItems:resultsButton, nil];
//    [menu setPosition:CGPointMake(windowSize.width-(windowSize.width-BTN_OFFSET_LEFT), 
//                                  windowSize.height-BTN_OFFSET_TOP -30)];
//    
//    [self addChild:menu];
//}

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
