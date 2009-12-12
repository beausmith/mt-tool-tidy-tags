#!/usr/bin/perl

#   MT Tidy Tags 1.5
#   A perl script to normalize Movable Type template tags
#
#   http://beausmith.com/mt/plugins/tidytags/
#
#   This script looks for all MT tags (in any supported format) and replaces them using the following standard
#     - lowercase "mt:"
#     - CamelCase tag name
#     - dollar signs wrapping function tags
#
#   Please note:
#     - This is not a Movable Type plugin, it is a command line tool to “tidy” template tags in text files.
#     - With simple modification, this script will work with future releases of Movable Type as well as with template tags created by plugins. All that is required is to add the additional template tags to the script under function or block, respectively.
# 
#   Usage: 
# 
#     - Many files w/ back up       perl -pi.orig MTTidyTags.pl *.mtml
# 
#     - Single file w/ back up      perl -pi.orig MTTidyTags.pl file.mtml
# 
#     - Overwrite file              perl -pi MTTidyTags.pl file.mtml
# 
#   Authors:
# 
#     Beau Smith <beau@sixapart.com>
#     Brad Choate <brad@sixapart.com>
#     Garth Webb <garth@sixapart.com>



use strict;
local $/;

# Block tags from $MT/lib/MT/Template/ContextHandlers.pm
# Update with each new release in order to account for new tags
my %block_tags = map { lc $_ => $_ } qw(
    App:Setting
    App:Widget
    App:StatusMsg
    App:Listing
    App:SettingGroup
    App:Form
    If
    Unless
    For
    Else
    ElseIf
    IfImageSupport
    IfFeedbackEnabled
    EntryIfTagged
    IfArchiveTypeEnabled
    IfArchiveType
    IfCategory
    EntryIfCategory
    SubCatIsFirst
    SubCatIsLast
    HasSubCategories
    HasNoSubCategories
    HasParentCategory
    HasNoParentCategory
    IfIsAncestor
    IfIsDescendant
    IfStatic
    IfDynamic
    AssetIfTagged
    PageIfTagged
    IfFolder
    FolderHeader
    FolderFooter
    HasSubFolders
    HasParentFolder
    IncludeBlock
    Loop
    Section
    IfNonEmpty
    IfNonZero
    IfCommenterTrusted
    CommenterIfTrusted
    IfCommenterIsAuthor
    IfCommenterIsEntryAuthor
    IfBlog
    IfAuthor
    AuthorHasEntry
    AuthorHasPage
    Authors
    AuthorNext
    AuthorPrevious
    Blogs
    BlogIfCCLicense
    Entries
    EntriesHeader
    EntriesFooter
    EntryCategories
    EntryAdditionalCategories
    BlogIfCommentsOpen
    EntryPrevious
    EntryNext
    EntryTags
    DateHeader
    DateFooter
    PingsHeader
    PingsFooter
    ArchivePrevious
    ArchiveNext
    SetVarBlock
    SetVarTemplate
    SetVars
    SetHashVar
    IfCommentsModerated
    IfRegistrationRequired
    IfRegistrationNotRequired
    IfRegistrationAllowed
    IfTypeKeyToken
    Comments
    CommentsHeader
    CommentsFooter
    CommentEntry
    CommentIfModerated
    CommentParent
    CommentReplies
    IfCommentParent
    IfCommentReplies
    IndexList
    Archives
    ArchiveList
    ArchiveListHeader
    ArchiveListFooter
    Calendar
    CalendarWeekHeader
    CalendarWeekFooter
    CalendarIfBlank
    CalendarIfToday
    CalendarIfEntries
    CalendarIfNoEntries
    Categories
    CategoryIfAllowPings
    CategoryPrevious
    CategoryNext
    Pings
    PingsSent
    PingEntry
    IfAllowCommentHTML
    IfCommentsAllowed
    IfCommentsAccepted
    IfCommentsActive
    IfPingsAllowed
    IfPingsAccepted
    IfPingsActive
    IfPingsModerated
    IfNeedEmail
    IfRequireCommentEmails
    EntryIfAllowComments
    EntryIfCommentsOpen
    EntryIfAllowPings
    EntryIfExtended
    SubCategories
    TopLevelCategories
    ParentCategory
    ParentCategories
    TopLevelParent
    EntriesWithSubCategories
    Tags
    Ignore
    EntryAssets
    PageAssets
    Assets
    AssetTags
    Asset
    AssetIsFirstInRow
    AssetIsLastInRow
    AssetsHeader
    AssetsFooter
    AuthorUserpicAsset
    EntryAuthorUserpicAsset
    CommenterUserpicAsset
    Pages
    PagePrevious
    PageNext
    PageTags
    PageFolder
    PagesHeader
    PagesFooter
    Folders
    FolderPrevious
    FolderNext
    SubFolders
    ParentFolders
    ParentFolder
    TopLevelFolders
    TopLevelFolder
    IfMoreResults
    IfPreviousResults
    PagerBlock
    IfCurrentPage
    IfTagSearch
    SearchResults
    IfStraightSearch
    NoSearchResults
    NoSearch
    SearchResultsHeader
    SearchResultsFooter
    BlogResultHeader
    BlogResultFooter
    IfMaxResultsCutoff

    # MT Community Solution Tags
    IfAnonymousRecommendAllowed
    IfEntryRecommended
    IfLoggedIn
    AuthorCommentResponses
    AuthorComments
    AuthorFavoriteEntries
    Actions
    ActionsHeader
    ActionsFooter
    ActionsEntry
    ActionsComment
    ActionsFavorite
    AuthorFollowingFavorites
    AuthorFollowingEntries
    AuthorFollowingComments
    AuthorFollowing
    AuthorFollowers
    AuthorIfFollowed
    AuthorIfFollowing

    # MT Professional Pack Tags
    EntryCustomFields
    PageCustomFields
    AssetCustomFields
    CategoryCustomFields
    UserCustomFields
    FolderCustomFields
);

# Function tags from $MT/lib/MT/Template/ContextHandlers.pm
# Update with each new release in order to account for new tags
my %fn_tags = map { lc $_ => $_ } qw(
    App:PageActions
    App:ListFilters
    App:ActionBar
    App:Link
    Var
    CGIPath
    AdminCGIPath
    CGIRelativeURL
    CGIHost
    StaticWebPath
    StaticFilePath
    AdminScript
    CommentScript
    TrackbackScript
    SearchScript
    XMLRPCScript
    AtomScript
    NotifyScript
    Date
    Version
    ProductName
    PublishCharset
    DefaultLanguage
    CGIServerPath
    ConfigFile
    UserSessionCookieTimeout
    UserSessionCookieName
    UserSessionCookiePath
    UserSessionCookieDomain
    CommenterNameThunk
    CommenterUsername
    CommenterName
    CommenterEmail
    CommenterAuthType
    CommenterAuthIconURL
    CommenterUserpic
    CommenterUserpicURL
    CommenterID
    CommenterURL
    FeedbackScore
    AuthorID
    AuthorName
    AuthorDisplayName
    AuthorEmail
    AuthorURL
    AuthorAuthType
    AuthorAuthIconURL
    AuthorUserpic
    AuthorUserpicURL
    AuthorBasename
    BlogID
    BlogName
    BlogDescription
    BlogLanguage
    BlogURL
    BlogArchiveURL
    BlogRelativeURL
    BlogSitePath
    BlogHost
    BlogTimezone
    BlogCategoryCount
    BlogEntryCount
    BlogCommentCount
    BlogPingCount
    BlogCCLicenseURL
    BlogCCLicenseImage
    CCLicenseRDF
    BlogFileExtension
    BlogTemplateSetID
    EntriesCount
    EntryID
    EntryTitle
    EntryStatus
    EntryFlag
    EntryCategory
    EntryBody
    EntryMore
    EntryExcerpt
    EntryKeywords
    EntryLink
    EntryBasename
    EntryAtomID
    EntryPermalink
    EntryClass
    EntryClassLabel
    EntryAuthor
    EntryAuthorDisplayName
    EntryAuthorUsername
    EntryAuthorEmail
    EntryAuthorURL
    EntryAuthorLink
    EntryAuthorNickname
    EntryAuthorID
    EntryAuthorUserpic
    EntryAuthorUserpicURL
    EntryDate
    EntryCreatedDate
    EntryModifiedDate
    EntryCommentCount
    EntryTrackbackCount
    EntryTrackbackLink
    EntryTrackbackData
    EntryTrackbackID
    EntryBlogID
    EntryBlogName
    EntryBlogDescription
    EntryBlogURL
    EntryEditLink
    Include
    Link
    WidgetManager
    WidgetSet
    ErrorMessage
    GetVar
    SetVar
    TypeKeyToken
    CommentFields
    RemoteSignOutLink
    RemoteSignInLink
    SignOutLink
    SignInLink
    CommentID
    CommentBlogID
    CommentEntryID
    CommentName
    CommentIP
    CommentAuthor
    CommentAuthorLink
    CommentAuthorIdentity
    CommentEmail
    CommentLink
    CommentURL
    CommentBody
    CommentOrderNumber
    CommentDate
    CommentParentID
    CommentReplyToLink
    CommentPreviewAuthor
    CommentPreviewIP
    CommentPreviewAuthorLink
    CommentPreviewEmail
    CommentPreviewURL
    CommentPreviewBody
    CommentPreviewDate
    CommentPreviewState
    CommentPreviewIsStatic
    CommentRepliesRecurse
    IndexLink
    IndexName
    IndexBasename
    ArchiveLink
    ArchiveTitle
    ArchiveType
    ArchiveTypeLabel
    ArchiveLabel
    ArchiveCount
    ArchiveDate
    ArchiveDateEnd
    ArchiveCategory
    ArchiveFile
    ImageURL
    ImageWidth
    ImageHeight
    CalendarDay
    CalendarCellNumber
    CalendarDate
    CategoryID
    CategoryLabel
    CategoryBasename
    CategoryDescription
    CategoryArchiveLink
    CategoryCount
    CategoryCommentCount
    CategoryTrackbackLink
    CategoryTrackbackCount
    PingsSentURL
    PingTitle
    PingID
    PingURL
    PingExcerpt
    PingBlogName
    PingIP
    PingDate
    FileTemplate
    SignOnURL
    SubCatsRecurse
    SubCategoryPath
    TagName
    TagLabel
    TagID
    TagCount
    TagRank
    TagSearchLink
    TemplateNote
    TemplateCreatedOn
    HTTPContentType
    AssetID
    AssetFileName
    AssetLabel
    AssetURL
    AssetType
    AssetMimeType
    AssetFilePath
    AssetDateAdded
    AssetAddedBy
    AssetProperty
    AssetFileExt
    AssetThumbnailURL
    AssetLink
    AssetThumbnailLink
    AssetDescription
    AssetCount
    PageID
    PageTitle
    PageBody
    PageMore
    PageDate
    PageModifiedDate
    PageAuthorDisplayName
    PageKeywords
    PageBasename
    PagePermalink
    PageAuthorEmail
    PageAuthorLink
    PageAuthorURL
    PageExcerpt
    BlogPageCount
    FolderBasename
    FolderCount
    FolderDescription
    FolderID
    FolderLabel
    FolderPath
    SubFolderRecurse
    SearchString
    SearchResultCount
    MaxResults
    SearchMaxResults
    SearchIncludeBlogs
    SearchTemplateID
    UserSessionState
    BuildTemplateID
    CaptchaFields
    EntryScore
    CommentScore
    PingScore
    AssetScore
    AuthorScore
    EntryScoreHigh
    CommentScoreHigh
    PingScoreHigh
    AssetScoreHigh
    AuthorScoreHigh
    EntryScoreLow
    CommentScoreLow
    PingScoreLow
    AssetScoreLow
    AuthorScoreLow
    EntryScoreAvg
    CommentScoreAvg
    PingScoreAvg
    AssetScoreAvg
    AuthorScoreAvg
    EntryScoreCount
    CommentScoreCount
    PingScoreCount
    AssetScoreCount
    AuthorScoreCount
    EntryRank
    CommentRank
    PingRank
    AssetRank
    AuthorRank
    PagerLink
    NextLink
    PreviousLink
    CurrentPage
    TotalPages

    # MT Community Solution Tags
    EntryRecommendedTotal
    EntryRecommendVoteLink
    CommunityScript
    ScoreDate
    AuthorFollowersCount
    AuthorFollowingCount
    AuthorFollowLink
    AuthorUnfollowLink

    # MT Professional Pack Tags
    CustomFieldBasename
    CustomFieldName
    CustomFieldDescription
    CustomFieldValue
    CustomFieldHTML
);

sub tidytags {
    my ($match, $slash, $stuff) = @_;
    
    # split the args from the tag
    my ($tag, $args) = split /\s+/, $stuff, 2;
    
    # prefix args with space if args
    $args = ' ' . $args if $args;

    # If tag exists in the block_tags list, then format tags as start & end block tags.
    if (exists ($block_tags{lc($tag)})) {
        $tag = $block_tags{lc($tag)};
        "<${slash}mt:" . $tag . $args . ">";

    # If tag exists in the fn_tags list, then format tags as function tags.
    } elsif (exists ($fn_tags{lc($tag)})) {
        $tag = $fn_tags{lc($tag)};
        "<\$mt:".$tag. $args."\$>";

    # If tag doesn't exist in either list, then format format the tag with the preferred prefix (mt:).
    } else {
        "<${slash}mt:" . $tag . $args . "><\!-- unknown tag -->";
    }
}

my $tag;

my $file = $_ . <>;
# my $file = <STDIN>; # Uncomment to use as TextMate command. Comment out the line above

# find tags in file matching any MT syntax and pass to tidytags function
$file =~ s!(<(\$)?(/)?MT:?((?:<[^>]+?>|.)+?)[\$/]?>)!tidytags($1, $3, $4)!geix;

$_ = $file;
# print $file; # Uncomment to use as TextMate command. Comment out the line above
