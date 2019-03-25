#pragma mark - Push notificaiton methods

/*
 1. Import UserNotifications.h
#import <UserNotifications/UserNotifications.h>
 2. Include UNUserNotificationCenterDelegate delegate
@interface AppDelegate ()<UNUserNotificationCenterDelegate>
 3. Call from didFinishLaunch method
// Register for push notification (make sure to register below Firebase configure since FCM is used for push notification)
[self registerForRemoteNotifications];
 4.
 Enable Push notification under "Capabilities"
 5.
 Enable Background modes under "Capabilities" & choose "Push notification" in it.
 6.
 Add following codes
*/

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, deviceToken);
    NSString *token = [self parseDeviceTokenData:deviceToken];
    [AnalyticsHelper trackUserProperty:token forName:FA_PROP_TOKEN];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"%s", __PRETTY_FUNCTION__);
    completionHandler(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge);
    [self handleRemoteNotification:[UIApplication sharedApplication] userInfo:notification.request.content.userInfo];
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s ~ User Info : %@", __PRETTY_FUNCTION__, response.notification.request.content.userInfo);
    completionHandler();
    [self handleRemoteNotification:[UIApplication sharedApplication] userInfo:response.notification.request.content.userInfo];
}

- (NSString *)parseDeviceTokenData:(NSData *)deviceToken {
    NSString *tokenString = [deviceToken description];
    tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Push Notification tokenstring is %@",tokenString);
    return tokenString;
}

- (void)registerForRemoteNotifications {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10.0")) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error){
            
            if(!error){
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [[UIApplication sharedApplication] registerForRemoteNotifications];
                });
            }
        }];
    } else { // Old versions
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
}

- (void)handleRemoteNotification:(UIApplication *)application userInfo:(NSDictionary *)remoteNotif {
    NSLog(@"%s : %@", __PRETTY_FUNCTION__, remoteNotif);
    // Handle Click of the Push Notification here like redirecting to specific screen of the app here.
    // You can write a code to redirect user to specific screen of the app here….
}
