function lstruct_out = section_lstruct (lstruct, ind)
% Get a section from a line structure
%
%   >> lstruct_out = section_lstruct (lstruct, ind)
%
% Input:
% ------
%   lstruct     Line structure: fields
%                   cstr        Row cellstr, trimmed both ends and blank lines removed
%                   cstr0       Row cellstr untrimmed lines but blank lines removed
%                   ind         Line numbers in original file
%                   flname      File name of original file
%                   flname_full Full file name of original file
%
%   ind         Array of line indicies into cstr
%
% Output:
% -------
%  lstruct_out  Line structure: fields
%                   cstr        Row cellstr, trimmed both ends and blank lines removed
%                   cstr0       Row cellstr untrimmed lines but blank lines removed
%                   ind         Line numbers in original file
%                   flname      File name of original file
%                   flname_full Full file name of original file


lstruct_out.cstr = lstruct.cstr(ind);
lstruct_out.cstr0 = lstruct.cstr0(ind);
lstruct_out.ind = lstruct.ind(ind);
lstruct_out.flname = lstruct.flname;
lstruct_out.flname_full = lstruct.flname_full;
