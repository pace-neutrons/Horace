function [filepath,filename] = parse_full_filename(full_filename)
%PARSE_FULL_FILENAME used by Horace sqw object to transform input filename
%into standard form used by the object. Also can be used to obtain this
%standard form for any input character array or string
%
% Input:
% full_filename  -- string or character array representing the full
%                   filename (with path)
% Returns:
% filepath       -- character array representing path to the file
% filename       -- character array representing name of the input file.
%                   if input filename did not have extension, the input
%                   name modified to have extension '.sqw'
%
if ~istext(full_filename)
    error('HERBERT:utilities:invalid_argument', ...
        'full_filename should be a string, describing full name of the file on disk.\n It is: %s', ...
        disp2str(full_filename));
end
if ~ischar(full_filename) && numel(full_filename)>1
    error('HERBERT:utilities:invalid_argument', ...
        ['This utilities accepts single filename only.\n' ...
        ' Provided %d elements of class: "%s"'],...
        numel(full_filename),class(full_filename));
end
if isempty(full_filename)||strlength(full_filename)==0
    filepath = '';
    filename = '';
    return;
end
[fp,fn,fe] = fileparts(full_filename);
filepath = char(fp);

if strlength(fe)==0
    fe = '.sqw';
end
filename = char(sprintf("%s%s",fn,fe));
