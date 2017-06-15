function out = arrayfun(fun,array,varargin)
% implements matlab's arrayfun for array of sqw objects
%
% on 10/06/2017 its a draft inclmplete version missing number of 
% features as a new style classes should have Matlab native arrayfun
% function availible.

if ~isa(fun,'function_handle')
    error('SQW:invalid_argument','first argument of arrayfun should be a function handle');
end

if nargin == 2
    if nargout>0
        tout = fun(array(1));
        out = repmat(tout,size(array));
        
        for i=2:numel(array)
            out(i) = fun(array(i));
        end
    else
        for i=1:numel(array)
            fun(array(i));
        end
        
    end
else
    error('SQW:not_implemented','multiple sqw arguments is not yet implemented');
end



