//
//	WLANBSSIDRule.m
//	ControlPlane
//
//	Created by David Jennes on 24/09/11.
//	Copyright 2011. All rights reserved.
//

#import "WLANBSSIDRule.h"
#import "WLANSource.h"

@implementation WLANBSSIDRule

registerRuleType(WLANBSSIDRule)

- (id) init {
	self = [super init];
	ZAssert(self, @"Unable to init super '%@'", NSStringFromClass(super.class));
	
	m_bssid = nil;
	
	return self;
}

#pragma mark - Source observe functions

- (void) networksChangedWithOld: (NSArray *) oldList andNew: (NSArray *) newList {
	BOOL found = NO;
	
	// loop through services
	for (NSDictionary *item in newList) {
		found = [m_bssid isEqualToString: [item valueForKey: @"BSSID"]];
		
		if (found)
			break;
	}
	
	self.match = found;
}

#pragma mark - Required implementation of 'Rule' class

- (NSString *) name {
	return NSLocalizedString(@"Wi-Fi BSSID", @"Rule type");
}

- (NSString *) category {
	return NSLocalizedString(@"Network", @"Rule category");
}

- (void) beingEnabled {
	[SourcesManager.sharedSourcesManager registerRule: self toSource: @"WLANSource"];
	
	// currently a match?
	WLANSource *source = (WLANSource *) [SourcesManager.sharedSourcesManager getSource: @"WLANSource"];
	[self networksChangedWithOld: nil andNew: source.networks];
}

- (void) beingDisabled {
	[SourcesManager.sharedSourcesManager unRegisterRule: self fromSource: @"WLANSource"];
}

- (void) loadData {
	m_bssid = [self.data objectForKey: @"parameter"];
}

- (NSArray *) suggestedValues {
	WLANSource *source = (WLANSource *) [SourcesManager.sharedSourcesManager getSource: @"WLANSource"];
	NSMutableArray *result = [[NSArray new] autorelease];
	
	// loop through networks
	for (NSDictionary *item in source.networks) {
		NSString *description = [NSString stringWithFormat: @"%@ (%@)",
								 [item valueForKey: @"BSSID"],
								 [item valueForKey: @"SSID"]];
		
		[result addObject: [NSDictionary dictionaryWithObjectsAndKeys:
							[item valueForKey: @"BSSID"], @"parameter",
							description, @"description", nil]];
	}
	
	return result;
}

@end