//
//  Cmput3DResultsLayer.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-04-17.
//  Copyright 2012 Greg Jaciuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CC3Layer.h"
#import "CCLayer.h"

@interface Cmput3DResultsLayer : CC3Layer {
    NSMutableArray *selectionTracker;
    NSMutableArray *depthTracker;
    NSMutableArray *complexityTracker;
    
    CCMenuItem *menuButton;
    CCMenuItem *resultsButton;
    CGSize windowSize; 
    CGSize windowSizeInPixels;
    
    CCLayer *labelLayer;
    CGFloat label_scale;
    NSString *device;
    
    CGFloat averageDepth;
    uint correctAnswers, incorrectAnswers;
}

@property (nonatomic, retain) NSMutableArray *selectionTracker;
@property (nonatomic, retain) NSMutableArray *depthTracker;
@property (nonatomic, retain) NSMutableArray *complexityTracker;

//method needs to be called for anything to be displayed. It is passed all the
//results from the cmput3dworld 
-(void) initWithResults: (NSMutableArray*) selectionTrack 
                                  depth: (NSMutableArray*) depthTrack
                                   name: (NSMutableArray*) complexityTrack;
-(void)addBackButton;
//-(void)getResultsButton;
//displays the results in console
-(void)showResults;
-(void)backToMenu: (CCMenuItem*) menuItem;
//adds all the results as CCLabelBMFont labels to the display 
-(void)results;
//-(void)addLabels;

// Creates a label to be used for results, adds it as a child to the
// labelLayer (layer holding only the results labels) , and returns it.
-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText tag: (uint) aTag;

//returns the scene this layer will run on
-(CCScene*) scene;

@end
