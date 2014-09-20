#!/usr/bin/perl

use WWW::Mechanize;
use HTML::TreeBuilder::XPath;
use Text::CSV;
use strict;

my $csv = Text::CSV->new;
$csv->eol("\r\n");

open my $fh, ">", "stocks_perl.csv" or die "$!";

my $user_agent = "Mozilla/5.0";
my $agent = WWW::Mechanize->new(agent => $user_agent);

my $base = "http://finance.yahoo.com";

# Stock

my $stock = "YHOO";

# Dataes

my @first = (9,8,2012);
my @last = (9,22,2012);

# Daily

my $freq = "d";

my $url = "${base}/q/hp?s=${stock}&a=${first[0]}&b=${first[1]}&c=${first[2]}&d=${last[0]}&e=${last[1]}&f=${last[2]}&g=${freq}";

my $page = $agent->get($url);
my $tree = HTML::TreeBuilder::XPath->new;

$tree->parse($page->decoded_content);

# This version doesn't skip the first row 
#my $path = '//*[@id="yfncsumtab"]/tr[2]/td[1]/table[4]/tr/td/table/tr';

# This variation skips the first row
my $path = '//*[@id="yfncsumtab"]/tr[2]/td[1]/table[4]/tr/td/table/tr[position() > 1]';

for my $tr ($tree->findnodes($path)) {

    my @r = ($stock);

    for my $td ($tr->findnodes("td")) {
	push(@r,$td->as_text);
    }

    if (@r>2) {
	$csv->print($fh,\@r)
    };
}

close $fh or die "$!";
