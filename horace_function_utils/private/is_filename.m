function ok=is_filename(infile)
% Determine if an argument has format to be a valid file name or set of file names
ok=false;
sz=size(infile);
if ~isempty(infile)
    % A character string starting with '-' is interpreted as a keyword option
    % [Note: the test:  strtrim(infile(1))=='-'  works even if the lhs is empty]
    if (ischar(infile) && ~(numel(sz)==2 && sz(1)==1 && strtrim(infile(1))=='-')) || iscellstr(infile)
        ok=true;
    end
end
