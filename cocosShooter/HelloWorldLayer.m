//
//  HelloWorldLayer.m
//  cocosShooter
//
//  Created by 欧 on 11/05/09.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "Monster.h"
#import "SimpleAudioEngine.h"

// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(160, 160, 255, 255)])) {
        self.isTouchEnabled = YES;
        
        winSize = [[CCDirector sharedDirector] winSize];
        //player = [CCSprite spriteWithFile:@"Player.png" rect:CGRectMake(0, 0, 27, 40)];
        _player = [[CCSprite spriteWithFile:@"Player2.png"] retain];
        _player.position = ccp(_player.contentSize.width/2, winSize.height/2);
        [self addChild:_player];
        
        _targets = [[NSMutableArray alloc] init];
        _projectiles = [[NSMutableArray alloc] init];
        
        [self schedule:@selector(spawnTarget:) interval:1.0];
        [self schedule:@selector(update:)];
        
        //[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"background-music-aac.caf"];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"bgm01.mp3"];
        
        msglabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:32];
        msglabel.color = ccc3(0, 0, 0);
        msglabel.position = ccp(winSize.width/2, winSize.height/2);
        msglabel.visible = NO;
        [self addChild:msglabel];
	}
	return self;
}

- (void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self
                                                     priority:0
                                              swallowsTouches:YES];
}

- (void)spriteMoveFinished:(CCSprite *)sprite {
    [self removeChild:sprite cleanup:YES];

    if(sprite.tag == 1) {
        //NSLog(@"remove target");
        [_targets removeObject:sprite];

        //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene]];
        [self looseGame];
        
    } else if(sprite.tag == 2) {
        //NSLog(@"remove projectile");
        [_projectiles removeObject:sprite];
    }
}

- (void)spawnTarget: (ccTime)dt
{
    if(_resetFlg) return;
    
    //CCSprite *target = [CCSprite spriteWithFile:@"Target.png" rect:CGRectMake(0, 0, 27, 40)];
    Monster *target = nil;
    if((arc4random() % 2) == 0) {
        target = [WeakAndFastMonster monster];
    } else {
        target = [StrongAndSlowMonster monster];
    }
    
    int minY = target.contentSize.height/2;
    int maxY = winSize.height - target.contentSize.height/2;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    target.position = ccp(winSize.width + (target.contentSize.width/2), actualY);
    [self addChild:target];
    
    target.tag = 1;
    [_targets addObject:target];
    
    int minDuration = target.minMoveDuration;
    int maxDuration = target.maxMoveDuration;
    int rangeDuration = maxDuration - minDuration;
    int actualDuration = (arc4random() % rangeDuration) + minDuration;
    
    id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(-target.contentSize.width/2, actualY)];
    id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
    [target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
}

- (BOOL) ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    return YES;
}

- (void) ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (_resetFlg || _projectile != nil) return;
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
    //location = [[CCDirector sharedDirector] convertToGL:location];
    
    CGPoint startPos = [_player position];
    //startPos.x += _player.contentSize.width/2;
    
    //NSLog(@"startPos.x = %f startPos.y = %f", startPos.x, startPos.y);
    //NSLog(@"location.x = %f location.y = %f", location.x, location.y);
    
    int offX = location.x - startPos.x;
    int offY = location.y - startPos.y;
    
    if (offX <= 0) {
        return;
    }
    
    //CCSprite *_projectile = [CCSprite spriteWithFile:@"Projectile.png" rect:CGRectMake(0, 0, 20, 20)];
    _projectile = [[CCSprite spriteWithFile:@"Projectile2.png"] retain];
    _projectile.position = startPos;
    //[[SimpleAudioEngine sharedEngine] playEffect:@"pew-pew-lei.caf"];
    [[SimpleAudioEngine sharedEngine] playEffect:@"se01.aif"];

 
    CGPoint realDest;
    realDest.x = winSize.width + (_projectile.contentSize.width/2);
    realDest.y = _projectile.position.y + (realDest.x * offY / offX);
    //NSLog(@"realDest.x = %f realDest.y = %f", realDest.x, realDest.y);

    float angleRad = atanf(realDest.y/realDest.x);
    float cocosAngle = -1 * CC_RADIANS_TO_DEGREES(angleRad);
    //_player.rotation = cocosAngle;
    float rotateDuration = fabs(angleRad * M_PI * 0.1);
    [_player runAction:[CCSequence actions:[CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                        [CCCallFunc actionWithTarget:self selector:@selector(finishShoot)],
                        nil]];
    
    float distance = ccpDistance(realDest, startPos);
    float speed = 480/1; //480pixels/1sec
    float realMoveDuration = distance/speed;

    [_projectile runAction:[CCSequence 
                           actions:[CCMoveTo actionWithDuration:realMoveDuration position:realDest],
                           [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)],
                           nil]];
    
    _projectile.tag = 2;
}

- (void) finishShoot
{
    //NSLog(@"finishShoot");
    [self addChild:_projectile];
    [_projectiles addObject:_projectile];
    
    [_projectile release];
    _projectile = nil;
}

- (void) update:(ccTime)dt {
    if(_resetFlg) return;
    
    NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
    NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
    for (CCSprite *projectile in _projectiles) {
        CGRect projectileRect = CGRectMake(projectile.position.x - projectile.contentSize.width/2,
                                           projectile.position.y - projectile.contentSize.height/2,
                                           projectile.contentSize.width,
                                           projectile.contentSize.height);
        for(CCSprite *target in _targets) {
            CGRect targetRect = CGRectMake(target.position.x - target.contentSize.width/2,
                                           target.position.y - target.contentSize.height/2,
                                           target.contentSize.width,
                                           target.contentSize.height);
            if(CGRectIntersectsRect(projectileRect, targetRect)) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"damage.wav"];
                [projectilesToDelete addObject:projectile];

                //[targetsToDelete addObject:target];
                Monster *monster = (Monster *)target;
                monster.hp--;
                //NSLog(@"monster.hp=%d", monster.hp);
                if(monster.hp <= 0) {
                    [[SimpleAudioEngine sharedEngine] playEffect:@"explode.wav"];
                    CCParticleSystem * emitter = [CCParticleExplosion node];
                    emitter.position = [monster position];
                    emitter.life = 0.1f;
                    emitter.duration = 0.1f;
                    emitter.lifeVar = 0.1f;
                    emitter.totalParticles = 100;
                    [self addChild:emitter];

                    [targetsToDelete addObject:target];
                }
            }
        }
        
    }

    for(CCSprite *projectile in projectilesToDelete) {
        [_projectiles removeObject:projectile];
        [self removeChild:projectile cleanup:YES];
    }
    [projectilesToDelete release];

    for(CCSprite *target in targetsToDelete) {
        [_targets removeObject:target];
        [self removeChild:target cleanup:YES];
        _destroyedCount++;
    }
    [targetsToDelete release];
    
    if(_destroyedCount > 10) {
        //NSLog(@"Load GameOver Scene");
        _destroyedCount = 0;
        [self winGame];
    }
}

- (void)winGame
{
    [self resetGame];

    [[SimpleAudioEngine sharedEngine] playEffect:@"se09.mp3"];
    [msglabel setString:@"You Win!"];
    [msglabel setVisible:YES];
    
    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3],
                     [CCCallFunc actionWithTarget:self selector:@selector(resetGameDone)], 
                     nil]];
}

- (void)looseGame
{
    /*
    NSLog(@"looseGame");
    //[[CCDirector sharedDirector] replaceScene:[GameOverScene scene]];
    CCScene *nextScene = [CCScene node];
    GameOverScene *layer = [GameOverScene node];
    [layer setLabelString:@"You Loose! :["];
    [nextScene addChild: layer];
    [[CCDirector sharedDirector] replaceScene:nextScene];
     */
    [self resetGame];

    [msglabel setString:@"You Loose :["];
    [msglabel setVisible:YES];

    [self runAction:[CCSequence actions:[CCDelayTime actionWithDuration:3],
                     [CCCallFunc actionWithTarget:self selector:@selector(resetGameDone)], 
                     nil]];

}

- (void) resetGame
{
    _resetFlg = true;
    for (CCSprite *projectile in _projectiles) {
        [self removeChild:projectile cleanup:YES];
    }
    [_projectiles removeAllObjects];
    
    for (CCSprite *target in _targets) {
        [self removeChild:target cleanup:YES];
    }
    [_targets removeAllObjects];
    
    _destroyedCount = 0;
}

- (void)resetGameDone
{
    NSLog(@"resetGameDone");
    [msglabel setString:@""];
    [msglabel setVisible:NO];
    _resetFlg = false;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
    [_player release];
    _player = nil;

    [_targets release];
    _targets = nil;

    [_projectiles release];
    _projectiles = nil;

	[super dealloc];
}
@end
