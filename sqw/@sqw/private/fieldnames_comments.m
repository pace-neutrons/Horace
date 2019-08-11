function names = fieldnames_comments(this)
% Comments to attach to fieldnames - useful output for generic set command
% Does not replace instrinsic fieldnames. 

% Original author: T.G.Perring
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)

% Inspired by:
% A Comprehensive Guide to Object Oriented Programming in MATLAB
%   Chapter 9 example set
%   (c) 2004 Andy Register


names = {...
    'main_header' {{'structure (1x1)'}} ...
    'header' {{'structure (1x1) or cellarray of structures (nx1) n>1'}}...
    'detpar' {{'structure (1x1)'}}...
    'data' {{'structure (1x1)'}}...
    }';
