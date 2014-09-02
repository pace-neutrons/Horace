function n=fmt_nbytes(fmt)
% Return the number of bytes for one item of the given format type
%
%   >> n=fmt_nbytes(fmt)
%
% Input:
% ------
%   fmt     Format string e.g. 'float64',  'int32'
%
% Ouptut:
%   n       Number of bytes for a scalar entry of the format (8 and 4 for the examples above)

if strcmp(fmt(end-1:end),'64')
    n=8;
elseif strcmp(fmt(end-1:end),'32')
    n=4;
elseif strcmp(fmt(end-1:end),'16')
    n=2;
elseif strcmp(fmt(end:end),'8')
    n=1;
end
