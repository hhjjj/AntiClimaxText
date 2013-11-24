//
//  AppDelegate.h
//  AntiClimaxText
//
//  Created by songhojun on 11/3/13.
//  Copyright (c) 2013 songhojun. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSStreamDelegate, NSApplicationDelegate, NSTextFieldDelegate>{
//    __weak NSTextField *_sendTextField;
//    __weak NSTextField *_ipTextField;
    int oldLength;
    
//
    NSInputStream	*inputStream;
    NSOutputStream	*outputStream;
    BOOL isClientStarted;

}
//@property (weak) NSTextField *_sendTextField;
//@property (weak) NSTextField *_ipTextField;
@property (weak) IBOutlet NSTextField *sendTextField;
@property (weak) IBOutlet NSTextField *ipTextField;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *portTextField;
@property (weak) IBOutlet NSTextField *userIDTextField;
@property (weak) IBOutlet NSButton *startButton;

// 이것의 목적은 무엇인가?
//@property (nonatomic, retain) NSInputStream *inputStream;
//@property (nonatomic, retain) NSOutputStream *outputStream;
- (IBAction)startClient:(id)sender;

- (void) initNetworkCommunication;
- (void) sendMessage:(NSString*)msg;

@end
