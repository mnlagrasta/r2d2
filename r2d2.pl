#!/usr/bin/env perl

use Mojolicious::Lite;

my $audio_cmd = 'mpg123 -q';
my $audio_path = './mp3/';

my @sound_table;

get_file_list();

get '/' => sub {
    my $c = shift;
    $c->stash(sound_table => \@sound_table);
    $c->render('index');
};

get '/:cmd' => sub {
    my $c = shift;
    my $cmd = $c->param('cmd');
    my $i = $c->param('i');

    if ($cmd eq 's') {
        `$audio_cmd $audio_path$sound_table[$i] >/dev/null &`;
    }

    $c->stash(sound_table => \@sound_table);
    $c->render('index');
};

sub get_file_list {
    opendir(my $dh, $audio_path) || die "can't opendir $audio_path: $!";
    while (readdir($dh)) {
        next unless (substr($_, -4, 4) eq '.mp3');
        push @sound_table, $_;
    }

    closedir $dh;
}

`$audio_cmd $audio_path$sound_table[0] >/dev/null &`;
app->start;

__DATA__

@@ index.html.ep
% my $a=0;
% my $b=0;
<table><tr>
% for my $sound (sort @$sound_table) {
  <td><a href="/s?i=<%= $a %>"><button><%= $sound %></button></a></td>
  % if ($b++ == 2) {
      </tr><tr>
      % $b=0;
  % }
  % $a++;
% }
</tr></table>
