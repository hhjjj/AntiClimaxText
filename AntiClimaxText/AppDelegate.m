//
//  AppDelegate.m
//  AntiClimaxText
//
//  Created by songhojun on 11/3/13.
//  Copyright (c) 2013 songhojun. All rights reserved.
//

#import "AppDelegate.h"



@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    oldLength = 0;
}



- (IBAction)textDidEnter:(id)sender {

//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/sendText?text=%@", [_ipTextField stringValue], [self urlencode:@"\n"]]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    
//    NSLog([NSString stringWithFormat:@"%@\n",[_sendTextField stringValue]]);
//    [self sendMessage:[NSString stringWithFormat:@"%@\n",[_sendTextField stringValue]]];
    
    NSTextField *field = sender;
    [field setStringValue:@""];
    [self sendMessage:@"\n\t"];

//    oldLength = 0;
}

-(void)controlTextDidChange:(NSNotification *)obj
{
    NSLog(@"Text Changed!!");
//    NSString *string = [_sendTextField stringValue];
//    NSLog(@"string: %d, %d, %@", (int)string.length, oldLength, string);
//    
//    NSString *niceString = [self urlencode:string];
//    NSLog(@"%@",niceString);
    
//    string = [string substringFromIndex:oldLength];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/sendText?text=%@", [_ipTextField stringValue], [self urlencode:string]]];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
//    oldLength = (int)[_sendTextField stringValue].length;
    
    
//    const char *c= [string UTF8String];
//    
//    int len = (int)strlen((const char *)c);
//    if (len > 0) {
//        const char lastChar = c[len-1];
//        
//        if (lastChar == ' ') {
////            string = [string substringFromIndex:(string.length-2)];
//            string = [string substringFromIndex:(string.length-2)];
//            [self sendMessage:[NSString stringWithFormat:@"%@\t",string]];
//        }
//        else if (lastChar == NSDeleteCharacter){
//            NSLog(@"delete");
//        }
//        else{
//            string = [string substringFromIndex:(string.length-1)];
//            [self sendMessage:[NSString stringWithFormat:@"%@\t",string]];
//
//        }
//    }
    
//    for (int i = 0; i< len; i++) {
//        const char thisChar = c[i];
//        if (thisChar == ' ') {
//            [self sendMessage:[NSString stringWithFormat:@"%@\t",@" "]];
//        }
//        else{
//            
//        }
//    }
//    [self sendMessage:[NSString stringWithFormat:@"%@\t",string]];
    
    
    // check backspace (deleted key) is pressed
    // check string length of textfield
    // check Korean is typed
    // check lastChar is Korean or Others ( numbers, special charaters)
    // send string accordinlgy
    //
    
    NSString *string = [_sendTextField stringValue];
    [self sendMessage:[NSString stringWithFormat:@"%@\t",string]];
}



- (NSString *)urlencode:(NSString*)string {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = (int) strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (IBAction)startClient:(id)sender {
    
   
    
    
    
    [self initNetworkCommunication];

}

- (void) initNetworkCommunication {
    
    NSString *ipStr = [_ipTextField stringValue];
    NSString *portStr = [_portTextField stringValue];
    UInt32 port = [portStr intValue];
    

    
	CFReadStreamRef readStream;
	CFWriteStreamRef writeStream;
//	CFStreamCreatePairWithSocketToHost(NULL, (CFStringRef)@"localhost", 11999, &readStream, &writeStream);
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)ipStr, port, &readStream, &writeStream);

    // check if there's is precious connection
    // anyway we can close them gracefully?
    
    if (outputStream == Nil) {
        NSLog(@"No Previous Connection");
        outputStream = (NSOutputStream *)CFBridgingRelease(writeStream);
        [outputStream setDelegate:self];
        [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream open];

    }
    else{
        NSLog(@"let's close");
        [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [outputStream close];

        outputStream = nil;
    }
    
    if (inputStream == Nil) {
        inputStream = (NSInputStream *)CFBridgingRelease(readStream);
        [inputStream setDelegate:self];
        [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream open];

    }
    else{
        [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [inputStream close];

        inputStream = nil;
    }
	
		
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    
	NSLog(@"stream event %lu", streamEvent);
	
	switch (streamEvent) {
			
		case NSStreamEventOpenCompleted:
			NSLog(@"Stream opened");
			break;
		case NSStreamEventHasBytesAvailable:
            
			if (theStream == inputStream) {
				
				uint8_t buffer[1024];
				NSInteger len;
				
				while ([inputStream hasBytesAvailable]) {
					len = [inputStream read:buffer maxLength:sizeof(buffer)];
					if (len > 0) {
						
						NSString *output = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
						
						if (nil != output) {
                            
							NSLog(@"server said: %@", output);
							//[self messageReceived:output];
							
						}
					}
				}
			}
			break;
            
			
		case NSStreamEventErrorOccurred:
			
			NSLog(@"Can not connect to the host!");
			break;
			
		case NSStreamEventEndEncountered:
            
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            //[theStream release];
            theStream = nil;
			
			break;
		default:
			NSLog(@"Unknown event");
	}
    
}

- (void) sendMessage:(NSString*)msg {
	
//	NSString *response  = [NSString stringWithFormat:@"Test\r\n"];
    //NSString *response  = @"안녕하세요~ 우우 ㅋㅋㅋㅋㅋ ㄹㄹㄹㄹㄹㄹㄹ ㅋㅋㅋㅋ[ㅔ케ㅔㅁㄴ아리ㅏㅓ마얼\r\n";

//	NSData *data = [[NSData alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"sending:%@", msg);
    NSData *data = [[NSData alloc] initWithData:[msg dataUsingEncoding:NSUTF8StringEncoding]];

	[outputStream write:[data bytes] maxLength:[data length]];
	//inputMessageField.text = @"";
	
}


// delete key detection
- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(deleteBackward:)){
        NSLog(@"Backspace!!");
    }else if(commandSelector == @selector(moveLeft:)){
        NSLog(@"Move Left!!");
    }else if(commandSelector == @selector(moveRight:)){
        NSLog(@"Move Right!!");
    }
    
    return NO;
}


@end
