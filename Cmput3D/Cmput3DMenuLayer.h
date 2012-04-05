//
//  Cmput3DMenuLayer.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright 2012 Greg Jaciuk . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CC3Layer.h"
#import "Cmput3DMenuLayer.h"
#import "Cmput3DLayer.h"
#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"


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

//returns the scene that is
+(CCScene*) scene;

@end
