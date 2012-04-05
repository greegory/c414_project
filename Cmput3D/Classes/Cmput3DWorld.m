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
        
        testCount = 0;
        depth = 0.0;
        firstGuess = NO;
        secondGuess = NO;
        wrongGuess = NO;
        LODidx = 0;
        
        selectedNode = nil;
        
        windowSize = (CGSize)[[CCDirector sharedDirector] winSize];
        
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
    
	// Make a simple box template available. Only 6 faces per node.
	mn = [CC3BoxNode nodeWithName: kBoxName];
	CC3BoundingBox bBox;
	bBox.minimum = cc3v(-1.0, -1.0, -1.0);
	bBox.maximum = cc3v( 1.0,  1.0,  1.0);
	[mn populateAsSolidBox: bBox];
	mn.material = [CC3Material material];
	mn.isTouchEnabled = YES;
	//mn.shouldColorTile = YES;
	[templateNodes addObject: mn];
	
	// Die cube model from POD resource.
	rezNode = [CC3PODResourceNode nodeFromResourceFile: kDieCubePODFile];
	mn = (CC3MeshNode*)[rezNode getNodeNamed: kDieCubeName];
	[mn remove];		// Remove from the POD resource
	mn.isTouchEnabled = YES;
	[templateNodes addObject: mn];
	
    NSLog(@"DONE");
    NSLog(@"%d", [templateNodes count]);
}

-(void) initSimpleNodeArray: (uint) idx{
    
    CC3MeshNode* mn;
    GLubyte r  = 0.0, g = 0.0, b = 0.0, a = 0.0;
    
    // Make a simple box template available. Only 6 faces per node.
    mn = [CC3BoxNode nodeWithName: kBoxName];
    CC3BoundingBox bBox;
    bBox.minimum = cc3v(-1.0, -1.0, -1.0);
    bBox.maximum = cc3v( 1.0,  1.0,  1.0);
    [mn populateAsSolidBox: bBox];
    mn.material = [CC3Material material];
    mn.specularColor = ccc4f(r, g, b, a);
    
    mn.isTouchEnabled = YES;
    [simpleNodes addObject: mn];
    
    for (int i = 0; i < 9; ++i){
        
        CC3Node *aNode = [[simpleNodes objectAtIndex:0] copyAutoreleased];

        r += 10;
        g += 15;
        b += 20;
        a += 10;
        
        aNode.diffuseColor = ccc4f(r, g, b, a);
        
        [simpleNodes addObject:aNode];
        
    }
    
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

-(void) updateBeforeTransform: (CC3NodeUpdatingVisitor*) visitor {}

-(void) updateAfterTransform: (CC3NodeUpdatingVisitor*) visitor {}


-(void)setSelectedObject:(uint) idx{
    
    if (idx == 0)
        currentNodeName = kBeachBallName;
    else if (idx == 1)
        currentNodeName = kBoxName;
    else
        currentNodeName = kDieCubeName;
    
    currentNodeIdx = idx;
    currentNode = (CC3Node*)[templateNodes objectAtIndex:currentNodeIdx];
    
    [self initSimpleNodeArray: currentNodeIdx];
    
    [self nextRound];
}


//-(void)increaseNodeByOne: (CGPoint) loc{
//    
//    CGSize window = (CGSize)[[CCDirector sharedDirector] winSize];
//   
//    //This makes a random place for when the PLUS button is used
//    if (loc.x == 0){
//        loc = CGPointMake(arc4random()%320, arc4random()%480);
//    }
//    
//    //Ensures that the objects to not overlap the menus
//    if (loc.y < window.height-260)
//        loc.y = 80;
//    else if (loc.y > window.height-60)
//        loc.y = 400;
//    
//    CC3Node *aNode = [currentNode copyAutoreleased];
//    aNode.location = cc3v(loc.x, loc.y, depth);
//    aNode.uniformScale *= 40;
//    aNode.isTouchEnabled = YES;
//    
//    CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
//    														  rotateBy: cc3v(0.0, 30.0, 0.0)];
//    [aNode runAction: [CCRepeatForever actionWithAction: partialRot]];
//    
//    [self addChild:aNode];
//    
//    [self createGLBuffers];			// Copy vertex data to OpenGL VBO's.
//	[self releaseRedundantData];	// Release vertex data from main memory.
//   
//    //NSLog(@"%d",  [[self children] count]);
//}

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
            if (LODidx > 0) LODidx 
                -= 1;
        }
        
        CC3Node *aNode = [currentNode copyAutoreleased];
        
        aNode.location = cc3v(windowSize.width*baseNode, windowSize.height/2, depth);
        aNode.uniformScale *= OBJECT_SCALE;
        aNode.isTouchEnabled = YES;
        aNode.tag = BASE_OBJ;
        
        CC3Node *aNode2 = [(CC3Node*)[simpleNodes objectAtIndex: LODidx] copyAutoreleased];
        
        aNode2.location = cc3v(windowSize.width*simpleNode, windowSize.height/2, depth);
        aNode2.uniformScale *= OBJECT_SCALE;
        aNode2.isTouchEnabled = YES;
        aNode2.tag = SIMPLE_OBJ;
        
        CCActionInterval* partialRot = [CC3RotateBy actionWithDuration: 1.0
                                                              rotateBy: cc3v(0.0, 30.0, 0.0)];
        CCActionInterval* partialRot2 = [CC3RotateBy actionWithDuration: 1.0
                                                               rotateBy: cc3v(0.0, 30.0, 0.0)];
        
        [aNode runAction: [CCRepeatForever actionWithAction: partialRot]];
        [aNode2 runAction: [CCRepeatForever actionWithAction: partialRot2]];
        
        [self addChild:aNode];
        [self addChild:aNode2];    
        [self addLamp];
    }
}
//
//-(void) touchEvent: (uint) touchType at: (CGPoint) touchPoint {
//    
//	switch (touchType) {
//		case kCCTouchBegan:
//			[touchedNodePicker pickNodeFromTouchEvent: touchType at: touchPoint];
//            break;
//        case kCCTouchMoved:
//            break;
//        case kCCTouchEnded:
//            //If a node is not touched do nothing
//            //if (selectedNode == nil)
//            //    selectedNode = nil;
//            break;
//		default:
//			break;
//	}
//	
//}

-(void) nodeSelected: (CC3Node*) aNode byTouchEvent: (uint) touchType at: (CGPoint) touchPoint {
	LogInfo(@"You selected %@ at %@, or %@ in 2D.", aNode,
			NSStringFromCC3Vector(aNode ? aNode.globalLocation : kCC3VectorZero),
			NSStringFromCC3Vector(aNode ? [activeCamera projectNode: aNode] : kCC3VectorZero));
    
    
	// Remember the node that was selected
	selectedNode = aNode;
    
    if (selectedNode != nil){
        for (CC3Node* child in children) {
            
            if (aNode == child && aNode.tag == BASE_OBJ){
                if (firstGuess) secondGuess = YES;
                
                [selectionTracker addObject:[NSNumber numberWithInt:CORRECT]];
                [depthTracker addObject:[NSNumber numberWithFloat:depth]];
                firstGuess = YES;
            }
            else if (aNode.tag == SIMPLE_OBJ){
                [selectionTracker addObject:[NSNumber numberWithInt:INCORRECT]];
                [depthTracker addObject:[NSNumber numberWithFloat:depth]];
                firstGuess = NO;
                secondGuess = NO;
                wrongGuess = YES;
            }
        }
        
//        NSLog(@"%@", [depthTracker objectAtIndex: [depthTracker count]]);
        testCount++;
        [self nextRound];
    }
	
}
@end

