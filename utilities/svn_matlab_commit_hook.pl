#!/usr/bin/perl -w
###############################################################################
use strict;
###############################################################################
# script takes the text file supplied as input parameter, finds the string 
# COMMIT_COUNTER :: {num}
# in this file and increases the number {num} near the COMMIT_COUNTER in this file. 
#
# When this script is installed as the precommit hook
# for TortoseSVN, and the text file supplied as the input parameter for this file 
# is under version control with correspondent properties enabled, 
# the modification above lead to the mofification of the file version and revision to 
# the current subversion value. 
# 
# 
if ($#ARGV != 0){
  print "\n\n Usage: commit_hook version_file.m  \n\n";
  exit 0;
};

my $version_file=$ARGV[0];
my $pair_separator='::';  # the separator dividing value from the key
my $val_framing   =' ';   # the framing aroung value (can be empty)
my $keyC  = 'COMMIT_COUNTER';
my %rep_keys = ($keyC=>'');
#print " version $version_file \n";
#print " enter something to continue \n";
#my $tt = <STDIN>;


%rep_keys=get_values($version_file,$pair_separator,$val_framing,%rep_keys);
my $val = $rep_keys{$keyC};
if($val=~/\d/){
    $val+=1;
}else{
    $val =1;
}
$rep_keys{$keyC}=$val;

set_values($version_file,$pair_separator,$val_framing,%rep_keys);

exit(0);
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
###############################################################################
sub replace_value{   #12/24/09 1:25:PM
###############################################################################
# replace walue corresponding to the key, in the input string $data
# The $data is formatted according to the Tortose SVN rules. 
    my($key,$value,$pairs_separator,$val_framing,$data)=@_;
    my @tmp=split(/\$/,$data);
    my($i,@buf, $is_chomped);
    
    for($i=0;$i<=$#tmp;$i++){
        my @pair = split(/$pairs_separator/,$tmp[$i]);
        
        if($#pair==0){    next;  # no key-walue pairs, key is empty  
        }

        if($pair[0] =~ m/$key/){  # extract key
            $is_chomped = chomp($pair[1]);
            if($val_framing eq ''){                
                $pair[1]=$value;
            }else{   # we expect value to have $val_framing around it
                $pair[1] =~s/^$val_framing//;
                $pair[1] =~s/$val_framing$//;                
                $pair[1]=$val_framing.$value.$val_framing;
            }
            if($is_chomped){
                    $pair[1]=$pair[1]."$/";
            }
            
            $tmp[$i]=join($pairs_separator,@pair);
            last;
        }
    }
    $data=join('$',@tmp);
    
    return $data;
}
###############################################################################
sub set_values{   #12/24/09 1:25:PM
# read the file and replace the values from the file corresponding to the keys,
# specified in the imput hash, by the values corresponding to the hash values
###############################################################################
    my($out_file,$separator,$val_framing,%rep_keys)=@_;
    my($wk_file)="tmp.dat";
    my($data,$rd,$the_key,$the_value,$i);
    my (@kk) = keys(%rep_keys);
    
    open(OUTDATA,">$wk_file") || die " can not open temporary file $wk_file for keys replacet\n";
    open(INDATA,$out_file)    || die " can not open target file $out_file\n";
    
    while($data=<INDATA>){
        for($i=0;$i<=$#kk;$i++){
            $the_key=$kk[$i];
            if($data=~m/$the_key/){
                $the_value=$rep_keys{$the_key};
                $data=replace_value($the_key,$the_value,$separator,$val_framing,$data);
            }
        }
        print OUTDATA $data;
    }
    close(OUTDATA);
    close(INDATA);
    unlink($out_file) || die " can not delete $out_file, the resulting file $wk_file exists and you should rename it manually\n";
    rename($wk_file,$out_file) || die " can not rename temporary file $wk_file to a target file $out_file";
}

###############################################################################
sub get_values{   #12/24/09 1:25:PM
#    get the list of values corresponding to the list of keys from the file
#    the pairs are identified by $key_val_separator; the value can be surrounded by
#   $value_framing parameter
###############################################################################
    my($data_file,$key_val_separator,$value_framing,%rep_keys)=@_;
    my(@row,@buf,$ic,$jc,$data,$the_key,$the_value);
    my @kk = keys(%rep_keys);  # the keys, which values we try to identify from the file
    
    open(INDATA,$data_file) || die(" can not open Template file $data_file");    
    while($data=<INDATA>){

        @row = split(/$key_val_separator/,$data); # we detect prospective "key->value" pairs following the appearence of the $key_val_separator
        if($#row==0){           next;  # have to be pairs, othrewise the key is empty 
        }
        
        for($ic=0;$ic<$#row;$ic++){   # value can be empty, so need to go by one rather then by 2
            for($jc=0;$jc<=$#kk;$jc++){
                $the_key = $kk[$jc];                
                if($row[$ic]=~m/$the_key/){
                    
                    chomp($row[$ic+1]);
                    if($value_framing eq ''){                       
                        $the_value= $row[$ic+1];                        
                    }else{
                        @buf = split($value_framing,$row[$ic+1]);
                        $the_value= $buf[1];                        
                    }

                    $rep_keys{$the_key}=$the_value;
                }
                
            }
        }
    }
    close(INDATA);
    return %rep_keys;
}
