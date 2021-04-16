function out = arrayfun(fun,array,varargin)
% implements matlab's arrayfun for array of sqw objects
%
% on 10/06/2017 its a draft inclmplete version missing number of
% features as a new style classes should have Matlab native arrayfun
% function availible.

% It does not process multiple fun arguments and fails strangely on
% encountering one

if ~isa(fun,'function_handle')
    error('HORACE:sqw:invalid_argument',...
        'first argument of arrayfun should be a function handle');
end
%
pa = inputParser();
pa.KeepUnmatched = true;
addParameter(pa,'UniformOutput',true,...
    @(x)(assert(isscalar(x)&&(isnumeric(x)||islogical(x)),...
    'The UnitormOutput value should be transferrable to logical')));

parse(pa,varargin{:});
uniformOutput= pa.Results.UniformOutput;


if nargout>0
    if uniformOutput
        tout = fun(array(1));
        out = repmat(tout,size(array));
        for i=2:numel(array)
            out(i) = fun(array(i));
        end
    else
        out = cell(size(array));
        for i=1:numel(array)
            out{i} = fun(array(i));
        end
        
    end
else
    for i=1:numel(array)
        fun(array(i));
    end   
end



