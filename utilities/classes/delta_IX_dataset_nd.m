function [ok,mess,del_out]=delta_IX_dataset_nd(w1,w2,tol)
% Report the difference between two IX_dataset_nd objects if outside a given tolerance
%
%   >> [ok,mess,del]=delta_IX_dataset_nd(w1,w2)
%   >> [ok,mess,del]=delta_IX_dataset_nd(w1,w2,tol)
%
% Input:
% ------
%   w1, w2  IX_datset_nd objects to be compared (must both be scalar)
%
%   tol     Tolerance criterion for equality
%               if tol>=0, then absolute tolerance
%               if tol<0,  then relative tolerance (|tol| is absolute tolerance if
%                         max(a,b)<1 where a,b, are being tested for equivalence)
% Output:
% -------
%   ok      True if inside tolerance, false if outside or there is an error
%
%   mess    Warning message if del lies outside acceptable tolerance
%           Error message if del==[] (i.e. there was an error)
%           If ok (i.e. within tolerance), then mess is set to ''
%
%   del     Array containing maximum differences [x_1, x_2, ...,x_nd, signal, error]
%           Absolute or relative according to sign of tol
%           Set to [] if cannot compare the objects (e.g. different dimensionality)
%
% If the function is called no return arguments then if not ok (i.e. outside
% tolerance or an error) then the message is printed to the screen and
% an error is thrown.

if ~exist('tol','var')||isempty(tol), tol=0; end

% Check consistency of the two objects and get numerical differences
if isa(w1,'IX_dataset') && isa(w2,'IX_dataset')
    % Case of IX_dataset_nd object (n=integer)
    h1=ishistogram(w1);
    h2=ishistogram(w2);
    nd1=numel(h1);
    nd2=numel(h2);
    if nd1~=nd2
        ok=false; mess='Datasets have different dimensionality'; del_out=[];
        if nargout>0, return, else, error(mess), end
    end
    if ~all(h1==h2)
        ok=false; mess='One or more corresponding axes are not both histogram or point data'; del_out=[];
        if nargout>0, return, else, error(mess), end
    end
    
    del=zeros(1,nd1+2);
    delrel=zeros(1,nd1+2);
    for i=1:nd1
        x1=axis(w1,i);
        x2=axis(w2,i);
        if x1.distribution~=x2.distribution
            ok=false; mess=['Axis ',num2str(i),': one axis is a distribution, the other not']; del_out=[];
            if nargout>0, return, else, error(mess), end
        end
        if numel(x1.values)==numel(x2.values)
            [del(i),delrel(i)]=del_calc(x1.values,x2.values);
        else
            ok=false; mess=['Axis ',num2str(i),': different number of data points along this axis']; del_out=[];
            if nargout>0, return, else, error(mess), end
        end
        if ~isequal(x1.axis,x2.axis)
            ok=false; mess=['Axis ',num2str(i),': IX_axis descriptions differ']; del_out=[];
            if nargout>0, return, else, error(mess), end
        end
    end
    [del(nd1+1),delrel(nd1+1)]=del_calc(w1.signal(:),w2.signal(:));
    [del(nd1+2),delrel(nd1+2)]=del_calc(w1.error(:),w2.error(:));
else
    fname={'val';'err'};
    if isstruct(w1) && isstruct(w2) && isequal(fname,fields(w1)) && isequal(fname,fields(w2))
        if  isnumeric(w1.val) && isnumeric(w1.err) && isnumeric(w2.val) && isnumeric(w2.err) &&...
                isequal(size(w1.val),size(w2.val)) && isequal(size(w1.err),size(w2.err)) && isequal(size(w1.val),size(w1.err))
            % Case of a structure with fields val and err, as produced by integration
            del=zeros(1,2);
            delrel=zeros(1,2);
            [del(1),delrel(1)]=del_calc(w1.val,w2.val);
            [del(2),delrel(2)]=del_calc(w1.err,w2.err);
        else
            ok=false; mess='One or both of the fields ''val'' and ''err'' have different sizes'; del_out=[];
            if nargout>0, return, else, error(mess), end
        end
    else
        ok=false; mess='Unrecognised objects for comparison in this function'; del_out=[];
        if nargout>0, return, else, error(mess), end
    end
end

% Check if objects agree to requested tolerance
if tol<0
    del_out=delrel;
    del_max=max(del_out);
    if del_max>abs(tol)
        ok=false;
        mess=['Relative tolerance criterion failed: maximum relative error = ',num2str(del_max)];
        if nargout>0, return, else, error(mess), end
    else
        if nargout>0, ok=true; mess=''; end
    end
else
    del_out=del;
    del_max=max(del_out);
    if del_max>abs(tol)
        ok=false;
        mess=['Absolute tolerance criterion failed: maximum error = ',num2str(del_max)];
        if nargout>0, return, else, error(mess), end
    else
        if nargout>0, ok=true; mess=''; end
    end
end



%============================================================================================
function [del,delrel]=del_calc(v1,v2)
% Get absolute and relative differences between two vectors.
%
%   >> [del,delrel]=del_calc(v1,v2)
%
% Where the maximum absolute magnitude of a pair of elements is less than unity, it is treated as unity
% i.e. the relative difference becomes the absolute difference, or equivalently, the
% returned relative difference is alway less than or equal to the absolute difference.
% This is to avoid problems with large relative differences from rounding errors, which
% is against the spirit of the check that this function is designed for.
%
% Note that if divide by zero, then the NaNs are ignored in the max function, so no problem!
num=v1-v2;
den=max(max(abs(v1),abs(v2)),1);
del=max(abs(num));
delrel=max(abs(num)./den);
