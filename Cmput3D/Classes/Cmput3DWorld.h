//
//  Cmput3DWorld.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk  2012. All rights reserved.
//


#import "CC3World.h"
#import "CC3MeshNode.h"
#import "CC3PODLight.h"
#import "CC3PODResourceNode.h"
#import "CC3ActionInterval.h"
#import "CC3Camera.h"
#import "CC3Light.h"
#import "CC3ParametricMeshNodes.h"

/** Enumeration of camera zoom options. */
typedef enum {
	kCameraZoomNone,			/**< Inside the world. */
	kCameraZoomStraightBack,	/**< Zoomed straight out to view complete world. */
	kCameraZoomBackTopRight,	/**< Zoomed out to back top right view of complete world. */
} CameraZoomType;

//typedef enum{
//    ROUND_ONE,
//    ROUND_TWO,
//    ROUND_THREE
//} Rnd;

#define TEST_LENGTH 30
#define DEPTH_CHANGE 20
#define OBJECT_SCALE 40
#define BASE_OBJ 1
#define SIMPLE_OBJ 2
#define CORRECT 1
#define INCORRECT 0
#define SET_LEFT .33
#define SET_RIGHT .66

@interface Cmput3DWorld : CC3World {

    NSMutableArray *templateNodes;
    NSMutableArray *simpleNodes;
    NSMutableArray *selectionTracker;
    NSMutableArray *depthTracker;
    
    CC3Node *currentNode;
    NSString *currentNodeName;
    CC3Camera *camera;
    CC3Light *lamp;
    CC3Node* origCamTarget;
	CC3Node* camTarget;
    CC3Node *selectedNode;
    
    CameraZoomType cameraZoomType;
    uint currentNodeIdx;

    
    CGFloat depth;
    uint testCount;
    BOOL firstGuess;
    BOOL secondGuess;
    BOOL wrongGuess;
    uint LODidx;
    
    CGSize windowSize;
    
}

@property (nonatomic, retain) NSMutableArray *templateNodes;
@property (nonatomic, retain) NSMutableArray *simpleNodes;
@property (nonatomic, retain) NSMutableArray *selectionTracker;
@property (nonatomic, retain) NSMutableArray *depthTracker;


//Creates an array with some template objects that should be copied and
//placed on the screen via [self addChild:aNode]
-(void)initializeTemplates;

//this sets the initial object to 1 of 3 objects in the template array
//this is based on an index that is passed by the menu layer
-(void)setSelectedObject:(uint) kname;
-(void)nextRound;

-(void)addCamera;
-(void)addLamp;

@end
