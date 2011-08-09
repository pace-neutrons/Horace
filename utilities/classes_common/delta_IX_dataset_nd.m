function del_out=delta_IX_dataset_nd(w1,w2,tol)
% Report the different between two IX_dataset_nd objects
%
%   >> delta_IX_dataset_nd(w1,w2)   
%   >> delta_IX_dataset_nd(w1,w2,tol)
%
%   >> del = delta_IX_dataset_nd(...)


h1=ishistogram(w1);
h2=ishistogram(w2);
nd1=numel(h1);
nd2=numel(h2);
if nd1~=nd2
    disp('Different dimensionality')
    return
end
if ~all(h1==h2)
    disp('One or more corresponding axes are not both histogram or point data')
    if nargout>0, del_out=[]; end
    return
end

del=zeros(1,nd1+2);
for i=1:nd1
    [x1,hist1,distr1]=axis(w1,i);
    [x2,hist2,distr2]=axis(w2,i);
    if distr1~=distr2
        disp(['Axis ',num2str(i),': one object is a distribution, the other not'])
        if nargout>0, del_out=[]; end
        return
    end
    if numel(x1)==numel(x2)
        del(i)=max(abs(x1-x2));
    else
        disp(['Axis ',num2str(i),': different number of data points along this axis'])
        if nargout>0, del_out=[]; end
        return
    end
end
del(nd1+1)=max(abs(w1.signal(:)-w2.signal(:)));
del(nd1+2)=max(abs(w1.error(:)-w2.error(:)));
delmax=max(del);

if delmax<=tol
%    disp('Numerically equal objects')
else
    disp(['WARNING: Numerically unequal objects:    ',num2str(del)])
end

if nargout>0, del_out=del; end
