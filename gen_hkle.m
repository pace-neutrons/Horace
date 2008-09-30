function gen_hkle (msp, data_in_dir, fin, fout, u1, u2, varargin);
% Read in a number of spe files and use the projection facilities in 
% mslice to calculate the (Q,E) components for each pixel, and write these
% and the intensity to a binary file suitable for use in the Horace routines.
%
% Syntax:
%  Give two mslice projection axes, and construct the third:
%   >> gen_hkle (msp, data_in_dir, fin, fout, u1, u2)
%
%  adding labels to the three projection axes:
%   >> gen_hkle (msp, data_in_dir, fin, fout, u1, u2, u1_lab, u2_lab, u3_lab)
%
%  Give all three projection axes (must be orthogonal for mslice to work)
%   >> gen_hkle (msp, data_in_dir, fin, fout, u1, u2, u3)
%
%  adding labels:
%   >> gen_hkle (msp, data_in_dir, fin, fout, u1, u2, u3, u1_lab, u2_lab, u3_lab)
%
% NOTES:
% (1) If the binary output file already exists, the routine appends the new
%     data to the end of it. 
% (2) This routine requires that mslice is running in the background.
%
% Input:
% ------
%   msp         Mslice parameter file (including path if not in current
%               directory). Must have correct .phx file, scattering
%               plane etc. The only information that will be over-written 
%               by this function is the .spe file, psi and projection axes.
%
%   data_in_dir Path to the spe file names given in the file fin below.
%               - This path overrides any path given as part of the file names in fin
%               - Set to '' if the paths in the file fin are to be used
%   
%   fin         File with psi values (deg) and the spe file names to be included
%               Format of this file: e.g.
%                       90   MAP07491.SPE
%                       89   MAP07492.SPE
%                        :         :
%                       
%   fout        File name for the binary output file (format described below).
%               
%   u1    --|   Projection axes in which to label pixel centres [row vectors]
%   u2      |--   e.g.    u1 = [1,0,0], u2=[0,1,0], u3=[0,0,1]
%   u3    --|     e.g.    u1 = [1,1,0], u2=[-1,1,0], u3=[0,0,1]
%
%   u1_lab--|   Optional labels for the projection axes (e.g. 'Q_h' or 'Q_{kk}')
%   u2_lab  |-- If not provided, then default values will be written
%   u3_lab--|   
%
% Output:
% -------
% header block:
%   data.grid   Type of grid ('spe') [Character string]
%   data.title  Title [Character string]
%   data.a      Lattice parameters (Angstroms)
%   data.b           "
%   data.c           "
%   data.alpha  Lattice angles (degrees)
%   data.beta        "
%   data.gamma       "
%   data.u      Matrix (4x4) of projection axes in original 4D representation
%               u(:,1) first vector - u(1:3,1) r.l.u., u(4,1) energy etc.
%   data.ulen   Length of vectors in Ang^-1 or meV [row vector]
%   data.label  Labels of the projection axes [1x4 cell array of charater strings]
%   data.nfiles Number of spe file data blocks in the remainder of the file
%   data.urange Range along each of the axes: [u1_lo, u2_lo, u3_lo, u4_lo; u1_hi, u2_hi, u3_hi, u4_hi]
%   data.ebin   Energy bin width of first, minimum and last spe file: [ebin_first, ebin_min, ebin_max]
%   data.en0    Energy bin centres for the first spe file
%
% For each spe file in succession:
%   data.ei     Incident energy used for spe file (meV)
%   data.psi    Psi angle (deg)
%   data.cu     u crystal axis (r.l.u.) (see mslice) [row vector]
%   data.cv     v crystal axis (r.l.u.) (see mslice) [row vector]
%   data.file   File name of .spe file corresponding to the block being read
%   data.size   size(1)=number of detectors; size(2)=number of energy bins [row vector]
%   data.v      Array containing the components along the mslice projection
%              axes u1, u2, u3 for each pixel in the .spe file.
%              Note: size(data.v) = [3, no. dets * no. energy bins]
%   data.en     Vector containing the energy bin centres [row vector]
%   data.S      Intensity vector [row vector]
%   data.ERR    Variance vector [row vector]
%

% Original author: J. van Duijn
%
% $Revision$ ($Date$)
%
% Horace v0.1   J. van Duijn, T.G.Perring

tic

% Status of mslice - if this routine opens mslice, then opened_mslice will not be empty
opened_mslice = [];

% parameter used to check rounding
small = 1.0e-13;

% Determine if mslice is running, and try to open if it is not
fig=findobj('Tag','ms_ControlWindow');
if isempty(fig),
    disp('Mslice control window not active. Starting mslice...');
    disp (' ')
    mslice
    disp (' ')
    opened_mslice = findobj('Tag','ms_ControlWindow');
    if isempty(opened_mslice),
        error('ERROR: Unable to start mslice. Please check your mslice setup.');
    end
end

% Determine if u3 and labels are present:
if nargin==6|nargin==7
    labels = 0;
    if nargin==7; u3 = varargin{1}; end
elseif nargin==9|nargin==10
    labels = 1;
    if nargin==9
        u1_lab = varargin{1};
        u2_lab = varargin{2};
        u3_lab = varargin{3};
    elseif nargin==10
        u3 = varargin{1};
        u1_lab = varargin{2};
        u2_lab = varargin{3};
        u3_lab = varargin{4};
    end
else
    error ('ERROR: Check the number and type of input arguments')
end

% Check type of input variables
if ~(exist(msp,'file') && ~exist(msp,'dir'))
    error ('ERROR: .msp file does not exist - check input arguments')
end
if ~(isempty(data_in_dir) || isa_size(data_in_dir,'row','char'))
    error ('ERROR: Data_in_dir must be a character string')
end
if ~(exist(fin,'file') && ~exist(fin,'dir'))
    error ('ERROR: Input file name does not exist - check input arguments')
end
if ~isa_size(fout,'row','char')
    error ('ERROR: Check syntax of output file name')
end
if ~(isa_size(u1,[1,3],'double') && isa_size(u2,[1,3],'double'))
    error ('ERROR: u1 and u2 must be row vectors with length=3')
else
    if max(abs(u1))==0 || max(abs(u2))==0
        error ('ERROR: Length of vectors u1 and u2 must both be greater than zero')
    end
end
if exist('u3','var')
    if ~isa_size(u3,[1,3],'double')
        error ('ERROR: u3 must be a row vector with length=3')
    elseif max(abs(u3))==0
        error ('ERROR: Length of vector u3 must be greater than zero')
    end
end
if labels
    if ~(isa_size(u1_lab,'row','char') && isa_size(u2_lab,'row','char') && isa_size(u3_lab,'row','char'))
        error ('ERROR: Axis labels must be character strings')
    end
end

% Read input spe file information (*** should check that all data files exist at this point)
try
    [psi,fnames] = textread(fin,'%f %s');  
catch
    error (['ERROR: Check contents and format of spe file information file',fin])
end

nfiles = length(psi);
if nfiles<1
    error(['ERROR: No spe file information found in information file ',fin])
end
% Check that the files exist
for i=1:nfiles
    if ~isempty(data_in_dir)    %override paths to spe files
        [spe_path,spe_file,spe_ext,spe_ver] = fileparts(fnames{i});
        fname_true=fullfile(data_in_dir,[spe_file,spe_ext,spe_ver])
    else
        fname_true=fnames{i}
    end
    if exist(fname_true,'file')~=2
        error(['ERROR: File ',fname_true,' not found on path'])
    end
end

% Determine if binary file already exists
if exist(fout,'file')
    % Open existing file, read the header, update number of files and
    % position writing at the end of the file
    append = 1;
    fid=fopen(fout, 'r+');
    if fid<0; error (['ERROR: Unable to open file ',fout]); end
    % check that the file is not empty (common error); if it is empty, then treat like a new file
    status = fseek(fid,1,'cof');
    if status>=0
        fseek(fid,0,'bof'); % go back to beginning of file
        % read header
        [data,mess]=get_header(fid);
        if ~isempty(mess); fclose(fid); error(mess); end
        if isfield(data,'grid')
            if ~strcmp(data.grid,'spe')
                fclose(fid);
                error ('ERROR: The function gen_hkle only reads binary spe files');
            end
        else
            fclose(fid);
            error (['ERROR: Problems reading spe header data from ',fout])
        end
        data.nfiles=data.nfiles+nfiles;
        fseek(fid, 0, 'eof');
    else
        fseek(fid,0,'bof'); % go back to beginning of file
        append = 0;
    end
else
    % Open a new binary file
    append = 0;
    fid=fopen(fout,'w');
    if fid<0; error (['ERROR: Unable to open file ',fout]); end
end

%-----------------------------
try     % have a catch to intercept the case of an error to allow us to close the file
    
% Set up Q-space viewing axes
ms_load_msp(msp);

% check u1, u2 and u3 are orthogonal
alatt = zeros(1,3);
angdeg = zeros(1,3);
alatt(1)=ms_getvalue('as');
alatt(2)=ms_getvalue('bs');
alatt(3)=ms_getvalue('cs');
angdeg(1)=ms_getvalue('aa');
angdeg(2)=ms_getvalue('bb');
angdeg(3)=ms_getvalue('cc');
if ~exist('u3','var')
    [rlu_to_ustep, u_to_rlu, ulen, mess] = rlu_to_ustep_matrix (alatt, angdeg, u1, u2, [1,1,1], 'rrr');
    if ~isempty(mess)   % problem calculating ub matrix and related quantities
        error('ERROR: Check lattice parameters in msp file, also that u1 and u2 are not parallel')
    end
    % check if u2 is parallel to the 2nd vector produced by rlu_to_ustep
    if max(abs(u2/norm(u2) - u_to_rlu(:,2)'/norm(u_to_rlu(:,2)))) > small
        u2 = u_to_rlu(:,2)';
        u2(abs(u2)<small)=0;    % round to zero
    end    
    u3 = u_to_rlu(:,3)';
    u3(abs(u3)<small)=0;    % round to zero
else
    [rlu_to_ustep, u_to_rlu, ulen, mess] = rlu_to_ustep_matrix (alatt, angdeg, u1, u2, [1,1,1], 'aaa');
    if ~isempty(mess)   % problem calculating ub matrix and related quantities
        error('ERROR: Check lattice parameters in msp file, also that u1 and u2 are not parallel')
    end
    test = rlu_to_ustep*[u1',u2',u3'];
    if max(max(abs(test-diag(diag(test))))) > small
        error ('ERROR: u1, u2, u3 must form a right-handed orthogonal set')
    elseif min(diag(test))<0
        error('ERROR: u1, u2, u3 must form a right-handed orthogonal set, not left-handed')
    end
end  
disp(' ')
disp('--------------------------------------------------------------------------------')
disp ('Projection axes are:')
disp ([' u1: (',num2str(u1(1)),', ',num2str(u1(2)),', ',num2str(u1(3)),')'])
disp ([' u2: (',num2str(u2(1)),', ',num2str(u2(2)),', ',num2str(u2(3)),')'])
disp ([' u3: (',num2str(u3(1)),', ',num2str(u3(2)),', ',num2str(u3(3)),')'])

ms_setvalue('u11',u1(1));
ms_setvalue('u12',u1(2));
ms_setvalue('u13',u1(3));
ms_setvalue('u14',0);
ms_setvalue('u21',u2(1));
ms_setvalue('u22',u2(2));
ms_setvalue('u23',u2(3));
ms_setvalue('u24',0);
ms_setvalue('u31',u3(1));
ms_setvalue('u32',u3(2));
ms_setvalue('u33',u3(3));
ms_setvalue('u34',0);
if labels
    ms_setvalue('u1label',u1_lab);
    ms_setvalue('u2label',u2_lab);
    ms_setvalue('u3label',u3_lab);
    label = {u1_lab, u2_lab, u3_lab, 'E'};
else
    uarr = [[u1(1),u1(2),u1(3)]',[u2(1),u2(2),u2(3)]',[u3(1),u3(2),u3(3)]']; % write explicitly to avoid problem if u1 etc given as column vectors
    if max(max(abs(sort([uarr])-[0,0,0;0,0,0;1,1,1]))) < small
        lis= find(round(uarr));  % find the elements equal to unity
        tl= {'Q_h','Q_k','Q_l','E'};
        label= [tl(lis(1)),tl(lis(2)-3),tl(lis(3)-6),tl(4)];
    else
        label= {'Q_\zeta','Q_\xi','Q_\eta','E'};
    end
    ms_setvalue('u1label',label{1});
    ms_setvalue('u2label',label{2});
    ms_setvalue('u3label',label{3});
end

% Read and convert each spe file then write data to binary file 
for i = 1:nfiles
    t_start = toc;
    % must do a clever trick to set path for spe file - TGP
    disp(' ')
    disp('--------------------------------------------------------------------------------')
    disp(['Processing file ',fnames{i}])
    [spe_path,spe_file,spe_ext,spe_ver] = fileparts(fnames{i});
    if ~isempty(data_in_dir)    %override paths to spe files
        if strcmp(data_in_dir(end),filesep)
            ms_setvalue('DataDir',data_in_dir);
        else
            ms_setvalue('DataDir',[data_in_dir,filesep]);
        end
    else
        if isempty(spe_path)
            ms_setvalue('DataDir',spe_path);
        else
            ms_setvalue('DataDir',[spe_path,filesep]);
        end
    end
    ms_setvalue('DataFile',[spe_file,spe_ext]);
    ms_setvalue('psi_samp',psi(i));
    ms_load_data;
    ms_calc_proj;
    d = fromwindow;
    disp('Writing data to output file')
    if i==1 & ~append
        % The very first time around generate all the header information.
        data.grid= 'spe';
        data.title= d.title_label;
        data.a=ms_getvalue('as');
        data.b=ms_getvalue('bs');
        data.c=ms_getvalue('cs');
        data.alpha=ms_getvalue('aa');
        data.beta=ms_getvalue('bb');
        data.gamma=ms_getvalue('cc');
        data.u= [[u1,0]',[u2,0]',[u3,0]',[0 0 0 1]'];
        data.ulen= [d.axis_unitlength', 1];
        data.label= label;
        data.nfiles= nfiles;
        data.urange=[inf, inf, inf, inf; -inf, -inf, -inf, -inf];   % will update as files are read in
        ebin = (d.en(end)-d.en(1))/(length(d.en)-1);
        data.ebin = [ebin,inf,-inf];  % will also update
        data.en0 = d.en;
        write_header(fid,data);
    end
    fwrite(fid, d.efixed, 'float32'); 
    fwrite(fid, psi(i), 'float32');
    fwrite(fid, d.uv(1,:), 'float32');
    fwrite(fid, d.uv(2,:), 'float32');
    n=length(d.filename);
    fwrite(fid, n, 'int32');
    fwrite(fid, d.filename, 'char');
    sized= size(d.v);
    fwrite(fid,sized(1:2), 'int32');
    % Reshape and transpose the data.v array so that it becomes data.v(1:3,:) where each
    % column corresponds to components along u1, u2, u3 for one pixel.
    % Do the corresponding reshape and transpose for the signal and error arrays.
    nt= sized(1)*sized(2);
    fwrite(fid, reshape(d.v, nt, 3)','float32');
    fwrite(fid, d.en, 'float32');
    fwrite(fid, reshape(d.S, 1, nt), 'float32');
    fwrite(fid, reshape(d.ERR, 1, nt).^2, 'float32');  % store error squared 
    % Update minimum and maximum extent along the axes:
    vlo = [min(reshape(d.v, nt, 3),[],1),d.en(1)];
    vhi = [max(reshape(d.v, nt, 3),[],1),d.en(end)];
    data.urange(1,:) = min(data.urange(1,:),vlo);
    data.urange(2,:) = max(data.urange(2,:),vhi);
    % Update energy bin information
    ebin = (d.en(end)-d.en(1))/(length(d.en)-1);
    data.ebin(2) = min(ebin,data.ebin(2));
    data.ebin(3) = max(ebin,data.ebin(3));
    % Print some informational messages to the screen
    t_calc = toc;
    disp(' ')
    if i==1
        disp(['Processed ',num2str(i),' file of ',num2str(nfiles)])
    else
        disp(['Processed ',num2str(i),' files of ',num2str(nfiles)])
    end
    disp(['Time to process this file: ',num2str(t_calc-t_start), ' s'])
end

% if all the files are correctly appended to the binary file update the
% header with the total number of spe files. We do this even if a new file, as
% we only know the updated range of the data after reading in all the files
fseek(fid, 0, 'bof');       % go to beginning of file
write_header(fid,data);     % overwrite header information with the updated header
fclose(fid);

% Close mslice if opened in this function
if ~isempty(opened_mslice),
   disp(' ')
   disp(['Closing MSlice Control Window opened by the function gen_hkle'])
   delete(opened_mslice);
end

t_calc= toc;
disp(' ')
disp('--------------------------------------------------------------------------------')
disp(['Total time to process files: ',num2str(t_calc)])
disp('--------------------------------------------------------------------------------')

%-----------------------------
catch
    if ~isempty(fopen(fid)) % if error occurs after closing the file, don't attempt to close it again!
        fclose(fid);
    end
    error(lasterr)
end
