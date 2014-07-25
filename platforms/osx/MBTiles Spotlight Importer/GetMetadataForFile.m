//
//  MBTiles Spotlight Importer
//
//  Copyright 2011-2014 Mapbox, Inc.
//  All rights reserved.
//  
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//  
//      * Redistributions of source code must retain the above copyright
//        notice, this list of conditions and the following disclaimer.
//  
//      * Redistributions in binary form must reproduce the above copyright
//        notice, this list of conditions and the following disclaimer in the
//        documentation and/or other materials provided with the distribution.
//  
//      * Neither the name of Mapbox, Inc. nor the names of its contributors
//        may be used to endorse or promote products derived from this
//        software without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
//  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
//  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
//  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
//  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
//  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h> 
#import <Foundation/Foundation.h>

#import "FMDatabase.h"
#import "FMResultSet.h"

Boolean GetMetadataForURL(void *thisInterface, 
                          CFMutableDictionaryRef attributes, 
                          CFStringRef contentTypeUTI,
                          CFURLRef urlForFile)
{
    Boolean success = NO;
    
    @autoreleasepool {

        FMDatabase *db = [FMDatabase databaseWithPath:[(__bridge NSURL *)urlForFile path]];
        
        if ([db open])
        {
            NSDictionary *fetches = [NSDictionary dictionaryWithObjectsAndKeys:(NSString *)kMDItemDisplayName, @"name",
                                                                               (NSString *)kMDItemDescription, @"description",
                                                                               (NSString *)kMDItemVersion,     @"version",
                                                                               (NSString *)kMDItemCopyright,   @"attribution",
                                                                               nil];
            
            for (NSString *key in [fetches allKeys])
            {
                FMResultSet *result = [db executeQuery:@"select value from metadata where name = ?", key];
                
                if ( ! [db hadError])
                {
                    [result next];
                
                    if ([result stringForColumnIndex:0])
                        [(__bridge NSMutableDictionary *)attributes setObject:[result stringForColumnIndex:0] forKey:[fetches objectForKey:key]];
                    
                    [result close];
                }
            }
            [db close];
            [(__bridge NSMutableDictionary *)attributes setObject:[NSString stringWithFormat:@"MBTiles"]
                                                  forKey:(NSString *)kMDItemKind];
            success = YES;
        }
        

        return success;
    }
}