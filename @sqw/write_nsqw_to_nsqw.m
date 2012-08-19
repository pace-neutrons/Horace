function [grid_size, urange] = write_nsqw_to_nsqw (dummy, infiles, outfiles, grid_size_in, urange_in)
% Read a collection of sqw files and sort the pixels from those files onto a common grid.
% Write the results to disk, one file per input sqw file.
%
%   >> [grid_size, urange] = write_nsqw_to_nsqw (dummy, infiles, outfiles)
%   >> [grid_size, urange] = write_nsqw_to_nsqw (dummy, infiles, outfiles, grid_size_in)
%
% Input:
%   dummy           Dummy sqw object  - used only to ensure that this service routine was called
%   infiles         Cell array or character array of file name(s) of input file(s)
%   outfiles        Cell array or character array of full name(s) of output file(s)
%   grid_size_in    [Optional] Scalar or row vector of grid dimensions.
%                  Default is [10,10,10,10]
%   urange_in       [Optional] Range of data grid for output. If not given, then uses smallest hypercuboid
%                  that encloses the whole data range.
%
% Ouput:
%   grid_size       Actual grid size used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid
%

% T.G.Perring   27 June 2007
% $Revision$ ($Date$)


% Check that the first argument is sqw object
% -------------------------------------------
if ~isa(dummy,classname)    % classname is a private method 
    error('Check type of input arguments')
end

% Check number of input arguments (necessary to get more useful error message because this is just a gateway routine)
% --------------------------------------------------------------------------------------------------------------------
if ~(nargin>=3 && nargin<=5)
    error('Check number of input arguments')
end


% Check that the input files all exist and give warning if the output files overwrite the input files.
% ----------------------------------------------------------------------------------------------------

% Convert to cell array of strings if necessary
if ~iscellstr(infiles)
    infiles=cellstr(infiles);
end

if ~iscellstr(outfiles)
    outfiles=cellstr(outfiles);
end

% Check there is one output file for each input file
nfiles=length(infiles);
if nfiles~=length(outfiles)
    error('Number of output file names does not match the number of input file names')
end

% Check input files exist
for i=1:nfiles
    if exist(infiles{i},'file')~=2
        error(['ERROR: File ',infiles{i},' not found'])
    end
end

% *** Check output files can be opened
% *** Check that output files and input files do not coincide
% *** Check do not repeat an input file or output file name

% Set default grid size if none given
% ------------------------------------
if nargin<=2
    grid_size_in=10;
end

if nargin<=3
    urange_in=[];
end

% Read header information from files, and check consistency
% ---------------------------------------------------------
disp('Reading header(s) of input file(s) and checking consistency')
% Read data:
% (*** At present we require that all detector info is the same for all files, and each input file contains only one spe file)
main_header=cell(nfiles,1);
header=cell(nfiles,1);
datahdr=cell(nfiles,1);
pos_datastart=zeros(nfiles,1);

for i=1:nfiles
    [main_header{i},header{i},det_tmp,datahdr{i},mess,position,npixtot,type,current_format] = get_sqw (infiles{i},'-h');
    if ~current_format; error('Data in file %s does not have current Horace format - please re-create',infiles{i}); end
    if ~isempty(mess); error('Error reading data from file %s \n %s',infiles{i},mess); end
    if ~strcmpi(type,'a'); error(['No pixel information in ',infiles{i}]); end
    if main_header{i}.nfiles~=1; error(['Data from more than one spe file in ',infiles{i}]); end
    if i==1
        det=det_tmp;    % store the detector information for the first file
    end
    if ~isequal_par(det,det_tmp); error('Detector parameter data is not the same in all files'); end
    clear det_tmp       % save memory on what could be a large variable
    pos_datastart(i)=position.data;  % start of data block
end

% Check consistency:
% (*** At present, we insist that lattice parameters, u_to_rlu, and uoffset are identical. This may be
% generalisable however)

npax=length(datahdr{1}.pax);
small = 1.0e-10;% test number to define equality allowing for rounding
for i=2:nfiles  % only need to check if more than one file
    ok = all(abs(header{i}.alatt-header{1}.alatt)<small);
    ok = ok & all(abs(header{i}.angdeg-header{1}.angdeg)<small);
    ok = ok & all(abs(header{i}.uoffset-header{1}.uoffset)<small);
    ok = ok & all(abs(header{i}.u_to_rlu-header{1}.u_to_rlu)<small);
    if ~ok
        error('Not all input files have the same lattice parameters,projection axes and projection axes offsets in header blocks')
    end
    
    ok = all(abs(datahdr{i}.uoffset-datahdr{1}.uoffset)<small);
    ok = ok & all(abs(datahdr{i}.u_to_rlu-datahdr{1}.u_to_rlu)<small);
    if ~ok
        error('Not all input files have the same projection axes and projection axes offsets in data blocks')
    end

    if length(datahdr{i}.pax)~=npax
        error('Input files must all have the same number of projection axes')
    end
    if npax<4   % one or more integration axes
        ok = all(datahdr{i}.iax==datahdr{1}.iax);
        ok = ok & all(datahdr{i}.iint==datahdr{1}.iint);
        if ~ok
            error('Not all integration axes and integration limits are identical')
        end
    end
    if npax>0   % one or more projection axes
        ok = all(datahdr{i}.pax==datahdr{1}.pax);
        if ~ok
            error('Not all projection axes are identical')
        end
    end
end
    
% Get full range of the data
if isempty(urange_in)   % urange not given, so set from data
    urange=datahdr{1}.urange;
    for i=2:nfiles
        urange=[min(urange(1,:),datahdr{i}.urange(1,:));max(urange(2,:),datahdr{i}.urange(2,:))];
    end
else
    urange=urange_in;
end

% Read in the data, sort, and write the newly ordered sqw file to disk

for i=1:nfiles
    bigtic
    disp('--------------------------------------------------------------------------------')
    disp(['Processing file: ',infiles{i}])
    % read data
    [fid,mess]=fopen(infiles{i},'r');
    if fid<0; error(['Unable to open input file: ',mess]); end
    status=fseek(fid,pos_datastart(i),'bof');   % Move directly to location of start of data block
    if status<0; fclose(fid); error(['Error getting to data block in file ',infiles{i}]); end
    [data,mess] = get_sqw_data(fid);
    if ~isempty(mess); fclose(fid); error(['Error reading data block in file ',infiles{i}]); end
    fclose(fid);
    
    % sort pixels and create output data structure
    disp('  Sorting pixels ...')
try
    [grid_size,sqw_data.p]=construct_grid_size(grid_size_in,urange,4);    
%   sets this fields in-place: [sqw_data.pix,sqw_data.s,sqw_data.e,sqw_data.npix]=bin_pixels_c(sqw_data,urange,grid_size);
%  ************** !!! DANGEROUS !!! ***********************************
%   bin_pixels_c modifies data in-place saving memory but
%   if one saved sqw_data or any of its fields in an array before
%   this, both arrays will be modified (untill disjoined)
% %     [scratch, sort_in_place]=bin_pixels_c(sqw_data,urange,grid_size); 
% %     if(~sort_in_place)
% %         sqw_data=scratch;        
% %     end

   nThreads=get(config,'threads'); % picked up by bin_pixels_c directly;  
% %
   bin_pixels_c(sqw_data,urange,grid_size); 
%  ************** !!! DANGEROUS !!! ***********************************        
catch
    [ix,npix,p,grid_size,ibin]=sort_pixels(sqw_data.pix(1:4,:),urange,grid_size_in);
    sqw_data.pix=sqw_data.pix(:,ix);
    sqw_data.p=p;
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
   
    sqw_data.filename=data.filename;
    sqw_data.filepath=data.filepath;
    sqw_data.title=data.title;
    sqw_data.alatt=data.alatt;
    sqw_data.angdeg=data.angdeg;
    sqw_data.uoffset=data.uoffset;
    sqw_data.u_to_rlu=data.u_to_rlu;
    sqw_data.ulen=data.ulen;
    sqw_data.ulabel=data.ulabel;
    sqw_data.iax=data.iax;
    sqw_data.iint=data.iint;
    sqw_data.pax=data.pax;
    sqw_data.dax=data.dax;
    sqw_data.urange=data.urange;    % Retain the urange for the particular file


    clear data      % to reduce memory consumption

    
    % Write to output file
    disp(['  Writing output data file: ',outfiles{i},' ...'])
    [path,name,ext]=fileparts(outfiles{i});
    main_header{i}.filename=[name,ext];
    main_header{i}.filepath=[path,filesep];
    mess=put_sqw (outfiles{i},main_header{i},header{i},det,sqw_data);
    if ~isempty(mess); error('Problems writing to output file %s \n %s',outfiles{i},mess); end  
    clear sqw_data  % to reduce memory consumption
    bigtoc
    disp(' ')
end

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear grid_size urange
end
