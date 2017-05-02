function [ok, mess, lstruct, source] = read_file (flname)
% Read lines of text from file as row cellstr
%
%   >> [ok, mess, lstruct] = read_file (flname)
%
% Input:
% ------
%   flname      File name
%
% Output:
% -------
%   ok          True if all OK, false otherwise
%
%   mess        Empty string if all OK, error message if not
%
%   lstruct     Line structure: fields
%                   cstr        Row cellstr, trimmed both ends and blank lines removed
%                   cstr0       Row cellstr untrimmed lines but blank lines removed
%                   ind         Line numbers in original file
%                   flname      File name of original file
%                   flname_full Full file name of original file
%
%   source      Row cellstr of untrimmed lines and blank lines, exactly as read from file


% Default output
lstruct.cstr={}; lstruct.cstr0={}; lstruct.ind=[]; lstruct.flname=''; lstruct.flname_full='';

% Get data from source
[fname_full,ok,mess]=translate_read(flname);
if ok
    [source,ok,mess] = textcell (fname_full);
    if ~ok
        return
    end
else
    return
end

% Trim and remove blank lines, and pack as structure
[cstr,~,nonempty]=str_trim_cellstr(source);
nstr=numel(cstr);
if nstr==0
    return
end

ind = find(nonempty)';      % make row;
lstruct.cstr0=source(ind);
lstruct.cstr=cstr';         % make row vector
lstruct.ind=ind;
lstruct.flname=flname;
lstruct.flname_full=fname_full;
