//
//  Cmput3DWorld.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk 2012. All rights reserved.
//

#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"

@implementation Cmput3DWorld

@synthesize templateNodes;
@synthesize simpleNodes;
@synthesize selectionTracker;
@synthesize depthTracker;

-(void) dealloc {

    camera = nil;
    lamp = nil;
    currentNode = nil;
    currentNodeName = nil;
    camTarget = nil;
    origCamTarget = nil;
    selectedNode = nil;
    
    [templateNodes release];
    [simpleNodes release];
    [selectionTracker release];
    [depthTracker release];

	[super dealloc];
}

-(id) init {
    
    if ((self = [super init])){
        selectionTracker = [[NSMutableArray arrayWithCapacity: TEST_LENGTH ] retain];
        depthTracker = [[NSMutableArray arrayWithCapacity: TEST_LENGTH ] retain];
        
        selectedNode = nil;
        
        windowSize = (CGSize)[[CCDirector sharedDirector] winSize];
        
        //Need to calculate the depth based on the screen size
        depth = 0.0;
        testCount = 0;
        
        firstGuess = NO;
        secondGuess = NO;
        wrongGuess = NO;
        LODidx = arc4random() % 9;        
    }
    return self;
}


-(void) initializeTemplates {
	
    CC3MeshNode* mn;
	CC3ResourceNode* rezNode;
    
    templateNodes = [[NSMutableArray array] retain];
    simpleNodes = [[NSMutableArray array] retain];
    
    // Ball models from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kBallsFileName];
	
	// Beachball with no texture, but with several subnodes
	mn = (CC3MeshNode*)[rezNode getNodeNamed: kBeachBallName];
	[mn remove];		// Remove from the POD resource
	mn.isOpaque = YES;
	mn.isTouchEnabled = YES;
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
    
    //Add the Full complexity buddha
    rezNode = [CC3PODResourceNode nodeFromResourceFile:kBuddhaPODFile0];
    mn = (CC3MeshNode*) [rezNode getNodeNamed:kBuddhaName0];
    [mn remove];
    mn.isTouchEnabled = YES;
    [templateNodes addObject:mn];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kDieCubePODFile];
	mn = (CC3MeshNode*)[rezNode getNodeNamed: kDieCubeName];
	[mn remove];		// Remove from the POD resource
	mn.isTouchEnabled = YES;
	[templateNodes addObject: mn];
	
    NSLog(@"DONE");
    NSLog(@"%d", [templateNodes count]);
}

-(void) initSimpleNodeArray: (NSString *) kname{
    
    if (kname == kBunnyName0)
        [self initWithBunny];
    
    else if (kname == kBuddhaName0)
        [self initWithBuddha];
    
    else if (kname == kDinoName0)
        [self initWithDinosaur];
    
}


/**
 * Constructs the 3D world.
 *
 * Adds 3D objects to the world, loading a 3D 'pod' message
 * from a POD file
*/
-(void) initializeWorld {
    
    [self initializeTemplates];
    
    [self addCamera];
    
//	[self addContentFromPODResourceFile: @"DieCube.pod"] ;
	
    self.drawingSequencer = [CC3NodeArraySequencer sequencerWithEvaluator: [CC3LocalContentNodeAcceptor evaluator]];
	self.drawingSequencer.allowSequenceUpdates = NO;
    
	// Create OpenGL ES buffers for the vertex arrays to keep things fast and efficient,
	// and to save memory, release the vertex data in main memory because it is now redundant.
	[self createGLBuffers];
	[self releaseRedundantData];
    
	// Displays bounding boxes around all nodes. The bounding box for each node
	// will encompass its child nodes.
//	self.shouldDrawAllWireframeBoxes = NO;
	
	LogDebug(@"The structure of this world is: %@", [self structureDescription]);
	
}

-(void) addCamera{

    // Camera starts out embedded in the world.
	cameraZoomType = kCameraZoomNone;
	
	// The camera comes from the POD file and is actually animated.
	// Stop the camera from being animated so the user can control it via the user interface.
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

-(void)setSelectedObject:(uint) idx{
    
    if (idx == 0)
        currentNodeName = kBunnyName0;
    else if (idx == 1)
        currentNodeName = kBuddhaName0;
    else
        currentNodeName = kDinoName0;
    
    currentNodeIdx = idx;
    currentNode = (CC3Node*)[templateNodes objectAtIndex:currentNodeIdx];
    
    [self initSimpleNodeArray: currentNodeName];
    
    [self nextRound];
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
    
    [self addChild:aNode];
    
    [self createGLBuffers];			// Copy vertex data to OpenGL VBO's.
	[self releaseRedundantData];	// Release vertex data from main memory.
   
    //NSLog(@"%d",  [[self children] count]);
}

-(void) nextRound{
    
    if (testCount == TEST_LENGTH) {
        for (NSNumber* num in selectionTracker) {
            NSLog(@"%d",[num unsignedIntValue]);
        }
        for (NSNumber* num in depthTracker) {
            NSLog(@"%f",[num floatValue]);
        }
        [[CCDirector sharedDirector] replaceScene:
         [CCTransitionFade transitionWithDuration:0.5f scene:[Cmput3DMenuLayer scene]]];
    }
    else{
    
        [self removeAllChildren];

        CGFloat baseNode, simpleNode;
        
        int i = random()%10;
        if (i%2 == 0){
            baseNode = SET_LEFT;
            simpleNode = SET_RIGHT;
        }
        else {
            baseNode = SET_RIGHT;
            simpleNode = SET_LEFT;
        }
        
        if (secondGuess){
            depth -= DEPTH_CHANGE;
            firstGuess = NO;
            secondGuess = NO;
            wrongGuess = NO;
            if (LODidx < [simpleNodes count]) 
                LODidx += 1;
        }
        else if (wrongGuess){
            depth += DEPTH_CHANGE;
            firstGuess = NO;
            secondGuess = NO;
            wrongGuess = NO;
            if (LODidx > 0) 
                LODidx -= 1;
        }
        
        CC3Node *aNode = [currentNode copyAutoreleased];
        
        aNode.location = cc3v(windowSize.width*baseNode, windowSize.height/2, depth);
        aNode.uniformScale *= OBJECT_SCALE;
        aNode.isTouchEnabled = YES;
        aNode.tag = BASE_OBJECT;
        
        CC3Node *aNode2 = [(CC3Node*)[simpleNodes objectAtIndex: LODidx] copyAutoreleased];
        
        aNode2.location = cc3v(windowSize.width*simpleNode, windowSize.height/2, depth);
        aNode2.uniformScale *= OBJECT_SCALE;
        aNode2.isTouchEnabled = YES;
        aNode2.tag = SIMPLE_OBJECT;
        
//        CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
//                                                              rotateBy: cc3v(0.0, 30.0, 0.0)];
//        CCActionInterval* partialRot2 = [CC3RotateBy actionWithDuration: 1.0
//                                                               rotateBy: cc3v(0.0, 30.0, 0.0)];
//        
//        [aNode runAction: [CCRepeatForever actionWithAction: partialRot]];
//        [aNode2 runAction: [CCRepeatForever actionWithAction: partialRot2]];
//        
        [self addChild:aNode];
        [self addChild:aNode2];    
        [self addLamp];
    }
}

-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
    
	switch (touchType) {
		case kCCTouchBegan:
            NSLog(@"Touch Began");
			[touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint];
            break;
        case kCCTouchMoved:
            [self rotateMainNodeFromSwipeAt: touchPoint];
            break;
        case kCCTouchEnded:
            NSLog(@"Touch ended");
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
        if (node == selectedNode)
            [node rotateByAngle: angle aroundAxis: axis];
    }
    
}


//will get called based on teh touchEvent method by calling
// [touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint]; 
// in the touchBegan / touchEnded
-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	LogInfo(@"You selected %@ at %@, or %@ in 2D.", aNode,
			NSStringFromCC3Vector(aNode ? aNode.globalLocation : kCC3VectorZero),
			NSStringFromCC3Vector(aNode ? [activeCamera projectNode: aNode] : kCC3VectorZero));
    
    
	// Remember the node that was selected
	selectedNode = aNode;
    
    if (selectedNode != nil){
        for (CC3Node* child in children) {
            
            if (aNode == child && aNode.tag == BASE_OBJECT){
                if (firstGuess) secondGuess = YES;
                
                [selectionTracker addObject:[NSNumber numberWithInt:CORRECT]];
                [depthTracker addObject:[NSNumber numberWithFloat:depth]];
                firstGuess = YES;
            }
            else if (aNode.tag == SIMPLE_OBJECT){
                [selectionTracker addObject:[NSNumber numberWithInt:INCORRECT]];
                [depthTracker addObject:[NSNumber numberWithFloat:depth]];
                firstGuess = NO;
                secondGuess = NO;
                wrongGuess = YES;
            }
        }

        testCount++;
    }
	
}


-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void)initWithBunny{
    CC3MeshNode* meshNode;
	CC3ResourceNode* resourceNode;
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile1];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName1];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile2];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName2];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
    resourceNode = [CC3PODResourceNode nodeFromResourceFile:kBunnyPODFile3];
    
    meshNode = (CC3MeshNode*)[resourceNode getNodeNamed:kBunnyName3];
    [meshNode remove];
    meshNode.isTouchEnabled = YES;
    [simpleNodes addObject:meshNode];
    
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

@end

