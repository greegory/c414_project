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

//game variables
#define TEST_LENGTH 16
//#define DEPTH_CHANGE 20
//#define OBJECT_SCALE 40
#define BASE_OBJECT 1
#define SIMPLE_OBJECT 2
#define CORRECT 1
#define INCORRECT 0
#define SET_LEFT .33
#define SET_RIGHT .66

#define LEFT_NODE                0
#define RIGHT_NODE               1

@interface Cmput3DWorld : CC3World {

    NSMutableArray *templateNodes;
    NSMutableArray *simpleNodes;
    NSMutableArray *selectionTracker;
    NSMutableArray *depthTracker;
    NSMutableArray *complexityTracker;
    
    CC3Node *currentNode; //Template node being used i.e. buddha, dragon, bunny
    NSString *currentNodeName; 
    CC3Camera *camera;
    CC3Light *lamp;
    CC3Node *origCamTarget;
	CC3Node *camTarget;
    CC3Node *selectedNode; // The last node that was selected by the user touch
    
    CC3Node *leftNode;
    CC3Node *rightNode;
    
    CGPoint lastTouchPoint;
    
    CameraZoomType cameraZoomType;
    uint currentNodeIdx; //index reference for the templateNodes Array
    
    CGFloat depth;
    CGFloat depth_change;
    CGFloat object_scale;
    
    uint testCount;
    BOOL firstGuess;
    BOOL secondGuess;
    BOOL wrongGuess;
    uint LODidx; //index reference for the level of detail 
    
    CGSize windowSize;
    
}

@property (nonatomic, retain) NSMutableArray *templateNodes;
@property (nonatomic, retain) NSMutableArray *simpleNodes;
@property (nonatomic, retain) NSMutableArray *selectionTracker;
@property (nonatomic, retain) NSMutableArray *depthTracker;
@property (nonatomic, retain) NSMutableArray *complexityTracker;


//Creates an array with some template objects that should be copied and
//placed on the screen via [self addChild:aNode]
-(void)initializeTemplates;

//3dLayer needs to uncomment cctouchmoved method for this method to work Cmput3DLayer
//This layer gets called on every pixel change from the touch. The touchpoint is
//re-sent every time. Last touch needs to be remembered to compare it against
-(void)rotateMainNodeFromSwipeAt: (CGPoint) touchPoint;

//this sets the initial object to 1 of 3 objects in the template array
//this is based on an index that is passed by the menu layer
-(void)setSelectedObject:(uint) kname;

//the logic of the test is calculated and any adjustments to globals is done
-(void)calculateGameLogic: (uint) choice;
-(void)nextRound;

// adds another current object to the touchpoint
-(void)increaseNodeByOne: (CGPoint) touchpoint;

-(void)addCamera;
-(void)addLamp;

-(void)initWithBunny;
-(void)initWithBuddha;
-(void)initWithDinosaur;

@end
