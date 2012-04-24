//
//  Cmput3DWorld.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk 2012. All rights reserved.
//

#import "Cmput3DAppDelegate.h"
#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"
#import "Cmput3DResultsLayer.h"

@implementation Cmput3DWorld

@synthesize templateNodes;
@synthesize simpleNodes;
@synthesize selectionTracker;
@synthesize depthTracker;
@synthesize complexityTracker;

-(void) dealloc {

    camera = nil;
    lamp = nil;
    currentNode = nil;
    currentNodeName = nil;
    camTarget = nil;
    origCamTarget = nil;
    selectedNode = nil;
    
    leftNode = nil;
    rightNode = nil;
    
    [templateNodes release];
    [simpleNodes release];
    [selectionTracker release];
    [depthTracker release];
    [complexityTracker release];

	[super dealloc];
}

-(id) init {
    
    if ((self = [super init])){
        selectionTracker = [[NSMutableArray arrayWithCapacity: TEST_LENGTH ] retain];
        depthTracker = [[NSMutableArray arrayWithCapacity: TEST_LENGTH ] retain];
        complexityTracker = [[NSMutableArray arrayWithCapacity: TEST_LENGTH ] retain];
        
        selectedNode = nil;
        
        windowSize = (CGSize)[[CCDirector sharedDirector] winSize];
        
        //Need to calculate the depth, change, and scale based on the screen size
        depth = 0.0;
        
        NSString *device = [[[UIDevice currentDevice] model] 
                            stringByReplacingOccurrencesOfString:@" Simulator" 
                            withString:@""];
        
        LogInfo(@"%@", device);
        
        if ([device isEqualToString:@"iPhone"]){ 
            object_scale = 40;
            depth_change = 20;
        }
        else if ([device isEqualToString:@"iPad"]){
            object_scale = 80;
            depth_change = 40;
        }
        else{
            object_scale = 40;
            depth_change = 20;        
        }
        
        device = nil;
        
        testCount = 0;
        firstGuess = NO;
        secondGuess = NO;
        wrongGuess = NO;     
        
        [self initializeTemplates];
    }
    return self;
}


-(void) initializeTemplates {
	
    CC3MeshNode* mn;
	CC3ResourceNode* rezNode;
    
    templateNodes = [[NSMutableArray array] retain];
    
    // POD resource for Full complexity Bunny
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kBunnyPODFile3];
	
	mn = (CC3MeshNode*) [rezNode getNodeNamed: kBunnyName3];
	[mn remove];		// Remove from the POD resource
	[templateNodes addObject: mn];
    
    // Add the Full complexity buddha
    rezNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile0];
    
    mn = (CC3MeshNode*) [rezNode getNodeNamed:kBuddhaName0];
    [mn remove];
    [templateNodes addObject:mn];
	
	// POD resource for Full complexity Dinosaur
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kDinoPODFile0];
	
    mn = (CC3MeshNode*)[rezNode getNodeNamed: kDinoName0];
	[mn remove];		// Remove from the POD resource
	[templateNodes addObject: mn];
	
    
    //	// Make a simple box template available. Only 6 faces per node.
    //	mn = [CC3BoxNode nodeWithName: kBoxName];
    //	CC3BoundingBox bBox;
    //	bBox.minimum = cc3v(-1.0, -1.0, -1.0);
    //	bBox.maximum = cc3v( 1.0,  1.0,  1.0);
    //	[mn populateAsSolidBox: bBox];
    //	mn.material = [CC3Material material];
    //	mn.isTouchEnabled = YES;
    //	//mn.shouldColorTile = YES;
    //	[templateNodes addObject: mn];
    
    LogInfo(@"DONE Loading templates");
    LogInfo(@"%d", [templateNodes count]);
}

-(void) initSimpleNodeArray: (NSString *) kname{
    
    simpleNodes = [[NSMutableArray array] retain];
    
    if (kname == kBunnyName3)
        [self initWithBunny];
    
    else if (kname == kBuddhaName0)
        [self initWithBuddha];
    
    else if (kname == kDinoName0)
        [self initWithDinosaur];
    
    
    //set the LODidx randomly within the number of available 3d meshes
    LODidx = arc4random() % [simpleNodes count];   
}

-(void)setSelectedObject:(uint) idx{
    
    if (idx == 0)
        currentNodeName = kBunnyName3;
    else if (idx == 1)
        currentNodeName = kBuddhaName0;
    else
        currentNodeName = kDinoName0;
    
    currentNodeIdx = idx;
    currentNode = [(CC3Node*)[templateNodes objectAtIndex:currentNodeIdx] copyAutoreleased];
    
    
    [self initSimpleNodeArray: currentNodeName];
    
    [self nextRound];
}


/**
 * Constructs the 3D world.
 *
 * Adds 3D objects to the world, loading a 3D 'pod' message
 * from a POD file
*/
-(void) initializeWorld {
    
    //[self addCamera];
	
    self.drawingSequencer = [CC3NodeArraySequencer sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	self.drawingSequencer.allowSequenceUpdates = NO;
    
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
	
	LogDebug(@"The structure of this world is: %@", [self structureDescription]);
	
}

-(void) addCamera{

    // Camera starts out embedded in the world.
	cameraZoomType = kCameraZoomNone;
	
	[self.activeCamera disableAnimation];
	
	// Keep track of which object the camera is pointing at
	origCamTarget = self.activeCamera.target;
	camTarget = origCamTarget;
    
	self.activeCamera.uniformScale = 1;
	
   // [self addLamp];

}

-(void) addLamp{
    
	lamp = [CC3Light nodeWithName: @"Lamp"];
	lamp.location = cc3v( windowSize.width/2, windowSize.height/2, depth+200 );
	lamp.isDirectionalOnly = NO;
    lamp.uniformScale *= 100;
	[self addChild: lamp];
    
}

-(void) calculateGameLogic: (uint) choice{
    
    NSString *nName = @"";
      
    if (leftNode.tag == BASE_OBJECT && choice == LEFT_NODE){
        if (firstGuess){ secondGuess = YES; LogInfo(@"second guess correct");}
        
        nName = [leftNode.structureDescription stringByReplacingOccurrencesOfString:@"CC3PODMeshNode " withString:@""];
        nName = [nName stringByReplacingOccurrencesOfString:@" (POD index: 0)" withString:@""];
        nName = [nName stringByReplacingOccurrencesOfString:@"-1" withString:@""];
        
        [selectionTracker addObject:[NSNumber numberWithInt:CORRECT]];
        [depthTracker addObject:[NSNumber numberWithFloat:depth]];
        [complexityTracker addObject:nName];
        
        firstGuess = YES;
        LogInfo(@"First guess correct");
    }
    else if (leftNode.tag == SIMPLE_OBJECT && choice == RIGHT_NODE){
        if (firstGuess){ secondGuess = YES; LogInfo(@"second guess correct");}
        
        nName = [rightNode.structureDescription stringByReplacingOccurrencesOfString:@"CC3PODMeshNode" withString:@""];       
        nName = [nName stringByReplacingOccurrencesOfString:@" (POD index: 0)" withString:@""];
        nName = [nName stringByReplacingOccurrencesOfString:@"-2" withString:@""];
        
        [selectionTracker addObject:[NSNumber numberWithInt:CORRECT]];
        [depthTracker addObject:[NSNumber numberWithFloat:depth]];
        [complexityTracker addObject:nName];
         
        firstGuess = YES;
        LogInfo(@"First guess correct");
    }
    else if (leftNode.tag == BASE_OBJECT && choice == RIGHT_NODE){
        nName = [rightNode.structureDescription stringByReplacingOccurrencesOfString:@"CC3PODMeshNode" withString:@""];
        nName = [nName stringByReplacingOccurrencesOfString:@" (POD index: 0)" withString:@""]; 
        nName = [nName stringByReplacingOccurrencesOfString:@"-1" withString:@""];
        
        [selectionTracker addObject:[NSNumber numberWithInt:INCORRECT]];
        [depthTracker addObject:[NSNumber numberWithFloat:depth]];
        [complexityTracker addObject:nName];
        
        firstGuess = NO;
        secondGuess = NO;
        wrongGuess = YES;
        LogInfo(@"First guess wrong");
    }
    else if (leftNode.tag == SIMPLE_OBJECT && choice == LEFT_NODE){
        nName = [leftNode.structureDescription stringByReplacingOccurrencesOfString:@"CC3PODMeshNode" withString:@""];
        nName = [nName stringByReplacingOccurrencesOfString:@" (POD index: 0)" withString:@""]; 
        nName = [nName stringByReplacingOccurrencesOfString:@"-2" withString:@""];
        
        [selectionTracker addObject:[NSNumber numberWithInt:INCORRECT]];
        [depthTracker addObject:[NSNumber numberWithFloat:depth]];
        [complexityTracker addObject:nName];
        
        firstGuess = NO;
        secondGuess = NO;
        wrongGuess = YES;
        LogInfo(@"First guess wrong");
    }
    
    testCount++;
    
    if (testCount == TEST_LENGTH) {
        
        Cmput3DResultsLayer *alayer = [Cmput3DResultsLayer node];
        [alayer initWithResults:selectionTracker depth:depthTracker name:complexityTracker];
        
        [alayer scheduleUpdate];
            
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:[alayer scene]]];
    }
    else{
        
        if (secondGuess){
            depth -= depth_change;
            firstGuess = NO;
            secondGuess = NO;
            wrongGuess = NO;
            if (LODidx > 0) 
                LODidx -= 1;
        }
        else if (wrongGuess){
            // dino model scale is different that other two. Needs to stop
            // coming closer at depth 60.0 instead of 100.0
            if (currentNodeName == kDinoName0){
                if (depth < 60.0)
                    depth += depth_change;
            }
            else if (depth < 100.0)
                depth += depth_change;
            
            firstGuess = NO;
            secondGuess = NO;
            wrongGuess = NO;
            if (LODidx < [simpleNodes count]-1) 
                LODidx += 1;
        }
        LogInfo(@"%.1f", depth);
    }
}

-(void) nextRound{
    
    int i = arc4random()%10;
    CGFloat baseNodeOffset, simpleNodeOffset;
    
    [self removeAllChildren];
    
    if (i%2 == 0){
        baseNodeOffset = SET_LEFT;
        simpleNodeOffset = SET_RIGHT;
    }
    else {
        baseNodeOffset = SET_RIGHT;
        simpleNodeOffset = SET_LEFT;
    }
    
    CC3Node *aNode = [(CC3Node*)[templateNodes objectAtIndex:currentNodeIdx] copyAutoreleased];
    
    aNode.location = cc3v(windowSize.width*baseNodeOffset, windowSize.height/2, depth);
    aNode.uniformScale *= object_scale;
    aNode.isTouchEnabled = YES;
    aNode.tag = BASE_OBJECT;
    
    CC3Node *aNode2 = [(CC3Node*)[simpleNodes objectAtIndex: LODidx] copyAutoreleased];
    
    aNode2.location = cc3v(windowSize.width*simpleNodeOffset, windowSize.height/2, depth);
    aNode2.uniformScale *= object_scale;
    aNode2.isTouchEnabled = YES;
    aNode2.tag = SIMPLE_OBJECT;
     
    if (baseNodeOffset < 0.5){
        leftNode = aNode;
        rightNode = aNode2;
    }
    else {
        leftNode = aNode2;
        rightNode = aNode;
    }
        
    [self addChild:aNode] ;
    [self addChild:aNode2];    
    [self addLamp];
       
    [self createGLBuffers];
	[self releaseRedundantData];
}

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
    
	switch (touchType) {
		case kCCTouchBegan:
            LogInfo(@"Touch Began");
			[touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint];
            break;
        case kCCTouchMoved:
            [self rotateMainNodeFromSwipeAt: touchPoint];
            break;
        case kCCTouchEnded:
            LogInfo(@"Touch ended");
            //[self nextRound];
            
            //[touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint];
            break;
		default:
			break;
	}
    // For all event types, remember where the touchpoint was, for subsequent events.
	lastTouchPoint = touchPoint;
	
}
/** Set this parameter to adjust the rate of rotation from the length of touch-move swipe. */
#define kSwipeScale 0.6


-(void) rotateMainNodeFromSwipeAt: (CGPoint) touchPoint {
	
	CC3Camera* cam = self.activeCamera;
	
	// Get the direction and length of the movement since the last touch move event, in
	// 2D screen coordinates. The 2D rotation axis is perpendicular to this movement.
	CGPoint swipe2d = ccpSub(touchPoint, lastTouchPoint);
	CGPoint axis2d = ccpPerp(swipe2d);
	
	// Project the 2D axis into a 3D axis by mapping the 2D X & Y screen coords
	// to the camera's rightDirection and upDirection, respectively.
	CC3Vector axis = CC3VectorAdd(CC3VectorScaleUniform(cam.rightDirection, axis2d.x),
								  CC3VectorScaleUniform(cam.upDirection, axis2d.y));
	GLfloat angle = ccpLength(swipe2d) * kSwipeScale;

	for (CC3Node* node in children) {
        if (node == selectedNode){
//            CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
//                                                        rotateBy: cc3v(0.0,30,0.0)];   
//            [node runAction: [CCRepeatForever actionWithAction: partialRot]];
            [node rotateByAngle: angle aroundAxis: axis];
            
        }
    }
    
}


// will get called based on teh touchEvent method by calling
// [touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint]; 
// in the touchBegan / touchEnded
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	LogInfo(@"You selected %@ at %@, or %@ in 2D.", aNode,
			NSStringFromCC3Vector(aNode ? aNode.globalLocation : kCC3VectorZero),
			NSStringFromCC3Vector(aNode ? [activeCamera projectNode: aNode] : kCC3VectorZero));
    
    
	// Remember the node that was selected
	selectedNode = aNode;
    
}


-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void)initWithBunny{
    CC3MeshNode* meshNode;
	CC3ResourceNode* resourceNode;
    
//    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile1];
//    
//    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName1];
//    [meshNode remove];
//    meshNode.isTouchEnabled = YES;
//    [simpleNodes addObject:meshNode];
//    
//    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile2];
//    
//    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName2];
//    [meshNode remove];
//    meshNode.isTouchEnabled = YES;
//    [simpleNodes addObject:meshNode];
//    
//    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile3];
//    
//    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName3];
//    [meshNode remove];
//    meshNode.isTouchEnabled = YES;
//    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile4];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName4];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile5];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName5];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile6];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName6];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile7];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName7];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile8];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName8];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile9];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName9];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile10];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName10];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile11];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName11];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile12];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName12];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile13];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName13];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile14];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName14];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    
}

-(void)initWithBuddha{
    
    CC3MeshNode* meshNode;
	CC3ResourceNode* resourceNode;
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile1];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName1];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile2];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName2];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile3];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName3];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile4];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName4];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile5];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName5];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile6];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName6];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile7];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName7];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile8];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName8];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile9];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName9];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile10];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBuddhaName10];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
}

-(void)initWithDinosaur{
    
    CC3MeshNode* meshNode;
	CC3ResourceNode* resourceNode;
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile1];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName1];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile2];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName2];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile3];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName3];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile4];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName4];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile5];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName5];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile6];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName6];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile7];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName7];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile8];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName8];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kDinoPODFile9];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kDinoName9];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    
}
         
 
 -(void)increaseNodeByOne: (CGPoint) touchpoint{
     
     //This makes a random place for when the PLUS button is used
     if (touchpoint.x == 0){
         touchpoint = CGPointMake(arc4random()%320, arc4random()%480);
     }
     
     //Ensures that the objects to not overlap the menus
     if (touchpoint.y < windowSize.height-260)
         touchpoint.y = 80;
     else if (touchpoint.y > windowSize.height-60)
         touchpoint.y = 400;
     
     CC3Node *aNode = [currentNode copyAutoreleased];
     aNode.location = cc3v(touchpoint.x, touchpoint.y, depth);
     aNode.uniformScale *= 40;
     aNode.isTouchEnabled = YES;
     
     CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                           rotateBy: cc3v(0.0, 30.0, 0.0)];
     [aNode runAction: [CCRepeatForever actionWithAction: partialRot]];
     
     //        CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
     //                                                              rotateBy: cc3v(0.0, 30.0, 0.0)];
     //        CCActionInterval* partialRot2 = [CC3RotateBy actionWithDuration: 1.0
     //                                                               rotateBy: cc3v(0.0, 30.0, 0.0)];
     //        
     //        [aNode runAction: [CCRepeatForever actionWithAction: partialRot]];
     //        [aNode2 runAction: [CCRepeatForever actionWithAction: partialRot2]];
     //   
     [self addChild:aNode];
     
     [self createGLBuffers];			// Copy vertex data to OpenGL VBO's.
     [self releaseRedundantData];	// Release vertex data from main memory.
     
     //LogInfo(@"%d",  [[self children] count]);
 }
@end

