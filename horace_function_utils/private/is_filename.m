function ok=is_filename(infile)
% Determine if an argument has format to be a valid file name or set of file names
% A a non-empty character string not beginning with '-', or a cell array of character strings, is
% permitted. This does not mean that they are valid file names, but it means that the special case of an option
% (which by convention usually starts with '-') is caught.
ok=false;
sz=size(infile);
if ~isempty(infile)
    % A character string starting with '-' is interpreted as a keyword option
    % [Note: the test:  strtrim(infile(1))=='-'  works even if the lhs is empty]
    if (ischar(infile) && ~(numel(sz)==2 && sz(1)==1 && strncmp(strtrim(infile(1)),'-',1))) || iscellstr(infile)
        ok=true;
    end
end
