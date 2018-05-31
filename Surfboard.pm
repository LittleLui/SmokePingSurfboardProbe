package Smokeping::probes::Surfboard;

=head1 301 Moved Permanently

This is a Smokeping probe module. Please use the command 

C<smokeping -man Smokeping::probes::Surfboard>

to view the documentation or the command

C<smokeping -makepod Smokeping::probes::Surfboard>

to generate the POD document.

=cut

use strict;
use base qw(Smokeping::probes::basefork); 
# or, alternatively
# use base qw(Smokeping::probes::base);
use Carp;
use pQuery;
use Data::Dumper qw(Dumper);

sub pod_hash {
	return {
		name => <<DOC,
Smokeping::probes::Surfboard - Probes Motorola Surfboard SB5100 signal stats
DOC
		description => <<DOC,
Probes the SNR_Down, PL_Down, PL_Up statistics from the SB5100 signaldata.html
DOC
		authors => <<'DOC',
 Wolfgang Groiss <wolfgang.groiss@gmail.com>,
DOC
		see_also => <<DOC
L<smokeping_extend>
DOC
	};
}

sub new($$$)
{
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@_);

    # no need for this if we run as a cgi
    unless ( $ENV{SERVER_SOFTWARE} ) {
    	# if you have to test the program output
	# or something like that, do it here
	# and bail out if necessary
    };

    return $self;
}

# This is where you should declare your probe-specific variables.
# The example shows the common case of checking the availability of
# the specified binary.

sub probevars {
	my $class = shift;
	return $class->_makevars($class->SUPER::probevars, {
		#_mandatory => [ 'binary' ],
		#binary => { 
		#	_doc => "The location of your pingpong binary.",
		#	_example => '/usr/bin/pingpong',
		#	_sub => sub { 
		#		my $val = shift;
        	#		return "ERROR: pingpong 'binary' does not point to an executable"
            	#			unless -f $val and -x _;
		#		return undef;
		#	},
		#},
	});
}

# Here's the place for target-specific variables

sub targetvars {
	my $class = shift;
	return $class->_makevars($class->SUPER::targetvars, {
		#weight => { _doc => "The weight of the pingpong ball in grams",
		#	       _example => 15
		#},
		#

		_mandatory => ['key'],
		key => {
			_doc => "The key of the stat to query, either 'SNR_Down', 'PL_Down' or 'PL_Up'.",
			_example => 'SNR_Down'
		},
			
	});
}

sub ProbeDesc($){
    my $self = shift;
    return "html scrapes";
}

# this is where the actual stuff happens
# you can access the probe-specific variables
# via the $self->{properties} hash and the
# target-specific variables via $target->{vars}

# If you based your class on 'Smokeping::probes::base',
# you'd have to provide a "ping" method instead
# of "pingone"

sub pingone ($){
    my $self = shift;
    my $target = shift;

    my $host = $target->{addr};
    my $url = "http://$host/signaldata.html";

    my $count = $self->pings($target); # the number of pings for this targets
    my $key = $target->{vars}{key};
    my @times;

    my %queries = (
	    'SNR_Down' => 'table[border="1"] tr:eq(2) td:eq(1)',
	    'PL_Down' => 'table[border="1"] tr:eq(3) td:eq(1)',
	    'PL_Up' => 'table[border="1"]:eq(1) tr:eq(4) td:eq(1)'
    );

    my $query = $queries{$key}; 

    for (1..$count) {
	$self->do_debug("key: $key => query: $query");
        pQuery($url)
	    ->find($query)
	    ->each(sub {
                my $tx = pQuery($_)->text();
		my @txsplit = split / /, $tx;
     		$self->do_debug("$key: " . $tx);
     		$self->do_debug("=> $key: " . @txsplit[0]);
		
		push @times, @txsplit[0];
	    });
    }

    return @times;
}

# That's all, folks!

1;
