/*
 *  TKItem_Core.h
 *  Created on 16/Jan/19.
 *
 *  Copyright (C) 2018 Karim. All rights reserved.
 */

#import "TKItem.h"
#import "Statement.h"

@interface TKItem ()

-(instancetype)initWithStatement:(tk::Ref<tk::Statement>)statement;

@end
