//
//  Cmput3DAppDelegate.m
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk 2012. All rights reserved.
//

#import "cocos2d.h"

#import "Cmput3DAppDelegate.h"
#import "Cmput3DLayer.h"
#import "Cmput3DWorld.h"
#import "Cmput3DMenuLayer.h"
#import "CC3EAGLView.h"

@implementation Cmput3DAppDelegate

@synthesize window;

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[viewController release];
	[super dealloc];
}

- (void) applicationDidFinishLaunching:(UIApplication*)application {
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	CCDirector *director = [CCDirector sharedDirector];

	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	[director setDeviceOrientation:kCCDeviceOrientationPortrait];

	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:YES];
	
	// Alloc & init the EAGLView
	//  1. Transparency (alpha blending), and device camera overlay requires an alpha channel,
	//     so must use RGBA8 color format. If not using device overlay or alpha blending
	//     (transparency) in any 3D or 2D graphics this can be changed to kEAGLColorFormatRGB565.
	//	2. 3D rendering requires a depth format of 16 bit.
	//  3. For highest performance, multisampling antialiasing is disabled by default.
	//     To enable multisampling antialiasing, set the multiSampling parameter to YES.
	//     You can also change the number of samples used with the numberOfSamples parameter.
	//  4. If you are using BOTH multisampling antialiasing AND node picking from touch events,
	//     use the CC3EAGLView class instead of EAGLView. When using EAGLView, multisampling
	//     antialiasing interferes with the color-testing algorithm used for touch-event node picking.
	EAGLView *glView = [CC3EAGLView viewWithFrame: [window bounds]
									  pixelFormat: kEAGLColorFormatRGBA8
									  depthFormat: GL_DEPTH_COMPONENT16_OES
							   preserveBackbuffer: NO
									   sharegroup: nil
									multiSampling: NO
								  numberOfSamples: 4];
	
	// Turn on multiple touches if needed
	[glView setMultipleTouchEnabled: NO];
	
	// attach the openglView to the director
	[director setOpenGLView:glView];
						
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
						
	
	// make the GL view a child of the main window and present it
	[window addSubview: glView];
	[window makeKeyAndVisible];

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
    [[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
    
	[[CCDirector sharedDirector] runWithScene: [Cmput3DMenuLayer scene]];
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[viewController release];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

@end
