#!/usr/bin/env perl

# Copyright 2020 Karl-Johan Grahn

use strict;
use warnings;
use XML::Simple qw(XMLout);

# Parse input argument
my $input_log_file;
if (@ARGV ne 1) {
   print "Error: Too many or too few input arguments\n";
   print "Syntax: $0 <path to logfile.log>\n";
   exit;
} else {
   $input_log_file = shift(@ARGV);
}

# This is a function to create a hash reference based on the content of a log file.
# The hash reference is structured so it later can be the input argument to the
# XMLout function of the XML::Simple module.
# Input:
#        $file - path to log file
# Output:
#        $hash_ref - hash reference
sub getHashRef {
   my $file = shift;
   # Initialize hash reference
   my $hash_ref = {};

   open my $filehandle, $file or die "Error: Could not open log file \"$file\": $!";
   # Initialize indexes to be used to create the proper hash reference structure
   my $target_index = -1;
   my $issues_index = -1;
   my $generated_content_index = -1;
   my $processed_content_index = -1;
   # Read each line of the log file at a time
   my $previous_line = "";
   while (my $line = <$filehandle>) {
      if ($line =~ /^Compiling target /) {
         $target_index += 1;
         # For each target, reset the following indexes so the corresponding nodes are added to the current target
         $issues_index = -1;
         $generated_content_index = -1;
         $processed_content_index = -1;
         # Use look behind and look ahead in the regular expression to get the target name
         $line =~ /(?<=Compiling target )(.*)(?=_X\.\.\.)/;
         $hash_ref->{target}[$target_index]->{name} = [$1];
      } elsif (($line =~ /^Missing linked source file:/) ||
               ($line =~ /^Link points outside project file:/) ||
               ($line =~ /^Cross-reference to excluded file removed from output./) ||
               ($line =~ /^Failed to update:/) ||
               ($line =~ /^Excluded from output:/) ||
               ($line =~ /^Missing cross-referenced file:/) ||
               ($line =~ /^File could not be loaded/) ||
               ($line =~ /^Use of undefined variable/) ||
               ($line =~ /^Cross-referenced topic is not part of TOC:/)) {
         $issues_index += 1;
         chomp($line);  # Remove newlines
         # For some messages, it seems they are related to what happened in the previous line,
         # so append that as a suggestion for helping in troubleshooting the message
         if (($line =~ /^Missing linked source file:/) ||
             ($line =~ /^Use of undefined variable/) ||
             ($line =~ /^File could not be loaded/) ||
             ($line =~ /^Cross-reference to excluded file removed from output./)) {
            $line =~ s/\.+$//;  # Remove any trailing punctuation
            $line .= " (in " . $previous_line . "?)";
         }
         $hash_ref->{target}[$target_index]->{issues}->{issue}[$issues_index] = $line;
      } elsif ($line =~ /^Processing (CSS|topic):/) {
         $processed_content_index += 1;
         chomp($line);  # Remove newlines
         $line =~ s/\.+$//;  # Remove any trailing punctuation
         $line =~ s/^Processing (CSS|topic): //;  # Remove any leading info text
         $hash_ref->{target}[$target_index]->{processed_files}->{file}[$processed_content_index] = $line;
      } elsif ($line =~ /^Generated /) {
         $generated_content_index += 1;
         chomp($line);  # Remove newlines
         $line =~ s/^Generated //;  # Remove any leading info text
         $hash_ref->{target}[$target_index]->{generated_files}->{file}[$generated_content_index] = $line;
      }
      chomp($line);
      $previous_line = $line;
   }
   close $filehandle;
   return $hash_ref;
}

# This is a function to write a file with content
# Input:
#        $file - path to file to write
#        $content - content of the file
# Output:
#        File is created with the content that was provided
sub writeFile {
   my $file = shift;
   my $content = shift;
   print "Writing out build report to $file\n";
   open(FOUT, ">$file") or die "*** Error: Cannot open output file $file\n";
   binmode(FOUT, ":utf8");
   print (FOUT $content);
   close(FOUT);
}

my $log_hash_ref = &getHashRef($input_log_file);

# XMLout takes a hash reference and returns an XML encoding of that structure
my $xmlstring = XMLout($log_hash_ref,
                       RootName => "data",
                       XMLDecl => '<?xml version="1.0" encoding="utf-8"?>');

my $outputfile = 'report.xml';

&writeFile($outputfile, $xmlstring);

print "Script is done!\n";