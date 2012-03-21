//
//  Cmput3DWorld.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


#import "CC3World.h"
#import "CC3MeshNode.h"


@interface Cmput3DWorld : CC3World {

    NSMutableArray *templateNodes;
    CC3Node *currentNode;
    NSString *currentNodeName;
    uint currentNodeIdx;
    uint nodeCount;
}

@property (nonatomic, retain) NSMutableArray *templateNodes;

//Creates an array with some template objects that should be copied and
//placed on the screen via [self addChild:aNode]
-(void)initializeTemplates;

//this sets the initial object to 1 of 3 objects in the template array
//this is based on an index that is passed by the menu layer
-(void)setSelectedObject:(uint) kname;

//need to find equal spacing for for every node that is added
//i.e. 2 nodes get placed at a standard distance, 3 equally and so on
-(void)increaseNodeByOne;

@end
