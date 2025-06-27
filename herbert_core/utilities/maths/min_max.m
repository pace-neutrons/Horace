function res = min_max(input)
%MIN_MAX Ranges of matrix rows.
%
%  <a href="matlab:doc minmax">min_max</a>(X) takes a single matrix of
%  size NxM (or cell array of such matrices) and returns
%  an Nx2 value of min and max values for each row of the matrix (or row
%  of matrices).
%
%  Here min_max is calculated for a random matrix:
%
%  >>xx = <a href="matlab:doc rands">rands</a>(4,5);
%  >>mm = <a href="matlab:doc min_max">min_max</a>(xx);
%  >><a href="matlab:doc size(mm)">size(mm)</a>
%    ans=
%    4   2
%
%  Other example:
%  >>ma = [  1     2     3     4;
%            5     6     7     8]
%  >><a href="matlab:doc min_max">min_max</a>(ma)
%  ans =
%        1     4
%        5     8
%
%  Note:
%   This function implements minmax procedure
%   defined in nnet toolbox or Deep learning toolbox of MATLAB
%   (depending on version) if such toolbox is not available.
%
persistent use_toolbox

if isempty(use_toolbox)
    try
        res = minmax(input);
        use_toolbox = true;
        return;
    catch ME
        if strcmp(ME.identifier,'MATLAB:UndefinedFunction')
            use_toolbox = false;
        else
            rethrow(ME)
        end
    end
end
if use_toolbox
    res = minmax(input);
else
    res = [min(input,[],2),max(input,[],2)];
end