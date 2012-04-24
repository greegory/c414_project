//
//  Cmput3DAppDelegate.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CCNodeController.h"
#import "CC3World.h"

@interface Cmput3DAppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow* window;
	CCNodeController* viewController;
}

@property (nonatomic, retain) UIWindow* window;

@end
