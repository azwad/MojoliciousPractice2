package Model::search;
use Mojolicious::Lite 'app';
use Mojo::ByteStream 'b';
use File::Basename 'dirname';
use File::Path 'mkpath';
use Encode;
use feature 'say';


sub new {
	my $self = {};
	my $data_file = app->home->rel_file('search-person/data.txt');
	unless(-f $data_file){
		my $data_dir = dirname($data_file);
	  unless (-d $data_dir){
			mkpath($data_dir) or die "Cannot create '$data_dir'";
		}
		open my $fh, '>', $data_file or die "Cannot create file '$data_file': $!";
		close $fh;
	}
	$self->{data_file} = $data_file;
	bless $self, shift;
	return $self;
}

sub looks_like_number {
	my $var = shift;
	if ($var =~ /^\d+$/){
		return 1;
	}else{
		return 0;
	}
}


sub search_result {
	my $self = shift;
	my $input = shift;
	my $height_min = $input->{height_min};
	my $height_max = $input->{height_max};
 	my $res = {};

	my $error = !$height_min
		? 'need input number'
		: !$height_max
		? 'need input number'
		: !looks_like_number($height_min)
		? 'Height min must be a number'
		: !looks_like_number($height_max)
		? 'Height max must be a numer'
		: undef;

	return $res = { err => 1, template => 'error',message => $error,} if $error;

	my $data_file = $self->{data_file};
	say $data_file;
	open my $fh, '<', $data_file or die "Cannot open file'$data_file': $!";

	my $persons = [];
	while (my $line = <$fh>) {
		chomp $line;
		$line = decode_utf8($line);
		my @record = split("\t", $line);
		my $person = {};
		$person->{name} = $record[0];
		$person->{height} = $record[1];
		if ($person->{height} >= $height_min && 
				$person->{height} <= $height_max){
			push @$persons, $person;
		}
	}
	$res = {
		err => 0,
		persons => $persons,
	};
	return $res;
}

sub regist {
	my $self = shift;
	my $input = shift;
	my $res = {};
	my $name = $input->{name};
	my $height = $input->{height};
	my $error = !$name
							? 'you must be specify name'
							: looks_like_number($name)
							? 'is this a name? might be a number'
							: !looks_like_number($height)
							? 'Height must be a number'
							: undef;

	return $res = { err => 1, template => 'error',message => $error,} if $error;

	my $data_file = $self->{data_file};

	open my $fh ,'>>', $data_file or die "Cannot open file '$data_file': $!";
	my $line = join "\t", b($name)->encode('UTF-8')->to_string, 
												b($height)->encode('UTF-8')->to_string;
	print $fh "$line\n";
	close $fh;
	return $res = { err => 0 };
}
1;
 
