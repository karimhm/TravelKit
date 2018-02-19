/*
 *  TKUtilities.m
 *  Created on 15/Feb/18.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKUtilities.h"

BOOL TKFileExists(NSString *path) {
    return (access(path.fileSystemRepresentation, F_OK ) != -1);
}

BOOL TKFileReadable(NSString *path) {
    return (access(path.fileSystemRepresentation, R_OK ) != -1);
}

BOOL TKFileWritable(NSString *path) {
    return (access(path.fileSystemRepresentation, W_OK ) != -1);
}
