function wout=recompute_bin_data(w)
% Given sqw_type object, recompute w.data.s and w.data.e from the contents of pix array
%
%   >> wout=recompute_bin_data(w)

% See also average_bin_data, which uses en essentially the same algorithm. Any changes
% to the one routine must be propagated to the other.

% Original author: T.G.Perring
%
% $Revision$ ($Date$)

wout=w;

nbin=numel(w.data.npix);

%t1=tic();

try
    %error('MATLAB:nomem','bla=bla')   
    i  = int32(1:nbin);
    npix = reshape(w.data.npix,numel(w.data.npix),1);
    allocatabable = npix(i)~=0;
    i = i(allocatabable);
    ti = arrayfun(@(ind)({int32(ones(npix(ind),1))*ind}),i);
    ind = cat(1,ti{:});

    clear i ti allocatable;
catch ME
    switch ME.identifier
        case 'MATLAB:nomem'
            clear i ti allocatable;
            
            nend=cumsum(w.data.npix(:));
            npixtot=nend(end);
            nbeg=nend-w.data.npix(:)+1;
            ind=zeros(npixtot,1,'int32');
            
            
            if get(hor_config,'horace_info_level')>0
                warning('SQW:recompute_bin_data',' not enough memory to define bin indexes, running slow loop')
            end
            for i=1:nbin
                ind(nbeg(i):nend(i))=i;
            end
            if get(hor_config,'horace_info_level')>0
                warning('SQW:recompute_bin_data',' slow loop completed')
            end
            
        otherwise
            rethrow(ME);
    end
end
%t=toc(t1)


wout.data.s=accumarray(ind,w.data.pix(8,:),[nbin,1])./w.data.npix(:);
wout.data.s=reshape(wout.data.s,size(w.data.npix));
% separate into two steps to save memory
npix2 = (w.data.npix(:).^2);
wout.data.e=accumarray(ind,w.data.pix(9,:),[nbin,1])./npix2;
clear npix2;
wout.data.e=reshape(wout.data.e,size(w.data.npix));
nopix=(w.data.npix(:)==0);
wout.data.s(nopix)=0;
wout.data.e(nopix)=0;


