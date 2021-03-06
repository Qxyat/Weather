//
//  AppDelegate.h
//  Weather
//
//  Created by 邱鑫玥 on 15/11/7.
//  Copyright © 2015年 qiu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <ViewDeck.h>
#import "WXApi.h"
@interface AppDelegate : UIResponder <UIApplicationDelegate,WXApiDelegate>
{
    enum WXScene wxScene;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) IIViewDeckController *deckViewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) sendTextContent;
- (void)setWXScene:(NSInteger)type;
@end

