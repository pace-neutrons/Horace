function names = fieldnames_comments(this)
% Comments to attach to fieldnames - useful output for generic set command
% Does not replace instrinsic fieldnames. 

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

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
