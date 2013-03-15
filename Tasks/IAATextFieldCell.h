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
 Block that will be called when editing of the text field has ended passing the text field's text.
 */
@property (nonatomic, copy) void(^commitBlock)(NSString *);

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
