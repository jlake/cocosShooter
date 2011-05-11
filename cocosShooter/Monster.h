//
//  Monster.h
//  cocosShooter
//
//  Created by 欧 on 11/05/10.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Monster : CCSprite {
@private
    int _curHp;
    int _minMoveDuration;
    int _maxMoveDuration;
}

@property (nonatomic, assign) int hp;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;

@end

@interface WeakAndFastMonster : Monster {
@private
}
+(id)monster;
@end

@interface StrongAndSlowMonster : Monster {
@private
}
+(id)monster;
@end
