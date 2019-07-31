function [ok,mess,func]=function_handles_parse(func_in,size_w,local)
% Make a cell array of function handles
%
%   >> [ok,mess,func]=function_handles_parse(func_in,size_w,local)
%
% Input:
% ------
%   func_in Cell array of handles to functions
%           Some, but not all, elements of the cell array can be empty.
%          Empty elements will be later interpreted as not having a
%          function to evaluate for the corresponding data set.
%
%   size_w  Size of the array of data sets
%           If local==true, then a single function handle or scalar cell array with
%          one function handle will be expanded to a cell array of handles
%          with this size. A cell array of handles if not scalar will
%          be checked to have this number of elements. Must have prod(size_nw))>=1
%
%   local   True if require functions local to each dataset, false if single
%          global function is required
%
% Output:
% -------
%   ok      Status flag: =true if all OK; =false if not
%   mess    Error message: empty if OK, non-empty otherwise
%   func    Cell array of function handles. Missing functions are represented
%          by empty elements (anything for which isempty(func{i})==true)
%           if local: func is a cell array with size given by size_w
%           if not:   func is a scalar cell array (and contains a function handle)

ok=true;
mess='';
if local
    if isscalar(func_in) && prod(size_w)>1
        func=repmat(func_in,size_w);
    elseif numel(func_in)==prod(size_w)
        if numel(size(func_in))==numel(size_w) && all(size(func_in)==size_w(:)')
            func=func_in;
        else
            func=reshape(func_in,size_w);  % get to same shape as data array
        end
    else
        ok=false;
        mess='Function handle argument must be scalar or have same size as data array for local fitting functions';
        func={};
    end
else
    if isscalar(func_in)
        func=func_in;
    else
        ok=false;
        mess='Function handle argument must be scalar for global fitting function';
        func={};
    end
end
