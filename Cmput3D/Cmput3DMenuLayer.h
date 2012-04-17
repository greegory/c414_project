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

//testing models - should be removed
#define kBoxName				@"Box"
#define kBeachBallName			@"BeachBall"
#define kDieCubeName			@"Cube"

#define kBallsFileName			@"Balls.pod"
#define kMascotPODFile			@"cocos3dMascot.pod"
#define kDieCubePODFile			@"DieCube.pod"

// Model names
#define kBuddhaName0            @"buddha-2983v"
#define kBuddhaName1            @"buddha-2983v-298"
#define kBuddhaName2            @"buddha-2983v-571"
#define kBuddhaName3            @"buddha-2983v-894"
#define kBuddhaName4            @"buddha-2983v-1192"
#define kBuddhaName5            @"buddha-2983v-1490"
#define kBuddhaName6            @"buddha-2983v-1788"
#define kBuddhaName7            @"buddha-2983v-2086"
#define kBuddhaName8            @"buddha-2983v-2384"
#define kBuddhaName9            @"buddha-2983v-2682"
#define kBuddhaName10           @"buddha-2983v-2903"

#define kDinoName0              @"dinosaur5000v"
#define kDinoName1              @"dinosaur4000v"
#define kDinoName2              @"dinosaur3500v"
#define kDinoName3              @"dinosaur3000v"
#define kDinoName4              @"dinosaur2500v"
#define kDinoName5              @"dinosaur2000v"
#define kDinoName6              @"dinosaur1500v"
#define kDinoName7              @"dinosaur1000v"
#define kDinoName8              @"dinosaur500v"
#define kDinoName9              @"dinosaur100v"

//#define kBunnyName0             @"bunny-35947v"
//#define kBunnyName1             @"bunny-30000v"
//#define kBunnyName2             @"bunny-20000v"
#define kBunnyName3             @"bunny-10000v"
#define kBunnyName4             @"bunny-5000v"
#define kBunnyName5             @"bunny-4500v"
#define kBunnyName6             @"bunny-4000v"
#define kBunnyName7             @"bunny-3500v"
#define kBunnyName8             @"bunny-3000v"
#define kBunnyName9             @"bunny-2500v"
#define kBunnyName10            @"bunny-2000v"
#define kBunnyName11            @"bunny-1500v"
#define kBunnyName12            @"bunny-1000v"
#define kBunnyName13            @"bunny-500v"
#define kBunnyName14            @"bunny-100v"

// POD File names
#define kBuddhaPODFile0         @"buddha-2983v.pod"
#define kBuddhaPODFile1         @"buddha-2983v-298.pod"
#define kBuddhaPODFile2         @"buddha-2983v-571.pod"
#define kBuddhaPODFile3         @"buddha-2983v-894.pod"
#define kBuddhaPODFile4         @"buddha-2983v-1192.pod"
#define kBuddhaPODFile5         @"buddha-2983v-1490.pod"
#define kBuddhaPODFile6         @"buddha-2983v-1788.pod"
#define kBuddhaPODFile7         @"buddha-2983v-2086.pod"
#define kBuddhaPODFile8         @"buddha-2983v-2384.pod"
#define kBuddhaPODFile9         @"buddha-2983v-2682.pod"
#define kBuddhaPODFile10        @"buddha-2983v-2903.pod"

#define kDinoPODFile0           @"dinosaur5000v.pod"
#define kDinoPODFile1           @"dinosaur4000v.pod"
#define kDinoPODFile2           @"dinosaur3500v.pod"
#define kDinoPODFile3           @"dinosaur3000v.pod"
#define kDinoPODFile4           @"dinosaur2500v.pod"
#define kDinoPODFile5           @"dinosaur2000v.pod"
#define kDinoPODFile6           @"dinosaur1500v.pod"
#define kDinoPODFile7           @"dinosaur1000v.pod"
#define kDinoPODFile8           @"dinosaur500v.pod"
#define kDinoPODFile9           @"dinosaur100v.pod"

//#define kBunnyPODFile0          @"bunny-35947v.pod"
//#define kBunnyPODFile1          @"bunny-30000v.pod"
//#define kBunnyPODFile2          @"bunny-20000v.pod"
#define kBunnyPODFile3          @"bunny-10000v.pod"
#define kBunnyPODFile4          @"bunny-5000v.pod"
#define kBunnyPODFile5          @"bunny-4500v.pod"
#define kBunnyPODFile6          @"bunny-4000v.pod"
#define kBunnyPODFile7          @"bunny-3500v.pod"
#define kBunnyPODFile8          @"bunny-3000v.pod"
#define kBunnyPODFile9          @"bunny-2500v.pod"
#define kBunnyPODFile10         @"bunny-2000v.pod"
#define kBunnyPODFile11         @"bunny-1500v.pod"
#define kBunnyPODFile12         @"bunny-1000v.pod"
#define kBunnyPODFile13         @"bunny-500v.pod"
#define kBunnyPODFile14         @"bunny-100v.pod"

@interface Cmput3DMenuLayer : CC3Layer {
}

//returns the scene that is
+(CCScene*) scene;

@end
