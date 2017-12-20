function [ok,mess,fun] = fun_parse (fun_in,size_fun)
% Make a cell array of function handles
%
%   >> [ok,mess,fun] = fun_parse (fun_in,size_fun)
%
% Input:
% ------
%   fun_in  Cell array of handles to functions.
%           Some or all elements of the cell array can be [].
%          Empty elements will be later interpreted as not having a
%          function to evaluate for the corresponding data set.
%
% size_fun  Required size of the output array of function handles
%
% Output:
% -------
%   ok      Status flag: =true if all OK; =false if not
%   mess    Error message: empty if OK, non-empty otherwise
%   fun    Cell array of function handles. Missing functions are represented
%          by [].
%           if local: fun is a cell array with size given by size_w
%           if not:   fun is a scalar cell array (and contains a function handle)
%           If there was an error, then fun={}


% Original author: T.G.Perring
%
% $Revision: 624 $ ($Date: 2017-09-27 15:46:51 +0100 (Wed, 27 Sep 2017) $)


[ok,mess,fun]=is_valid_function_handles(fun_in);
if ~ok, return, end

if numel(fun)>0
    if prod(size_fun)>0
        if isscalar(fun) && prod(size_fun)>1
            fun=repmat(fun,size_fun);
        elseif numel(fun)==prod(size_fun)
            if ~(numel(size(fun))==numel(size_fun) && all(size(fun)==size_fun))
                fun=reshape(fun,size_fun);  % get to same shape as data array
            end
        else
            ok=false;
            mess='Function handle argument must be scalar or have same number of elements as number to be set';
            fun={};
        end
    else
        if ~isscalar(fun) || ~isequal(fun{1},[])
            % Case of fun=[] is ok if prod(size_fun)==0
            ok=false;
            mess='Function handle(s) given but none required';
            fun={};
        end
    end
    
else
    if prod(size_fun)>0
        ok=false;
        mess='Function handle argument is empty but function handle(s) are expected';
        fun={};
    end
end
