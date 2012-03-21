//
//  Cmput3DMenuLayer.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CC3Layer.h"


// Model names
#define kBoxName				@"Box"
#define kBeachBallName			@"BeachBall"
#define kDieCubeName			@"Cube"
#define kMascotName				@"cocos2d_3dmodel_unsubdivided"

// File names
#define kBallsFileName			@"Balls.pod"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"


@interface Cmput3DMenuLayer : CC3Layer {
}

//returns the scene that is. Based on the cocos2d layer scheme
+(CCScene*)scene;

@end
