function [slice,ok,mess]=get_slice(filename)
% Read a slice file with all pixel information
%
%   >> [slice,ok,mess]=get_slice(filename)
%
%   filename        Name of file from which to read slice
%
%   slice           Structure with the following information:
%   ok              =true if all OK; =false otherwise
%   mess            ='' if OK==true error message if OK==false
%
% Contents of slice structure:
% -----------------------------
% - If succesfully read, then will contain fields:
%
%      xbounds: [1x(nx+1) double]
%      ybounds: [1x(ny+1) double]
%            x: [1xn double], n=nx*ny
%            y: [1xn double]
%            c: [1xn double]
%            e: [1xn double]
%      npixels: [1xn double]
%       pixels: [mx7 double], m=sum(npixels(:))
%      x_label: '[ Q_h, 0, 3 ]  in 2.894 Å^{-1}'
%      y_label: '[ +0.5   Q_vert, -Q_vert, 3 ]  in 2.506 Å^{-1}'
%      z_label: 'Intensity (abs. units)'
%        title: {'map02114.spe, , Ei=447 meV'  [1x56 char]  [1x52 char]}
% x_unitlength: '2.894'
% y_unitlength: '2.5063'
%    SliceFile: 'aaa.slc'
%     SliceDir: 'c:\temp\'
%
% Format of slice file:
%   first line:
%     <nx = no. x bins>  <ny = no. y bins>  <x coord of centre of bin(1,1)>  <y coord of same>  <x bin width>  <y bin width>
%
%   then for each bin in the order (1,1)...(nx,1), (1,2)...(nx,2),  ... , (1,ny)...(nx,ny):
%      x(av)   y(av)   I(av)   err(I(av))   npix
%      det_no(1)      eps_centre(1)     d_eps(1)     x(1)     y(1)     I(1)     err(1)
%         .                 .              .           .        .        .        .
%      det_no(npix)   eps_centre(npix)  d_eps(npix)  x(npix)  y(npix)  I(npix)  err(npix)
%      x_label                         = [ Q_h, 0, 0 ]  in 1.174 Å^{-1}
%      y_label                         = [ 0, 0, Q_l ]  in 1.163 Å^{-1}
%      z_label                         = Intensity (abs. units)
%      title                           = spe250.spe, , Ei=250 meV
%      title                           = {\bfu}=[1 0 0], {\bfv}=[0 1 0], Psi=({\bfu},{\bfki})=98.5
%      title                           = slice 150<E<200 , Q_h=-1.4:0.055:0.3 , Q_l=-0.7:0.025:0.7
%      x_unitlength                    = 1.1735
%      y_unitlength                    = 1.1633
%
% (the number of entries beginning 'x_label','y_label','title' will depend on the number of lines required for those fields)

ok=true;
mess='';

% Remove blanks from beginning and end of filename
file_tmp=strtrim(filename);

% Read file
use_mex=get(herbert_config,'use_mex');
if use_mex
    try
        [header,x,y,c,e,npixels,pixels,footer]=get_slice_mex(file_tmp);
        nx=header(1); ny=header(2); xorig=header(3); yorig=header(4); dx=header(5); dy=header(6);
        slice.xbounds=xorig+dx.*(linspace(0,nx,nx+1)-0.5);
        slice.ybounds=yorig+dy.*(linspace(0,ny,ny+1)-0.5);
        slice.x=x'; slice.y=y'; slice.c=c'; slice.e=e'; slice.npixels=npixels'; slice.pixels=pixels';
        slice.x_label=[];
        slice.y_label=[];
        slice.z_label=[];
        slice.title=[];
        slice.x_unitlength=[];
        slice.y_unitlength=[];
        [slice,added]=get_labels_to_struct(footer,slice);
    catch
        force_mex=get(herbert_config,'force_mex_if_use_mex');
        if ~force_mex
            display(['Error calling mex function ',mfilename,'_mex. Calling matlab equivalent'])
            use_mex=false;
        else
            slice=[];
            ok=false;
            mess=['Error loading slice data from ',file_tmp]';
            return
        end
    end
end
if ~use_mex
    try     % try matlab algorithm
		if get(herbert_config,'log_level')>-1
			disp(['Matlab loading of slice file : ' file_tmp]);
		end
        % Open file for reading
        fid=fopen(file_tmp,'rt');
        if fid==-1,
            error([ 'Error opening file ' file_tmp ]);
        end
        % Read x,y,c,e and complete pixel information
        header=fscanf(fid,'%g',6);	% number of data points in the slice
        nx=header(1); ny=header(2); xorig=header(3); yorig=header(4); dx=header(5); dy=header(6);
        slice.xbounds=xorig+dx.*(linspace(0,nx,nx+1)-0.5);
        slice.ybounds=yorig+dy.*(linspace(0,ny,ny+1)-0.5);
        
        n=nx*ny;    % number of data points
        nbuff=1e5;  % initial buffer size for pixel array
        bin_data=zeros(5,n);
        pix_data=zeros(7,nbuff);
        npixtot=0;
        for i=1:n,
            bin_data(:,i)=fscanf(fid,'%g',5);
            npix=bin_data(5,i);
            if npix>0
                npixtot=npixtot+npix;
                if npixtot>nbuff
                    pix_data=[pix_data,zeros(7,2*npixtot-nbuff)];  % make the buffer twice as big as required total
                    nbuff=size(pix_data,2);
                end
                pix_data(:,npixtot-npix+1:npixtot)=fscanf(fid,'%g',[7,npix]);
            end
        end
        slice.x=bin_data(1,:);
        slice.y=bin_data(2,:);
        slice.c=bin_data(3,:);
        slice.e=bin_data(4,:);
        slice.npixels=bin_data(5,:);
        if npixtot~=nbuff;
            slice.pixels=pix_data(:,1:npixtot)';    % strip off the unused elements of the buffer
        else
            slice.pixels=pix_data';
        end
        % Read footer information
        slice.x_label=[];
        slice.y_label=[];
        slice.z_label=[];
        slice.title=[];
        slice.x_unitlength=[];
        slice.y_unitlength=[];
        [slice,added]=get_labels_to_struct(fid,slice);
        fclose(fid);
    catch
        slice=[];
        ok=false;
        mess='Unable to load slice from file.';
        return
    end
end
slice.c(slice.npixels==0)=NaN;  % bins with no pixels made NaN
slice.e(slice.npixels==0)=0;

% Add fields if missing from footer
if ~added
    disp('Have reached the end of file without finding any label information appended.');
    slice.x_label='x coordinate of slice';
    slice.y_label='y coordinate of slice';
    slice.z_label='Intensity';
    [pathname,file,ext]=fileparts(file_tmp);
    slice.title=avoidtex([file,ext]);
    slice.x_unitlength='1';
    slice.y_unitlength='1';
    slice.SliceFile=[file,ext];
    slice.SliceDir=[pathname,filesep];
else
    [pathname,file,ext]=fileparts(file_tmp);
    slice.SliceFile=[file,ext];
    slice.SliceDir=[pathname,filesep];
end

if get(herbert_config,'log_level')>-1
	disp(['Loaded slice ( ' num2str(numel(slice.npixels)) ' data points and ' num2str(size(slice.pixels,1)) ' pixels) from file : ']);
	disp(file_tmp);
end
