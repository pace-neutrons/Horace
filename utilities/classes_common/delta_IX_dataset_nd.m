function del_out=delta_IX_dataset_nd(w1,w2,tol,verbose)
% Report the different between two IX_dataset_nd objects
%
%   >> delta_IX_dataset_nd(w1,w2)
%   >> delta_IX_dataset_nd(w1,w2,tol)           % -ve tol then |tol| is relative tolerance
%   >> delta_IX_dataset_nd(w1,w2,tol,verbose)   % verbose=true then print message even if equal
%
%   >> del = delta_IX_dataset_nd(...)
%
% if tol>0, then absolute tolerance
% if tol<0, then relative tolerance

if ~exist('tol','var')||isempty(tol), tol=0; end
if ~exist('verbose','var')||isempty(tol), verbose=false; end

if isstruct(w1) && isstruct(w2)     % assume structure with fields val and err, as produced by integration
    del=zeros(1,2);
    delrel=zeros(1,2);
    [del(1),delrel(1)]=del_calc(w1.val,w2.val);
    [del(2),delrel(2)]=del_calc(w1.val,w2.val);
else
    h1=ishistogram(w1);
    h2=ishistogram(w2);
    nd1=numel(h1);
    nd2=numel(h2);
    if nd1~=nd2
        disp('Different dimensionality')
        del_out=[];
        return
    end
    if ~all(h1==h2)
        disp('One or more corresponding axes are not both histogram or point data')
        if nargout>0, del_out=[]; end
        return
    end
    
    del=zeros(1,nd1+2);
    delrel=zeros(1,nd1+2);
    for i=1:nd1
        x1=axis(w1,i);
        x2=axis(w2,i);
        if x1.distribution~=x2.distribution
            disp(['Axis ',num2str(i),': one object is a distribution, the other not'])
            if nargout>0, del_out=[]; end
            return
        end
        if numel(x1.values)==numel(x2.values)
            [del(i),delrel(i)]=del_calc(x1.values,x2.values);
        else
            disp(['Axis ',num2str(i),': different number of data points along this axis'])
            if nargout>0, del_out=[]; end
            return
        end
        if ~isequal(x1.axis,x2.axis)
            disp(['Axis ',num2str(i),': IX_axis descriptions differ'])
            if nargout>0, del_out=[]; end
            return
        end
    end
    [del(nd1+1),delrel(nd1+1)]=del_calc(w1.signal(:),w2.signal(:));
    [del(nd1+2),delrel(nd1+2)]=del_calc(w1.error(:),w2.error(:));
end

delmax=max(del);
delrelmax=max(delrel);
if tol<0
    if nargout>0, del_out=delrel; end
    if delrelmax<=abs(tol)
        if verbose, disp('Numerically equal objects'), end
    else
        disp(['WARNING: Numerically unequal objects:    ',num2str(delrel)])
    end
else
    if nargout>0, del_out=del; end
    if delmax<=tol
        if verbose, disp('Numerically equal objects'), end
    else
        disp(['WARNING: Numerically unequal objects:    ',num2str(del)])
    end
end



%============================================================================================
function [del,delrel]=del_calc(v1,v2)
% Get absolute and absolute relative differences between two arrays
num=v1-v2;
den=max(max(abs(v1),abs(v2)),1);
del=max(abs(num));
delrel=max(abs(num)./den);
