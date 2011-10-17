package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
use Moose;

# ABSTRACT: Debian formatter for Changelogs

extends 'Dist::Zilla::Plugin::ChangelogFromGit';

use DateTime::Format::Mail;
use Text::Wrap qw(wrap fill $columns $huge);

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

		my $tag_line = $self->zilla->name.' ('.$version.') stable; urgency=low';
		$changelog .= (
			"$tag_line\n"
		);

	    foreach my $change (@{ $release->changes }) {
	        
	        unless ($change->description =~ /^\s/) {
                $changelog .= fill("    ", "    ", $change->description)."\n\n";
            }
            $changelog .= ' -- '.$change->author_name.' <'.$change->author_email.'>  '.$change->date."\n\n";

	    }
	}
	
	return $changelog;
}

=head1 SYNOPSIS

    [ChangelogFromGit::Debian]
    max_age = 365
    tag_regexp = ^\d+\.\d+$
    file_name = debian/changelog
    wrap_column = 72

=head1 DESCRIPTION

Dist::Zilla::Plugin::ChangelogFromGit::Debian extends
L<Dist::Zilla::Plugin::ChangelogFromGit> to create changelogs acceptable
for Debian packages.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;