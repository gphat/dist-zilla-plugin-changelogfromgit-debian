package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
use Moose;

# ABSTRACT: Debian formatter for Changelogs

extends 'Dist::Zilla::Plugin::ChangelogFromGit';

use DateTime::Format::Mail;
use Text::Wrap qw(wrap fill $columns $huge);

=attr allow_empty_head

If true then an empty head is allowed. Since this module converts head to
the current dzil version, this might be useful to you for some reason.

=cut

has 'allow_empty_head' => (
    is => 'rw',
    isa => 'Bool',
    default => 1
);

=attr dist_name

The distribution name for this package.

=cut

has 'dist_name' => (
    is => 'rw',
    isa => 'Str',
    default => 'stable'
);

=attr maintainer_email

The maintainer email for this package.

=cut

has 'maintainer_email' => (
    is => 'rw',
    isa => 'Str',
    default => 'cpan@example.com'
);

=attr maintainer_name

The maintainer name for this package.

=cut

has 'maintainer_name' => (
    is => 'rw',
    isa => 'Str',
    default => 'CPAN Author'
);

=attr package_name

The package name for this package.

=cut

has 'package_name' => (
    is => 'rw',
    isa => 'Str',
    lazy => 1,
    default => sub {
        my $self = shift;
        return lc($self->zilla->name)
    }
);

sub render_changelog {
    my ($self) = @_;

	$Text::Wrap::huge    = 'wrap';
	$Text::Wrap::columns = $self->wrap_column;
	
	my $changelog = '';
	
	foreach my $release (reverse $self->all_releases) {

        # Don't output empty versions, unless it's HEAD cuz that might matter!
        next if $release->has_no_changes && $release->version ne 'HEAD';
        if($release->version eq 'HEAD') {
            next unless $self->allow_empty_head;
        }

        my $version = $release->version;
        if($version eq 'HEAD') {
            $version = $self->zilla->version;
        }

		my $tag_line = $self->package_name.' ('.$version.') '.$self->dist_name.'; urgency=low';
		$changelog .= (
			"$tag_line\n"
		);

        my $firstchange = undef;
	    foreach my $change (@{ $release->changes }) {
	        unless(defined($firstchange)) {
	            $firstchange = $change;
	        }
	        unless ($change->description =~ /^\s/) {
                $changelog .= fill("  ", "    ", '* '.$change->description)."\n";
            }
	    }
	    if($release->has_no_changes) {
            $firstchange = Software::Release::Change->new(
                description => 'no changes'
                date => DateTime->now
            );
        }
        $changelog .= "\n -- ".$self->maintainer_name.' <'.$self->maintainer_email.'>  '.DateTime::Format::Mail->format_datetime($firstchange->date)."\n\n";
	}
	
	return $changelog;
}

=head1 SYNOPSIS

    #    [ChangelogFromGit::Debian]
    #    max_age = 365
    #    tag_regexp = ^\d+\.\d+$
    #    file_name = debian/changelog
    #    wrap_column = 72
    #    dist_name = squeeze # defaults to stable
    #    package_name = my-package # defaults to lc($self->zilla->name)

=head1 DESCRIPTION

Dist::Zilla::Plugin::ChangelogFromGit::Debian extends
L<Dist::Zilla::Plugin::ChangelogFromGit> to create changelogs acceptable
for Debian packages.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;