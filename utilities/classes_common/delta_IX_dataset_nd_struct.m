function delta_IX_dataset_nd_struct(w1,w2,varargin)
% Report the different between two structures of IX_dataset_nd objects
%
%   >> delta_IX_dataset_nd_struct(w1,w2)
%   >> delta_IX_dataset_nd_struct(w1,w2,tol)           % -ve tol then |tol| is relative tolerance
%   >> delta_IX_dataset_nd_struct(w1,w2,tol,verbose)   % verbose=true then print message even if equal
%
% Input:
% ------
%   w1, w2  IX_datset_nd objects to be compared (must both be scalar)
%   tol     Tolerance criterion for equality
%               if tol>=0, then absolute tolerance
%               if tol<0, then relative tolerance
%   verbose If verbose=true then print message even if equal

fname1=sort(fields(w1));
fname2=sort(fields(w2));

if ~isequal(fname1,fname2)
    error('Structures do not have the same fields')
end

for i=1:numel(fname1)
    if numel(w1.(fname1{i}))~=numel(w1.(fname1{i}))
        error('Number of elements do not match')
    end
end

disp('Working...')
for i=1:numel(fname1)
    for j=1:numel(w1.(fname1{i}))
%        disp([num2str(i),'  ',num2str(j)])
        delta_IX_dataset_nd(w1.(fname1{i})(j),w2.(fname2{i})(j),varargin{:});
    end
end
disp(' ')
disp('Done')
disp(' ')
