function yes=isstring(v)
% true id variable is a character string i.e. 1xn character array or empty character array
yes=ischar(v) && (isrow(v) || isempty(v));
