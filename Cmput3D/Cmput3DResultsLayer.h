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
    
    CCLayer *labelLayer;
    
    CGFloat averageDepth;
    uint correctAnswers, incorrectAnswers;
}

@property (nonatomic, retain) NSMutableArray *selectionTracker;
@property (nonatomic, retain) NSMutableArray *depthTracker;
@property (nonatomic, retain) NSMutableArray *complexityTracker;

-(void) initWithResults: (NSMutableArray*) selectionTrack 
                                  depth: (NSMutableArray*) depthTrack
                                   name: (NSMutableArray*) complexityTrack;
-(void)addBackButton;
-(void)getResultsButton;
-(void)showResults;
-(void)backToMenu: (CCMenuItem*) menuItem;
-(void)results;
-(void)addLabels;

-(CCLabelBMFont*) addStatsLabel: (NSString*) labelText tag: (uint) aTag;

-(CCScene*) scene;

@end
