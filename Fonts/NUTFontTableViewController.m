//
//  NUTFontTableViewController.m
//  Fonts
//
//  Created by Stephen Ryner Jr. on 11/17/13.
//  Copyright (c) 2013 Nuthatch Graphics. All rights reserved.
//

#import "NUTFontTableViewController.h"

@interface NUTFontTableViewController ()
@property (nonatomic, strong) NSArray *fonts;
@property (nonatomic) CGFloat fontSize;
@end

@implementation NUTFontTableViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        // init fontSize
        [self setFontSizeForCategory];

        NSMutableArray *fonts = [NSMutableArray array];
        NSArray *familyNames = [UIFont familyNames];
        for (NSString *familyName in familyNames)
        {
            NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
            for (NSString *fontName in fontNames)
            {
                UIFont *font = [UIFont fontWithName:fontName size:self.fontSize];
                [fonts addObject:font];
                NSLog(@"%@", font.fontName);
            }
        }

        NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"fontName" ascending:YES];
        self.fonts = [fonts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.separatorColor = [UIColor clearColor];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChange)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChange
{
    [self setFontSizeForCategory];
	[self.tableView reloadData];
}

- (void)setFontSizeForCategory
{
    // see http://johnszumski.com/blog/implementing-dynamic-type-on-ios7

    CGFloat fontSize = 16.0;
    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    NSString *description;
    
    if ([contentSize rangeOfString:@"Accessibility"].location != NSNotFound)
    {
        // TODO: these font sizes are guesses
        // Accessibility Content Size Category Constants
        if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityMedium]) {
            fontSize = 24.0;
            description = @"Accessibility Medium";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityLarge]) {
            fontSize = 26.0;
            description = @"Accessibility Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge]) {
            fontSize = 28.0;
            description = @"Accessibility Extra Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge]) {
            fontSize = 30.0;
            description = @"Accessibility 2X Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge]) {
            fontSize = 32.0;
            description = @"Accessibility 3X Large";
        }
        else {
            description = @"Unknown Content Cateogry Accessibility Size";
        }
    }
    else
    {
        //Content Size Category Constants
        if ([contentSize isEqualToString:UIContentSizeCategoryExtraSmall]) {
            fontSize = 12.0;
            description = @"Extra Small";
        } else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
            fontSize = 14.0;
            description = @"Small";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
            fontSize = 16.0;
            description = @"Medium";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
            fontSize = 18.0;
            description = @"Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
            fontSize = 20.0;
            description = @"Extra Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
            fontSize = 22.0;
            description = @"Extra Extra Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
            fontSize = 24.0;
            description = @"Extra Extra Extra Large";
        }
        else
        {
            description = @"Unknown Content Cateogry Size";
        }
    }

    self.fontSize = fontSize;

    self.title = [NSString stringWithFormat:@"%@ (%0.f)", description, fontSize];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1; // not zero
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.fonts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIFont *font = self.fonts[indexPath.row];
    font = [font fontWithSize:self.fontSize]; // maybe changed
    cell.textLabel.font = font;
    cell.textLabel.text = [self formatFontName:font.fontName];
    return cell;
}

- (NSString *)formatFontName:(NSString *)name
{
    // http://stackoverflow.com/questions/1918972/camelcase-to-underscores-and-back-in-objective-c/19850389#19850389
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=[a-z])([A-Z])|([A-Z])(?=[a-z])" options:0 error:nil];
    name = [regex stringByReplacingMatchesInString:name options:0 range:NSMakeRange(0, name.length) withTemplate:@" $1$2"];

    // hack out the dashes
    name = [name stringByReplacingOccurrencesOfString:@"-" withString:@""];

    return name;
}

@end
