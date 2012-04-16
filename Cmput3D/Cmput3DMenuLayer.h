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

#define kDinoName0              @"dinsaur5000v"
#define kDinoName1              @"dinsaur4000v"
#define kDinoName2              @"dinsaur3500v"
#define kDinoName3              @"dinsaur3000v"
#define kDinoName4              @"dinsaur2500v"
#define kDinoName5              @"dinsaur2000v"
#define kDinoName6              @"dinsaur1500v"
#define kDinoName7              @"dinsaur1000v"
#define kDinoName8              @"dinsaur500v"
#define kDinoName9              @"dinsaur100v"

#define kBunnyName0             @"bunny-35947v"
#define kBunnyName1             @"bunny-30000v"
#define kBunnyName2             @"bunny-20000v"
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

#define kDinoPODFile0           @"dinsaur5000v.pod"
#define kDinoPODFile1           @"dinsaur4000v.pod"
#define kDinoPODFile2           @"dinsaur3500v.pod"
#define kDinoPODFile3           @"dinsaur3000v.pod"
#define kDinoPODFile4           @"dinsaur2500v.pod"
#define kDinoPODFile5           @"dinsaur2000v.pod"
#define kDinoPODFile6           @"dinsaur1500v.pod"
#define kDinoPODFile7           @"dinsaur1000v.pod"
#define kDinoPODFile8           @"dinsaur500v.pod"
#define kDinoPODFile9           @"dinsaur100v.pod"

#define kBunnyPODFile0          @"bunny-35947v"
#define kBunnyPODFile1          @"bunny-30000v"
#define kBunnyPODFile2          @"bunny-20000v"
#define kBunnyPODFile3          @"bunny-10000v"
#define kBunnyPODFile4          @"bunny-5000v"
#define kBunnyPODFile5          @"bunny-4500v"
#define kBunnyPODFile6          @"bunny-4000v"
#define kBunnyPODFile7          @"bunny-3500v"
#define kBunnyPODFile8          @"bunny-3000v"
#define kBunnyPODFile9          @"bunny-2500v"
#define kBunnyPODFile10         @"bunny-2000v"
#define kBunnyPODFile11         @"bunny-1500v"
#define kBunnyPODFile12         @"bunny-1000v"
#define kBunnyPODFile13         @"bunny-500v"
#define kBunnyPODFile14         @"bunny-100v"

@interface Cmput3DMenuLayer : CC3Layer {
}

//returns the scene that is
+(CCScene*) scene;

@end
