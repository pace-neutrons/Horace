function wtot=sum_objectarr(w,dim)
% Sum an array of objects following the same rules as the intrinisc sum function
%
%   >> wtot=sum_object(w)
%   >> wtot=sum_object(w,dim)
%
% Tpye >> help sum   for the matlab help for the intrinsic function.

if ~isobject(w)
    error('Only sums objects that are not intrinsic to matlab.')
end

if isvector(w)
    wtot=w(1);
    for i=2:numel(w)
        wtot=wtot+w(i);
    end
else
    sz=size(w);
    if nargin==2
        if ~(isnumeric(dim) && isscalar(dim) && dim>0 && dim==round(dim))
            error('Dimension argument must be a positive integer scalar within indexing range.')
        elseif numel(sz)<dim || sz(dim)==1
            wtot=w;         % behaviour of sum is to return unchanged if dim exceeds indexing range
            return
        end
    elseif nargin==1
        dim=find(sz~=1,1);  % guaranteed to be non-zero, as the case of scalar input object caught by isvector
    end
    szout=sz; szout(dim)=1;
    if ~isempty(w)
        if dim==1
            szwork=[sz(1),prod(sz(2:end))];
            wtmp=reshape(w,szwork);
            wtot=wtmp(1,:);
            for i=2:sz(dim)
                wtot=wtot+wtmp(i,:);
            end
        elseif dim<numel(sz)
            szwork=[prod(sz(1:dim-1)),1,prod(sz(dim+1:end))];
            wtmp=reshape(w,szwork);
            wtot=wtmp(:,1,:);
            for i=2:sz(dim)
                wtot=wtot+wtmp(:,i,:);
            end
        else
            szwork=[prod(sz(1:end-1)),sz(end)];
            wtmp=reshape(w,szwork);
            wtot=wtmp(:,1);
            for i=2:sz(dim)
                wtot=wtot+wtmp(:,i);
            end
        end
        wtot=reshape(wtot,szout);
    else
        wtot=repmat(eval(class(w)),szout);     % *** I cannot think of a way of calling the default constructor without the eval function
    end
end
