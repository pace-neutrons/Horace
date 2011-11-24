function wout=squeeze_IX_dataset_nd(win,iax)
% Sqeeze singleton dimensions awaay in IX_dataset_nd objects to get to object of lower dimensionality
%
%   >> wout=squeeze(win)        % default is to squeeze all dimensions that are singletons
%   >> wout=squeeze(win,iax)    % squeeze only the indicated dimensions, if singletons
%
% If an array of IX_dataset_nd objects, then squeeze only if all output datasets will have the same
% dimensionality. This is so output can also be an array on the same dimensionality IX_dataset_nd objects.

% Check validity of input
ndim=dimensions(win(1));
if nargin==1
    iax=1:ndim;
else
    if any(iax<1) || any(iax>ndim)
        error(['Check list of axes to squeeze contains only integers in range 1-',num2str(ndim)])
    end
end

% Check all datasets have the same axes to be squeezed
remove=false(1,ndim);
remove(iax)=true;
for i=1:numel(win)
    sz=[size(win(i).signal),ones(1,ndim-numel(size(win(i).signal)))];   % this works even if ndim=1, i.e. ones(1,-1)==[]
    if i==1
        keep=(sz>1|~remove);
    else
        if any((sz>1|~remove)~=keep)
            error('Dimensions to be squeezed in the datasets are not all the same')
        end
    end
end
ind=find(keep); % list of axes to keep

% Squeeze the dimensions
if all(keep)
    wout=win;   % trivial case of nothing to be squeezed
elseif ~any(keep)
    if numel(win)==1
        wout.val=win.signal;
        wout.err=win.error;
    else
        val=zeros(1,numel(win));
        err=zeros(1,numel(win));
        for i=1:numel(win)
            val(i)=win(i).signal;
            err(i)=win(i).error;
        end
        wout=IX_dataset_1d(1:numel(win),val,err,win(1).title,IX_axis('Dataset index'),win(1).s_axis,false);
    end
else
    ndim_squeeze=sum(keep);
    if numel(win)==1
        sz=[size(win.signal),ones(1,ndim-numel(size(win.signal)))];
        % Put the trailing 1 on the end, in case of only one dimension after squeezing; reshape needs a size vector with at least two elements
        if ndim_squeeze>1, sz_squeeze=sz(keep); else sz_squeeze=[sz(keep),1]; end
        wout=IX_dataset_nd (win.title, reshape(win.signal,sz_squeeze), reshape(win.error,sz_squeeze), win.s_axis, axis(win(i),ind));
    else
        wout=repmat(IX_dataset_nd(ndim_squeeze),size(win));
        for i=1:numel(win)
            sz=[size(win(i).signal),ones(1,ndim-numel(size(win(i).signal)))];
            % Put the trailing 1 on the end, in case of only one dimension after squeezing; reshape needs a size vector with at least two elements
            if ndim_squeeze>1, sz_squeeze=sz(keep); else sz_squeeze=[sz(keep),1]; end
            wout(i)=IX_dataset_nd (win(i).title, reshape(win(i).signal,sz_squeeze), reshape(win(i).error,sz_squeeze), win(i).s_axis, axis(win(i),ind));
        end
    end
end
