function [w,ok,mess]=get_mask(filename)
% Read an ASCII .msk file
%
%   >> [w,ok,mess]=get_mask(filename)
%
% Input:
% ------
%   filename        Name of map file from which to read data
%
% Output:
% -------
%   w               Structure with a single field:
%               .msk    Contains a list of spectra to be masked, where all spectrum
%                      numbers are greater than or equal to one. The array is sorted into
%                      numerically increasing order, with duplicates removed.
%
%   ok              =true if all OK; =false otherwise
%
%   mess            ='' if OK==true error message if OK==false
%
%
% Format of a map file:
% ---------------------
% Lines of data with a integer sequences separated by spaces or commas e.g.
%       11:34,55-70,80
% Blank lines and comment lines (lines beginning with ! or %) are skipped over
% Comments can also be put at the end of lines


% Remove blanks from beginning and end of filename
[file_tmp,ok,mess]=translate_read(strtrim(filename));
if ~ok
    w=[];
    return
end

% Read file (use matlab, as files are generally small, so Fortran or C++ code not really necessary)
str=strtrim(textcell(file_tmp));
nline=numel(str);
if nline==0
    w=[]; ok=false; mess='Data file is empty'; return
end

% Process data from file
% ----------------------
% Have a try...catch block so that wherever the failure takes place, the file can always be closed and the error thrown

nmax=1e8;   % in case there is some silly mistake in the syntax
[w.msk,le_nmax]=str_to_iarray(str,nmax);
if ~le_nmax
    w=[]; ok=false; mess=['More than ',num2str(nmax),' masked spectra encountered - probably a syntax error in the file']; return
end

% OK if got to here
ok=true;
mess='';
