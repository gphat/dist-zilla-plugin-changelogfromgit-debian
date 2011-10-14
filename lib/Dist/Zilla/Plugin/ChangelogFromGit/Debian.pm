package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
use Moose;

# ABSTRACT: Debian formatter for Changelogs

with 'Dist::Zilla::Plugin::ChangelogFromGit::Formatter';

use DateTime::Format::Mail;
use Text::Wrap qw(wrap fill $columns $huge);

sub format {
    my ($self, $releases) = @_;

	$Text::Wrap::huge    = 'wrap';
	$Text::Wrap::columns = $self->wrap_column;
	
	my $changelog = '';
	
	foreach my $release (@{ $releases }) {

        # Don't output empty versions.
        next if $release->has_no_changes;

		my $tag_line = $self->dist_name.' ('.$release->{version}.') stable; urgency=low';
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

    [ChangelogFromGit]
    max_age = 365
    tag_regexp = ^\d+\.\d+$
    file_name = debian/changelog
    wrap_column = 72
    formatter_class = Debian

=head1 DESCRIPTION

Dist::Zilla::Plugin::ChangelogFromGit::Debian creates changelogs acceptable
for Debian packages.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;
1;