#!/usr/bin/perl -w
#use strict;
use warnings;
use Cwd qw(abs_path);
use List::Util qw(sum);

@ARGV >= 1 || die "Generate sankey files for ploting using R package \n; perl $0 config.txt ./\n";

my ($config, $outdir) = @ARGV;
$outdir ||= './';
-d $outdir || mkdir $outdir;
$outdir = abs_path($outdir);

my %conf = config_hash($config);

our (%kindom_abund, %phylum_abund, %class_abund, %order_abund, %family_abund, %genus_abund, %species_abund);

%kindom_abund = taxa_abund($conf{"kindom"}) if $conf{"kindom"} and -s $conf{"kindom"};

%phylum_abund = taxa_abund($conf{"phylum"}) if $conf{"phylum"} and -s $conf{"phylum"};

%class_abund = taxa_abund($conf{"class"}) if $conf{"class"} and -s $conf{"class"};

%order_abund = taxa_abund($conf{"order"}) if $conf{"order"} and -s $conf{"order"};

%family_abund = taxa_abund($conf{"family"}) if $conf{"family"} and -s $conf{"family"};

%genus_abund = taxa_abund($conf{"genus"}) if $conf{"genus"} and -s $conf{"genus"};

%species_abund = taxa_abund($conf{"species"}) if $conf{"species"} and -s $conf{"species"};

my %taxa_abund = (%kindom_abund, %phylum_abund, %class_abund, %order_abund, %family_abund, %genus_abund, %species_abund);

#k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__Roseburia;s__Roseburia_inulinivorans;
#k__Bacteria;p__Firmicutes;c__Clostridia;o__Clostridiales;f__Lachnospiraceae;g__unidentified_Lachnospiraceae;s__Butyrivibrio_fibrisolvens;

my %select_hash = %{$conf{minimum_taxa} . "_abund"};

my @minimum_taxa;
for my $t (sort {$select_hash{$b} <=> $select_hash{$a}} keys %select_hash){
  push @minimum_taxa, $t;
}

@minimum_taxa = @minimum_taxa[0..$conf{top_num}];

my %taxa_yes = map {$_, 1} @minimum_taxa;

my $target_file = $conf{$conf{minimum_taxa}};

# my %t1_t2 = taxa_tree($target_file);

my @nodes;
my %node_index;
my %node_nodeup;
my $index = 0;
open IN, $target_file;
while(<IN>){
  /^#/ && next;
  chomp;
  $taxa_yes{(split /\t/)[0]} || next;
  my $taxa_detail = (split /\t+/)[-1];
  $taxa_detail =~ s/\S__//g;
  my @taxa = split /;/, $taxa_detail;
  my @r_taxa = reverse(@taxa);
  push @nodes, $taxa[0];
  for my $i (0..$#r_taxa-1){ 
    if($r_taxa[$i+1] && $r_taxa[$i]){
      push @nodes, $r_taxa[$i];
      $node_nodeup{$r_taxa[$i]} = $r_taxa[$i+1];
    }
  }
}
close IN;

my $raw_link = $outdir . '/raw.link.txt';
my $link_sankey = $outdir . '/link.sankey.txt';
my $node_sankey = $outdir . '/node.sankey.txt';

open R1, ">$raw_link";
open R2, ">$link_sankey";
open R3, ">$node_sankey";

print R1 "source\ttarget\tvalue\n";
print R2 "source\ttarget\tvalue\n";

for (uniq(@nodes)){
  $node_index{$_} = $index++;
  print R3 $_ . "(" . format_digit($taxa_abund{$_}) . ")", "\n";
}

for(uniq(@nodes)){
  if($node_nodeup{$_}){
      print R1 $node_nodeup{$_} . "(" . format_digit($taxa_abund{$node_nodeup{$_}}) . ")", "\t", $_ . "(" . format_digit($taxa_abund{$_}) . ")", "\t",$taxa_abund{$_}, "\n";
  $node_index{$node_nodeup{$_}} ||= 0;
    print R2 $node_index{$node_nodeup{$_}}, "\t", $node_index{$_}, "\t", $taxa_abund{$_}, "\n";
  }
}

close R1;
close R2;
close R3;


sub config_hash{
  my ($conf) = @_;
  my %kv;
  open CONF, $conf; 
  while(<CONF>){
    /^#/ && next;
    chomp;
	s/\s+//g;
    my ($k, $v) = split /\=/;
    $kv{$k} = $v;
  }
  close CONF;
  return %kv;
}

sub taxa_abund{
  my ($taxa) = @_;
  my %ta;
  open TAXA, $taxa;
  <TAXA>;
  while(<TAXA>){
    chomp;
    my @temp = split /\t/;
    $ta{$temp[0]} = sum(@temp[1..$#temp-1]) / ($#temp-1);
  }
  close TAXA;
  return %ta;
}

sub format_digit{
  my ($d, $num) = @_;
  $num ||= 2;
  return sprintf("%.$num" . "f", $d * 100) . '%';
}

sub uniq {
    my %temp;
    grep !$temp{$_}++, @_;
}


