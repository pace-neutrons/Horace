function [s,e,npix,pix,urange] = sort_pixels_by_bins_(obj,pix,in_data_range)




% Flag if grid is in fact just a box i.e. 1x1x1x1
grid_is_unity = all(obj.grid_size == [1,1,1,1]);

% Set urange, and determine if all the data is on the surface or within the box defined by the ranges
if isempty(in_data_range)
    urange = obj.urange;   % range of the data
    data_in_range = true;
else
    urange = in_data_range;         % use input urange
    if any(urange(1,:)>obj.urange(1,:)) || any(urange(2,:)<obj.urange(2,:))
        data_in_range = false;
    else
        data_in_range = true;
    end
end
% If grid that is other than 1x1x1x1, or range was given, then sort pixels
if grid_is_unity && data_in_range   % the most work we have to do is just change the bin boundary fields
    s=sum(pix(8,:));
    e = sum(pix(9,:)); % take advantage of the squaring that has already been done for pix array
    npix=size(pix,2);
    urange = obj.urange;
else
    if hor_log_level>-1
        disp('Sorting pixels ...')
    end
    
    [use_mex,nThreads]=config_store.instance().get_value('hor_config','use_mex','threads');
    if use_mex
        try
            % Verify the grid consistency and build axes along the grid dimensions,
            % c-program does not check the grid consistency;
            
            sqw_fields   =cell(1,4);
            sqw_fields{1}=nThreads;
            %sqw_fields{1}=8;
            sqw_fields{2}=urange;
            sqw_fields{3}=obj.grid_size;
            sqw_fields{4}=pix;
            
            out_fields=bin_pixels_c(sqw_fields);
            
            s   = out_fields{1};
            e   = out_fields{2};
            npix= out_fields{3};
            pix = out_fields{4};
        catch Er
            warning('HORACE:using_mex','calc_sqw->Error: ''%s'' received from C-routine to rebin data, using matlab functions',Er.message);
            use_mex=false;
        end
    end
    if ~use_mex
        % sort pixels according their bins
        grid_size = obj.grid_size;
        [ix,npix,ibin]=sort_pixels_(pix(1:4,:),urange,grid_size);
        
        pix=pix(:,ix);
        
        s=reshape(accumarray(ibin,pix(8,:),[prod(grid_size),1]),grid_size);
        e=reshape(accumarray(ibin,pix(9,:),[prod(grid_size),1]),grid_size);
        npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
        s=s./npix;       % normalise data
        e=e./npix.^2;  % normalise variance
        clear ix ibin   % biggish arrays no longer needed
        nopix=(npix==0);
        s(nopix)=0;
        e(nopix)=0;
        
        clear nopix     % biggish array no longer needed
    end
    
    % If changed urange to something less than the range of the data, then must update true range
    if ~data_in_range
        urange(1,:)=min(pix(1:4,:),[],2)';
        urange(2,:)=max(pix(1:4,:),[],2)';
    else
        
    end
end


