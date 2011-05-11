//
//  HelloWorldLayer.h
//  cocosShooter
//
//  Created by 欧 on 11/05/09.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayerColor
{
@private
    CGSize winSize;
    CCSprite *_player;
    CCSprite *_projectile;
    NSMutableArray *_targets;
    NSMutableArray *_projectiles;
    int _destroyedCount;
    BOOL _resetFlg;
    CCLabelTTF *msglabel;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void)winGame;
- (void)looseGame;
- (void)resetGame;

@end
