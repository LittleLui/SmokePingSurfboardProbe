package Smokeping::probes::Czap;

=head1 301 Moved Permanently

This is a Smokeping probe module. Please use the command 

C<smokeping -man Smokeping::probes::Czap>

to view the documentation or the command

C<smokeping -makepod Smokeping::probes::Czap>

to generate the POD document.

=cut

use strict;
use base qw(Smokeping::probes::basefork); 
# or, alternatively
# use base qw(Smokeping::probes::base);
use Carp;
use Data::Dumper qw(Dumper);
use IPC::Open2;



sub pod_hash {
	return {
		name => <<DOC,
Smokeping::probes::Czap - Probes DVB-C quality metrics
DOC
		description => <<DOC,
Probes the signal, snr, ber and unc statistics from a DVB-C receiver via czap
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

		_mandatory => ['channel', 'key'],
		channel => {
			_doc => "Either -n <number> or the channel name in single or double quotes.",
			_example => "'-n 1' OR '\"History HD(SKY)\"'"
		},
		key => {
			_doc => "The key of the stat to query, either 'signal', 'snr', 'ber' or 'unc'.",
			_example => 'signal'
		},
			
	});
}

sub ProbeDesc($){
    my $self = shift;
    return "czap invocations";
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

#    my $host = $target->{addr};

    my $count = $self->pings($target); # the number of pings for this targets
    my $key = $target->{vars}{key};
    my $channel = $target->{vars}{channel};
    my @times;

    my %regexes = (
	    'signal' => 'signal\s*([0-9]+)',
	    'snr' => 'snr\s*([0-9]+)',
	    'ber' => 'ber\s*([0-9]+)',
	    'unc' => 'unc\s*([0-9]+)'
    );

    my $regex = $regexes{$key}; 

    $self->do_debug("key: $key => regex: $regex - channel: $channel");

    my $pid = open2(\*CZAP_OUT, \*CZAP_IN, "/usr/bin/czap -H $channel 2>&1")
      or die "open2() failed $!";

    $self->do_debug("started $pid");

    my $i = 0;
    while ($i < $count && kill(0, $pid)) {
        if (defined (my $line = <CZAP_OUT>)) {
	    chomp($line);
  	    $self->do_debug("post-chomp $line");
	    if ($line =~ /FE_HAS_LOCK/) {
	        $i += 1;

	        $self->do_debug("1 line: $line");
	        $line =~ /.$regex./;
	        $self->do_debug("2 line: $line, $1");

	        push @times, $1;
	    }
	}

    }

   $self->do_debug("eof or ate all $i/$count. $!");

    close CZAP_OUT;

    return @times;
}

# That's all, folks!

1;
