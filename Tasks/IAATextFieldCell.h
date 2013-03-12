//
//  IAATextFieldCell.h
//  Tasks
//
//  Created by Tomas Vana on 3/12/13.
//  Copyright (c) 2013 iOS Apps Austria. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAATextFieldCell : UITableViewCell

@property (nonatomic, readonly) UITextField *textField;

/**
 Block that will be called when editing of the text field has ended passing the text field's text
 and the cell's related object (a tag-like value that can be set for the cell).
 If non-nil, uses the return value as the new value for the text field.
 */
@property (nonatomic, copy) NSString *(^commitBlock)(NSString *);

/**
 Block that will be called when editing of the text field has started.
 */
@property (nonatomic, copy) void(^startedEditingBlock)();


- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
