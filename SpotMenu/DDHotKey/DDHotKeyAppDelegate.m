/*
 DDHotKey -- DDHotKeyAppDelegate.m
 
 Copyright (c) Dave DeLong <http://www.davedelong.com>
 
 Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is hereby granted, provided that the above copyright notice and this permission notice appear in all copies.
 
 The software is  provided "as is", without warranty of any kind, including all implied warranties of merchantability and fitness. In no event shall the author(s) or copyright holder(s) be liable for any claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from, out of, or in connection with the software or the use or other dealings in the software.
 */

#import "DDHotKeyAppDelegate.h"
#import "DDHotKeyCenter.h"
#import <Carbon/Carbon.h>

@implementation DDHotKeyAppDelegate

@synthesize window, output;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}

- (void) addOutput:(NSString *)newOutput {
	NSString * current = [output string];
	[output setString:[current stringByAppendingFormat:@"%@\n", newOutput]];
	[output scrollRangeToVisible:NSMakeRange([[output string] length], 0)];
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent {
	[self addOutput:[NSString stringWithFormat:@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]];
	[self addOutput:[NSString stringWithFormat:@"Hotkey event: %@", hkEvent]];
}

- (void) hotkeyWithEvent:(NSEvent *)hkEvent object:(id)anObject {
	[self addOutput:[NSString stringWithFormat:@"Firing -[%@ %@]", NSStringFromClass([self class]), NSStringFromSelector(_cmd)]];
	[self addOutput:[NSString stringWithFormat:@"Hotkey event: %@", hkEvent]];
	[self addOutput:[NSString stringWithFormat:@"Object: %@", anObject]];
}

- (IBAction) registerExample1:(id)sender {
	[self addOutput:@"Attempting to register hotkey for example 1"];
	DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	if (![c registerHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:NSControlKeyMask target:self action:@selector(hotkeyWithEvent:) object:nil]) {
		[self addOutput:@"Unable to register hotkey for example 1"];
	} else {
		[self addOutput:@"Registered hotkey for example 1"];
		[self addOutput:[NSString stringWithFormat:@"Registered: %@", [c registeredHotKeys]]];
	}
}

- (IBAction) registerExample2:(id)sender {
	[self addOutput:@"Attempting to register hotkey for example 2"];
	DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	if (![c registerHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:(NSControlKeyMask | NSAlternateKeyMask) target:self action:@selector(hotkeyWithEvent:object:) object:@"hello, world!"]) {
		[self addOutput:@"Unable to register hotkey for example 2"];
	} else {
		[self addOutput:@"Registered hotkey for example 2"];
		[self addOutput:[NSString stringWithFormat:@"Registered: %@", [c registeredHotKeys]]];
	}
}

- (IBAction) registerExample3:(id)sender {
#if NS_BLOCKS_AVAILABLE
	[self addOutput:@"Attempting to register hotkey for example 3"];
	DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	int theAnswer = 42;
	DDHotKeyTask task = ^(NSEvent *hkEvent) {
		[self addOutput:@"Firing block hotkey"];
		[self addOutput:[NSString stringWithFormat:@"Hotkey event: %@", hkEvent]];
		[self addOutput:[NSString stringWithFormat:@"the answer is: %d", theAnswer]];	
	};
	if (![c registerHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:(NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask) task:task]) {
		[self addOutput:@"Unable to register hotkey for example 3"];
	} else {
		[self addOutput:@"Registered hotkey for example 3"];
		[self addOutput:[NSString stringWithFormat:@"Registered: %@", [c registeredHotKeys]]];
	}
#else
	NSRunAlertPanel(@"Blocks not available", @"This example requires the 10.6 SDK", @"OK", nil, nil);
#endif
}

- (IBAction) unregisterExample1:(id)sender {
	DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	[c unregisterHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:NSControlKeyMask];
	[self addOutput:@"Unregistered hotkey for example 1"];
}

- (IBAction) unregisterExample2:(id)sender {
	DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	[c unregisterHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:(NSControlKeyMask | NSAlternateKeyMask)];
	[self addOutput:@"Unregistered hotkey for example 2"];
}

- (IBAction) unregisterExample3:(id)sender {
	DDHotKeyCenter *c = [DDHotKeyCenter sharedHotKeyCenter];
	[c unregisterHotKeyWithKeyCode:kVK_ANSI_V modifierFlags:(NSControlKeyMask | NSAlternateKeyMask | NSCommandKeyMask)];
	[self addOutput:@"Unregistered hotkey for example 3"];
}

@end
