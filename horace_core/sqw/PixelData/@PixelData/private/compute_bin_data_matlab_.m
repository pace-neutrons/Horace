function [mean_signal, mean_variance] = compute_bin_data_matlab_(obj, npix, log_level)
% Compute bin mean signal and variance using matlab routines
%
% See compute_bin_data for algorithm details
%
nbin=numel(npix);

try
    i  = int64(1:nbin);
    npix = reshape(npix,numel(npix),1);
    allocatabable = npix(i)~=0;
    i = i(allocatabable);
    if isempty(i)
        ind = [];
    else
        ti = arrayfun(@(ind)({int64(ones(npix(ind),1))*ind}),i);
        ind = cat(1,ti{:});
        clear i ti allocatable;
    end
catch ME
    switch ME.identifier
        case 'MATLAB:nomem'
            clear i ti allocatable;

            nend=cumsum(npix(:));
            npixtot=nend(end);
            nbeg=nend-npix(:)+1;
            ind=zeros(npixtot,1,'int32');

            if log_level>0
                warning('SQW:recompute_bin_data', ...
                        'Not enough memory to define bin indexes, running slow loop')
            end
            for i=1:nbin
                ind(nbeg(i):nend(i))=i;
            end
            if log_level>0
                warning('SQW:recompute_bin_data',' slow loop completed')
            end

        otherwise
            rethrow(ME);
    end
end

if ~isempty(ind)
    mean_signal=accumarray(ind,obj.signal,[nbin,1])./npix(:);
    mean_signal=reshape(mean_signal,size(npix));
    % separate into two steps to save memory
    npix2 = (npix(:).^2);
    mean_variance=accumarray(ind,obj.variance,[nbin,1])./npix2;
    clear npix2;
    %
    mean_variance=reshape(mean_variance,size(npix));
    nopix=(npix(:)==0);
    mean_signal(nopix)=0;
    mean_variance(nopix)=0;
end
