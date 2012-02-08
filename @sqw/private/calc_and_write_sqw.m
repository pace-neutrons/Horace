function [grid_size, urange] = calc_and_write_sqw(sqw_file, efix, emode, alatt, angdeg, u, v, psi,...
                                          omega, dpsi, gl, gs, data, det, det0, grid_size_in, urange_in)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

% Fill output main header block
[path,name,ext]=fileparts(strtrim(sqw_file));
main_header.filename=[name,ext];
main_header.filepath=[path,filesep];
main_header.title='';
main_header.nfiles=1;

% Calculate projections and fill data blocks to be written to file
disp('Calculating projections...')
[header,sqw_data]=calc_sqw (efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, data, det);
sqw_data.filename=main_header.filename;
sqw_data.filepath=main_header.filepath;
sqw_data.title=main_header.title;

clear data det  % Clear large variables from memory before start writing - writing seems to use lots of temporary memory

% Flag if grid is in fact just a box i.e. 1x1x1x1
grid_is_unity = (isscalar(grid_size_in)&&grid_size_in==1)||(isvector(grid_size_in)&&all(grid_size_in==[1,1,1,1]));

% Set urange, and determine if all the data is on the surface or within the box defined by the ranges
if ~exist('urange_in','var') || isempty(urange_in)
    urange = sqw_data.urange;   % range of the data
    data_in_range = true;
else
    urange = urange_in;         % use input urange
    if any(urange(1,:)>sqw_data.urange(1,:)) || any(urange(2,:)<sqw_data.urange(2,:))
        data_in_range = false;
    else
        data_in_range = true;
    end
end

% If grid that is other than 1x1x1x1, or range was given, then sort pixels
% (Recall that urange does NOT need to be changed, as urange is the true range of the pixels)
if grid_is_unity && data_in_range   % the most work we have to do is just change the bin boundary fields
    for id=1:4
        sqw_data.p{id}=[urange(1,id);urange(2,id)];
    end
    grid_size = grid_size_in;
else
    disp('Sorting pixels ...')
    
    use_mex=get(hor_config,'use_mex');
    if use_mex
        try
            % Verify the grid consistency and build axes along the grid dimensions,
            % c-program does not check the grid consistency;
            [grid_size,sqw_data.p]=construct_grid_size(grid_size_in,urange,4);

            sqw_fields   =cell(1,4);
            sqw_fields{1}=get(hor_config,'threads');
            sqw_fields{2}=urange;
            sqw_fields{3}=grid_size;
            sqw_fields{4}=sqw_data.pix;
            clear sqw_data.s sqw_data.e sqw_data.npix;
            
            out_fields=bin_pixels_c(sqw_fields);
            
            sqw_data.s   = out_fields{1};
            sqw_data.e   = out_fields{2};
            sqw_data.npix= out_fields{3};
            sqw_data.pix = out_fields{4};
                        
        catch
            warning('HORACE:using_mex','sqw:write_spe_to_sqw->Error: ''%s'' received from C-routine to rebin data, using matlab fucntions',lasterr());
            use_mex=false;
        end
    end
    if ~use_mex
        [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);

        sqw_data.p=p;   % added by RAE 10/6/11 to avoid crash when doing non-mex generation of sqw files
        sqw_data.pix=sqw_data.pix(:,ix);
        
        sqw_data.s=reshape(accumarray(ibin,sqw_data.pix(8,:),[prod(grid_size),1]),grid_size);
        sqw_data.e=reshape(accumarray(ibin,sqw_data.pix(9,:),[prod(grid_size),1]),grid_size);
        sqw_data.npix=reshape(npix,grid_size);      % All we do is write to file, but reshape for consistency with definition of sqw data structure
        sqw_data.s=sqw_data.s./sqw_data.npix;       % normalise data
        sqw_data.e=sqw_data.e./(sqw_data.npix).^2;  % normalise variance
        clear ix ibin   % biggish arrays no longer needed
        nopix=(sqw_data.npix==0);
        sqw_data.s(nopix)=0;
        sqw_data.e(nopix)=0;
        
        clear nopix     % biggish array no longer needed
    end
    
    % If changed urange to something less than the range of the data, then must update true range
    if ~data_in_range
        sqw_data.urange(1,:)=min(sqw_data.pix(1:4,:),[],2)';
        sqw_data.urange(2,:)=max(sqw_data.pix(1:4,:),[],2)';
    end
end

bigtoc('Time to convert from spe to sqw data:')

% Write header, detector parameters and processed data
% -------------------------------------------------------
[path,file]=fileparts(sqw_file);
disp(['Writing sqw data to ',file,' ...'])
bigtic;
%Open output file
fid=fopen(sqw_file,'W');    % upper case 'W' means no automatic flushing of buffer - can be faster
if fid<0
    error(['Unable to open file output file ',sqw_file])
end
mess=put_sqw (fid,main_header,header,det0,sqw_data);
fclose(fid);
if ~isempty(mess)
    error('Error writing data to file %s \n %s',sqw_file,mess)
end

bigtoc('Time to save data to file:')    % display timings

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear grid_size urange
end
