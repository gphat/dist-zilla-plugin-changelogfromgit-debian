package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
use Moose;

# ABSTRACT: Debian formatter for Changelogs

extends 'Dist::Zilla::Plugin::ChangelogFromGit';

use DateTime::Format::Mail;
use Text::Wrap qw(wrap fill $columns $huge);

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
    required => 1
);

=attr maintainer_name

The maintainer name for this package.

=cut

has 'maintainer_name' => (
    is => 'rw',
    isa => 'Str',
    required => 1
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

        # Don't output empty versions.
        next if $release->has_no_changes;

        my $version = $release->version;
        if($version eq 'HEAD') {
            $version = $self->zilla->version;
        }

		my $tag_line = $self->package_name.' ('.$version.') '.$self->dist_name.'; urgency=low';
		$changelog .= (
			"$tag_line\n"
		);

	    foreach my $change (@{ $release->changes }) {
	        
	        unless ($change->description =~ /^\s/) {
                $changelog .= fill("  ", "    ", '* '.$change->description)."\n";
            }
	    }
        $changelog .= "\n -- ".$change->author_name.' <'.$change->author_email.'>  '.DateTime::Format::Mail->format_datetime($change->date)."\n\n";
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