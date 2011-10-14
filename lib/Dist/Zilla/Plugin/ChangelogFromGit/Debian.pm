package Dist::Zilla::Plugin::ChangelogFromGit::Debian;
use Moose;

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

__PACKAGE__->meta->make_immutable;
no Moose;
1;