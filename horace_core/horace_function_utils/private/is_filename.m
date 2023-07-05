function ok = is_filename(infile)
% Determine if an argument has format to be a valid file name or set of file names
% A a non-empty character string not beginning with '-', or a cell array of character strings, is
% permitted. This does not mean that they are valid file names, but it means that the special case of an option
% (which by convention usually starts with '-') is caught.

ok = ~isempty(infile) && ...
     (istext(infile) && isrow(infile) || iscellstr(infile)) && ...
      ~any(strncmp(strtrim(infile),'-',1))

end
