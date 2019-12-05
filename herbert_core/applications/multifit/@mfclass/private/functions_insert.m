function Sfun = functions_insert (Sfun_in, isfore, ind)
% Insert default function handle(s) and parameter list(s)
%
%   >> Sfun = functions_insert (Sfun_in, isfore, ind)
%
% Input:
% ------
%   Sfun_in Functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_
%
%   isfore  True if foreground functions, false if background functions
%
%   ind     Indicies after which the functions are to be inserted (row vector)
%           One index per function, in the range
%               foreground functions:   0:(numel(Sfun.fun_)
%               background functions:   0:(numel(Sfun.bfun_)
%           Id empty (i.e. []) then nothing is done
%
% Output:
% -------
%   Sfun    Updated functions structure: fields are 
%               foreground_is_local_, fun_, pin_, np_, free_
%               background_is_local_, bfun_, bpin_, nbp_, bfree_


% Original author: T.G.Perring
%
% $Revision:: 838 ($Date:: 2019-12-05 14:56:03 +0000 (Thu, 5 Dec 2019) $)


% Fill output with default structure
Sfun = Sfun_in;
if numel(ind)==0
    return
end

% Update properties
if isfore
    [Sfun.fun_, Sfun.pin_, Sfun.np_, Sfun.free_] = insert (Sfun.fun_,...
        Sfun.pin_, Sfun.np_, Sfun.free_, ind);
else
    [Sfun.bfun_, Sfun.bpin_, Sfun.nbp_, Sfun.bfree_] = insert (Sfun.bfun_,...
        Sfun.bpin_, Sfun.nbp_, Sfun.free_, ind);
end


%------------------------------------------------------------------------------
function [fun_out, pin_out, np_out, free_out] = insert (fun, pin, np, ind)
% Insert elements into arrays after locations given by ind

n = numel(ind);
fun_out  = [fun, cell(1,n)];
pin_out  = [pin, repmat(mfclass_plist(),1,n)];
np_out   = [np, zeros(1,n)];
free_out = [free_, repmat({true(1,0)},1,n)];

[~,ix] = sort([1:numel(np), ind]);
fun_out  = fun_out(ix);
pin_out  = pin_out(ix);
np_out   = np_out(ix);
free_out = free_out(ix);

