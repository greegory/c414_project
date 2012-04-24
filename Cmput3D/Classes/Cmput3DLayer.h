//
//  Cmput3DLayer.h
//  Cmput3D
//
//  Created by Greg Jaciuk on 12-03-17.
//  Copyright Greg Jaciuk 2012. All rights reserved.
//

#import "CC3Layer.h"

#define BTN_OFFSET_LEFT     40
#define BTN_OFFSET_TOP      20

@interface Cmput3DLayer : CC3Layer {

    CCMenuItem *backButton;
    CCMenuItem *plusButton;
    
    CCMenuItem *leftButton;
    CCMenuItem *rightButton;
    
    CGSize windowSize; 
    
}

@end
