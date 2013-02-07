#!/usr/local/bin/morbo
use Mojolicious::Lite;
use feature qw( say );

my $site_title = 'Mojolicious Practice';

my ($dir1, $title1, $model1, $template1) = ('search', 'Search Page', 'search', 'search');
my ($dir2, $title2, $model2, $template2) = ('search_result', 'Search Result', 'search', 'search_result');
my ($dir3, $title3, $model3, $template3) = ('post', 'Post', 'search', 'post');
my ($dir4, $title4, $model4, $template4) = ('register', 'Register Page', 'search', 'register');


my $package_name = "model-$model1.pm";
my $app_object_name = "Model::$model1";
require $package_name;
app->helper(
	$model1 =>sub {
		$app_object_name->new;
});


get $dir1 => sub { 
	my $self = shift;
 	$self->stash(
			page_title => $title1,
			site_title => $site_title,
		);
	$self->render();
} => $template1;

get $dir4 => sub {
	my $self = shift;
 	$self->stash(
			page_title => $title4,
			site_title => $site_title,
		);
	$self->render();
} => $template4;

get $dir2 => sub {
	my $self = shift;
	my $input = {
			height_min => $self->param('height_min'),
			height_max => $self->param('height_max'),
	};
	my $method = 'search_result';
	my $res = $self->app->$model1->$method( $input );
	if ($res->{err}){
		return 		$self->render(
			template => 'error',
			page_title => 'error',
			site_title => $site_title,
			message  => $res->{message},
		);
	}
	$self->stash(
		result => $res->{persons},
		site_title => $site_title,
		page_title => $title2,
	);
	$self->render( );
} => $template2;

post $dir3 => sub {
	my $self = shift;
	my $input = {
			name => $self->param('name'),
			height => $self->param('height'),
	};
	my $method = 'regist';
	my $res = $self->app->$model1->$method( $input );
	if ($res->{err}){
		return 		$self->render(
			template => 'error',
			page_title => 'error',
			site_title => $site_title,
			message  => $res->{message},
		);
	}
	$self->redirect_to($dir4);
} => $template3;


app->start;
