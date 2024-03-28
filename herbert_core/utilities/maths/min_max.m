function res = min_max(input)
%MIN_MAX Ranges of matrix rows.
% This function implements minmax procedure
% defined in nnet toolbox of MATLAB if nnet is not available.
%
%  <a href="matlab:doc minmax">minmax</a>(X) takes a single matrix (or cell array of matrices) and returns
%  an Nx2 value of min and max values for each row of the matrix (or row
%  of matrices).
%
%  Here min-max is calculated for a random matrix:
%
%    x = <a href="matlab:doc rands">rands</a>(4,5)
%    mm = <a href="matlab:doc minmax">minmax</a>(x)

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