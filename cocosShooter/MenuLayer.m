//
//  MenuLayer.m
//  cocosShooter
//
//  Created by 欧 on 11/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MenuLayer.h"
#import "HelloWorldLayer.h"

@implementation MenuLayer

+ (id)scene
{
    CCScene *scene = [CCScene node];
    MenuLayer *layer = [MenuLayer node];
    [scene addChild:layer];
    return scene;
}

-(void) setUpMenus
{
	CCMenuItemImage * menuItem1 = [CCMenuItemImage itemFromNormalImage:@"MenuItem1.png"
                                                         selectedImage:@"MenuItem1_on.png"
                                                                target:self
                                                              selector:@selector(newGame:)];
    
	CCMenuItemImage * menuItem2 = [CCMenuItemImage itemFromNormalImage:@"MenuItem2.png"
                                                         selectedImage:@"MenuItem2_on.png"
                                                                target:self
                                                              selector:@selector(resumeGame:)];
    
    
	CCMenuItemImage * menuItem3 = [CCMenuItemImage itemFromNormalImage:@"MenuItem3.png"
                                                         selectedImage:@"MenuItem3_on.png"
                                                                target:self
                                                              selector:@selector(showOptions:)]; 
    
    CCMenuItemImage * menuItem4 = [CCMenuItemImage itemFromNormalImage:@"MenuItem4.png"
                                                         selectedImage:@"MenuItem4_on.png"
                                                                target:self
                                                              selector:@selector(showGuide:)]; 
    
	CCMenu * myMenu = [CCMenu menuWithItems:menuItem1, menuItem2, menuItem3, menuItem4, nil];
    
	[myMenu alignItemsVertically];
    
	[self addChild:myMenu];
}

- (id)init
{
	if((self=[super initWithColor:ccc4(255, 192, 128, 255)])) {
        [self setUpMenus];
	}
	return self;
}


- (void) newGame: (CCMenuItem  *) menuItem 
{
	// Run the intro Scene
	[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
}

- (void) resumeGame: (CCMenuItem  *) menuItem 
{
	NSLog(@"The second menu was called");
}

- (void) showOptions: (CCMenuItem  *) menuItem 
{
	NSLog(@"The third menu was called");
}

- (void) showGuide: (CCMenuItem  *) menuItem 
{
	NSLog(@"The fourth menu was called");
}


@end
