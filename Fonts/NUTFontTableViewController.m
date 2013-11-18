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
@property (nonatomic) CGFloat pointSize;
@end

@implementation NUTFontTableViewController

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {

        // init pointSize
        [self setpointSizeForCategory];

        NSMutableArray *fonts = [NSMutableArray array];
        NSArray *familyNames = [UIFont familyNames];
        for (NSString *familyName in familyNames)
        {
            NSArray *fontNames = [UIFont fontNamesForFamilyName:familyName];
            for (NSString *fontName in fontNames)
            {
                UIFont *font = [UIFont fontWithName:fontName size:self.pointSize];
                [fonts addObject:font];
//              NSLog(@"\n%@", font.fontName);
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contentSizeCategoryDidChange)
                                                 name:UIContentSizeCategoryDidChangeNotification
                                               object:nil];
    [self.tableView reloadData];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)contentSizeCategoryDidChange
{
    [self setpointSizeForCategory];
	[self.tableView reloadData];
}

- (void)setpointSizeForCategory
{
    // see http://johnszumski.com/blog/implementing-dynamic-type-on-ios7

    NSString *contentSize = [UIApplication sharedApplication].preferredContentSizeCategory;
    NSString *description;

    UIFont *templateFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    self.pointSize = templateFont.pointSize;

    if ([contentSize rangeOfString:@"Accessibility"].location != NSNotFound)
    {
        // TODO: these font sizes are guesses
        // Accessibility Content Size Category Constants
        if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityMedium]) {
            description = @"Accessibility Medium";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityLarge]) {
            description = @"Accessibility Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityExtraLarge]) {
            description = @"Accessibility Extra Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraLarge]) {
            description = @"Accessibility 2X Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryAccessibilityExtraExtraExtraLarge]) {
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
            description = @"Extra Small";
        } else if ([contentSize isEqualToString:UIContentSizeCategorySmall]) {
            description = @"Small";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryMedium]) {
            description = @"Medium";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryLarge]) {
            description = @"Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraLarge]) {
            description = @"Extra Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraLarge]) {
            description = @"Extra Extra Large";
        } else if ([contentSize isEqualToString:UIContentSizeCategoryExtraExtraExtraLarge]) {
            description = @"Extra Extra Extra Large";
        }
        else
        {
            description = @"Unknown Content Cateogry Size";
        }
    }

    self.title = [NSString stringWithFormat:@"%@ (%0.f)", description, self.pointSize];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // why yes, every font *could* have a different height
    UIFont *font = self.fonts[indexPath.row];

    // surprise!
    font = [font fontWithSize:self.pointSize];

    CGFloat height = font.leading * 1.5;

    if (height < 30) {
        // we may want to touch these some day
        // but 44 is ridiculous
        height = 30;
    }

    height = lroundf(height);
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    UIFont *font = self.fonts[indexPath.row];
    font = [font fontWithSize:self.pointSize]; // maybe changed
    cell.textLabel.font = font;
    if ([font.fontName isEqualToString:@"AppleColorEmoji"])
    {
        // https://twitter.com/SteveStreza/status/392758417233678336/photo/1
        cell.textLabel.text = @"👻";
    }
    else
    {
        cell.textLabel.text = [self formatFontName:font.fontName];
    }
//  cell.detailTextLabel.text = font.fontName;
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
