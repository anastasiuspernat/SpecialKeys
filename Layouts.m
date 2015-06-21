//
//  Layouts.m
//  SpecialKeys
//
//  Created by Anastasius on 26/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Layouts.h"
#import "basics.h"
#import "LogDebug.h"


@implementation Layouts
@synthesize currentLayoutTitle;
@synthesize mySpecialKeys;

+ (Layouts *)initLayoutsWithSpecialKeysCodes:(OrderedDictionary *)od
{
	Layouts *layouts = [[Layouts alloc] init];
	layouts.mySpecialKeys = [[OrderedDictionary alloc] init];
	
	[layouts initSpecialKeys:od];

	if (![layouts loadFromDisk])
	{
		[layouts initWithDefaultData];
	}
	return layouts;
}




- (OrderedDictionary *)getCurrentLayout
{
	return currentLayout;
}

- (void)setCurrentLayout:(OrderedDictionary *)newCurrentLayout
{
	currentLayout = newCurrentLayout;
}

- (OrderedDictionary *)getLayouts
{
	return _layouts;
}

- (void)setLayouts:(OrderedDictionary *)newLayouts
{
	_layouts = newLayouts;
}

- (void)initWithDefaultData
{
		
	NSMutableDictionary * d = [[[NSBundle bundleForClass:[self class]] infoDictionary] 
							 objectForKey:@"defaultLayouts"];
	OrderedDictionary * od = [OrderedDictionary dictionaryWithCapacity:0];
	
	
	[od addEntriesFromDictionary:d];
	
	od = [od objectForKey:@"ALL"];
	
	logDebug(@"**************** %@",[[d allKeys] objectAtIndex:0]);
	
	[self setLayouts:od];
	
	
	logDebug(@"**************** %@",[[d allKeys] objectAtIndex:0]);

	
    NSArray *lKeys = [[self getLayouts] allKeys];
	self.currentLayoutTitle = [lKeys objectAtIndex:0];

	
	[self rebuildCurrentLayoutFromTitle:[lKeys objectAtIndex:0]];
	
	
	
   // return layouts;
}

- (OrderedDictionary *)getRawLayoutByTitle:(NSString *)title
{
	return [[self getLayouts] objectForKey:title];	
}

- (void)rebuildCurrentLayoutFromTitle:(NSString *)title
{
	OrderedDictionary *od = [[OrderedDictionary alloc] init];
	[od addEntriesFromDictionary:[[self getLayouts] objectForKey:title]];
	logDebug(@"SpecialKeys: rebuildCurrentLayoutFromTitle: %@",title);
	NSSortDescriptor *sort;
	
	NSMutableArray *keys = [od allKeys];
	sort=[[[NSSortDescriptor alloc] initWithKey:nil ascending:YES]autorelease];
	
	NSArray *sortedDesc = [NSArray arrayWithObject:sort];
	[keys sortUsingDescriptors:sortedDesc];
	
	OrderedDictionary *od2 = [[OrderedDictionary alloc] init];
	for (int i=0;i<[keys count];i++)
	{
		NSString *key = [keys objectAtIndex:i];
		NSString *action = [od objectForKey:key];
		key = [[key componentsSeparatedByString:@","] objectAtIndex:1];
		[od2 insertObject:action forKey:key atIndex:i];
		
	}
	
	[self setCurrentLayout:od2];
}

- (NSString *)filesPath
{
	return [@"~/Library/Preferences/SpecialKeys/"
			stringByExpandingTildeInPath];
}

- (bool)loadFromDisk
{
	NSString *path = [self filesPath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		NSArray * dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
		NSArray * onlyXMLs = [dirContents filteredArrayUsingPredicate:[NSPredicate 
																  predicateWithFormat:@"self ENDSWITH[c] '.xml'"]];
		OrderedDictionary * layoutsFromFile = [[OrderedDictionary alloc] init];
		if ([onlyXMLs count]>0)
		{
			NSEnumerator * enumeratorXMLs = [onlyXMLs objectEnumerator];
			int i = 0;
			NSString * fileName;
			while(fileName = [enumeratorXMLs nextObject])
			{
				logDebug(@"SpecialKeys: loading layout from file: %@",fileName);
				NSString * filePath = [NSString stringWithFormat:@"%@/%@",path,fileName];
				NSMutableDictionary * layoutInfo = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
				if (layoutInfo && [layoutInfo count]>0)
				{
					NSString *info;
					info = [layoutInfo objectForKey:@"version"];
					if (info && [info isEqualToString:@"1.0"])
					{
						info = [layoutInfo objectForKey:@"Bundle"];
						if (info && [info isEqualToString:@"SpecialKeys"])
						{
							OrderedDictionary * entries = [[OrderedDictionary alloc] init]; 
							[entries addEntriesFromDictionary:[layoutInfo objectForKey:@"layout"]];
							logDebug(@"SpecialKeys: inserting layout: %@",fileName);
							[layoutsFromFile insertObject:entries forKey:[layoutInfo objectForKey:@"name"] atIndex:i];
							i++;
						}
					}
				}
			}
		} 
		NSArray * keys = [layoutsFromFile allKeys];
		if ([keys count]==0)
		return false; else
					{
						NSString * filePath = [NSString stringWithFormat:@"%@/%@",path,@"currentlayout"];
						NSString * currentLayoutData = [NSString stringWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:nil];
					    if (currentLayoutData && ![currentLayoutData isEqualToString:@""])
						{
							NSRange sub = [currentLayoutData rangeOfString:@"@end"];
							logDebug(@"SpecialKeys: location: %d",sub.location);
							
							if (sub.location != NSNotFound)
							{
								logDebug(@"SpecialKeys: loading current layout from currentlayout");
								currentLayoutTitle = [currentLayoutData substringWithRange:NSMakeRange(0,sub.location)];
							}else
								currentLayoutTitle = [[layoutsFromFile allKeys] objectAtIndex:0];
						} else 
						{
							currentLayoutTitle = [[layoutsFromFile allKeys] objectAtIndex:0];
						}
						logDebug(@"SpecialKeys: set current layout: %@",currentLayoutTitle);
						_layouts = layoutsFromFile;
						logDebug(@"SpecialKeys: rebuilding current layout: %@",currentLayoutTitle);
						if ([layoutsFromFile objectForKey:currentLayoutTitle]==nil)
							currentLayoutTitle = [[layoutsFromFile allKeys] objectAtIndex:0];
						[self rebuildCurrentLayoutFromTitle:currentLayoutTitle];
						[self saveToDisk];
						return true;
					}
	} else
	return false;
}

- (NSString *)fileNameFromLayout:(NSString *)name
{
	NSString *result = [name stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
	return [NSString stringWithFormat:@"%@.xml", [result stringByReplacingOccurrencesOfString:@"\\" withString:@"_"]];
}

- (void)initSpecialKeys:(NSMutableDictionary *)specialKeys
{
	mySpecialKeys = [[OrderedDictionary alloc] init];
	[mySpecialKeys initWithDictionary:specialKeys];
}




- (int)decodeNumber:(NSString*)str
{
	int result;
	result = [str intValue];
	if (result <= 0)
	{
		unsigned int resultU;
		NSScanner *scanner;
		//logDebug(@"SCANNING: %@",str);
		scanner = [NSScanner scannerWithString: str];
		
		[scanner scanHexInt: &resultU];
		//logDebug(@"SCANNED: %d",resultU);
		
		return (int)resultU;
	} else {
		return result;
	}

}



- (int)decodeSpecialKey:(NSString *)specialKeyName
{
	NSString *s = [mySpecialKeys objectForKey:[specialKeyName substringWithRange:NSMakeRange(1,[specialKeyName length]-2)]];
	if (s && ![s isEqualToString:@""])
		return [self decodeNumber:s]; else return 0;
}

- (NSString *)encodeSpecialKey:(int)adbCode
{
	logDebug(@"SpecialKeys: encodeSpecialKey: 0x%x",adbCode);
	if (adbCode == 0) return @"undefined";
	NSArray *keys = [mySpecialKeys allKeys];
	int i;
	for (i=0;i<[keys count];i++)
	{
		NSString *key = [keys objectAtIndex:i];
		int adbSpecialKeyCode = [self decodeNumber:[mySpecialKeys objectForKey:key]];
		if (adbSpecialKeyCode == adbCode)
			return [NSString stringWithFormat:@"{%@}",key];
	}
	return [NSString stringWithFormat:@"0x%x", adbCode];
}

- (void)saveToDisk
{
    //NSMutableDictionary * layouts;
	NSString *path = [self filesPath];
	if (![[NSFileManager defaultManager] fileExistsAtPath:path])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
	}
	
	logDebug(@"Special keys: saving layouts...");
	
	OrderedDictionary *layouts = [self getLayouts];
	logDebug(@"Special keys: saving layouts: %d",[layouts count]);
	NSMutableArray *keys = [layouts allKeys];
	int i = 0;
	NSString *fileName;
	for (i=0;i<[keys count];i++)
	{
		NSString *key = [keys objectAtIndex:i];
		logDebug(@"Special keys: saving layout: %@",key);
		NSMutableDictionary *layout = [layouts objectForKey:key];
		logDebug(@"Special keys: got layout");
		fileName = [self fileNameFromLayout:key];
		NSMutableDictionary *d = [[NSMutableDictionary alloc] init];
		//OrderedDictionary *d2 = [[NSMutableDictionary alloc] init];
		[d setObject:key forKey:@"name"];
		[d setObject:@"1.0" forKey:@"version"];
		[d setObject:@"SpecialKeys" forKey:@"Bundle"];
		[d setObject:@"Keyboard layouts for use with SpecialKeys" forKey:@"Description"];
		[d setObject:layout forKey:@"layout"];
		
		[d writeToFile:[NSString stringWithFormat:@"%@/%@",path,fileName]
										 atomically: TRUE];
	}
	
	fileName = @"currentlayout";
	OrderedDictionary *current = [self getRawLayoutByTitle:self.currentLayoutTitle];
	keys = [current allKeys];
	logDebug(@"SpecialKeys: saving currentlayout: %d keys",[keys count]);
	NSString *currentlayout = @"";
	currentlayout = [NSString stringWithFormat:@"%@@end\nALL/ALL/",currentLayoutTitle];
	for (i=0;i<[keys count];i++)
	{
		NSString *key = [keys objectAtIndex:i];
		logDebug(@"SpecialKeys: saving currentlayout: key: %@",key);
		NSString *keyCodesStr = [current objectForKey:key];
		logDebug(@"SpecialKeys: saving currentlayout: keyCodesStr: %@",keyCodesStr);
		NSArray *keyCodes = [keyCodesStr componentsSeparatedByString:@","];
		if (![[keyCodes objectAtIndex:0] isEqualToString:@""] && ![[keyCodes objectAtIndex:1] isEqualToString:@""])
		{
			int scanCode = [self decodeNumber:[keyCodes objectAtIndex:0]];
			if (scanCode != 0)
			{
				NSString *ADBCodeStr = [keyCodes objectAtIndex:1];
				int ADBCode = 0;
				if ([ADBCodeStr characterAtIndex:0]=='{')
				{
					ADBCode = [self decodeSpecialKey:ADBCodeStr];
					logDebug(@"decoding special key: %@ = %d",ADBCodeStr,ADBCode);
				} else {
					ADBCode = [self decodeNumber:ADBCodeStr];
					logDebug(@"decoding int: %@ = %d",ADBCodeStr,ADBCode);
				}
				if (ADBCode != 0)
				currentlayout = [NSString stringWithFormat:@"%@,%d,%d", currentlayout, scanCode, ADBCode];
				logDebug(@"currentlayout string: %@",currentlayout);
			}
		}
	}
	logDebug(@"CURRENTLAYOUT: %@",currentlayout);
	[currentlayout writeToFile:[NSString stringWithFormat:@"%@/%@",path,fileName]
					atomically: TRUE encoding: NSASCIIStringEncoding error:nil];

	
    //return self;
}

- (void)deleteLayoutFromDiskByTitle:(NSString *)title
{
	NSString *path = [NSString stringWithFormat:@"%@/",[self filesPath]];
	NSString *fileName = [self fileNameFromLayout:title];
	NSArray *files = [NSArray arrayWithObject:fileName];

	[[NSWorkspace sharedWorkspace] performFileOperation:NSWorkspaceRecycleOperation
												 source:path destination:@"" files:files tag:0];
	

}

- (NSArray *)allKeys
{
	return [_layouts allKeys];
}

- (NSDictionary *)forKey:(NSString *)key
{
	return [_layouts objectForKey:key];
}

@end
