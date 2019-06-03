function gen_sqw_cylinder_test (spe_file, par_file, sqw_file, efix, varargin)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
%   >> gen_sqw_cylinder_test (spe_file, par_file, sqw_file, efix, emode, clatt, omega, gl, gs)
%
% *** TEST ROUTINE
%       This was created rapidly as a fix-up during an experiment. A polished version is
%       marked for addition at a later date.
%
% Input: (in the following, nfile = number of spe files)
% ------
%   spe_file        Full file name of spe file - character string or cell array of
%                  character strings for more than one file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
%   clatt           Lattice parameter along c axis (Ang)
%   omega           Angle of axis of small goniometer arc w.r.t. notional u (deg) [scalar or vector length nfile]
%   gl              Large goniometer arc angle (deg)   [scalar or vector length nfile]
%   gs              Small goniometer arc angle (deg)   [scalar or vector length nfile]
%
% Meaning of gl and gs: they give the direction of the Qz axis. If gl=gs=0 then Qz is
% vertically upwards. In the case when you choose omega=0 then:
%   gl              Rotation is about horizontal axis perp. to ki, +ve tilts the
%                  vertical upwards towards the beam dump.
%   gs              Rotation is about ki, +ve rotation anticlockwise when looking
%                  from the sample towards the moderator
% Non-zero omega can be used to tie the direction of Qz in a different coordinate frame
%
% Output:
% --------
%   tmp_file        List of temporary files created by this call to gen_sqw (can be empty
%                  e.g. if a single spe file, when no temporary file is created)
%   grid_size       Actual size of grid used (size is unity along dimensions
%                  where there is zero range of the data points)
%   urange          Actual range of grid
%
%
% *** IMPORTANCE NOTES ***
%
% - This sqw object that is created is a 3D object, with axes (Q_inplane, Qz, eps)
%
% - Use cut_sqw and @sqw/cut WITHOUT the proj option. All other use may lead to
%  unexpected behaviour. The symmetrisation routines may not work, but the only
%  symmetrisation that is meaningful is to add +ve and -ve Qz, so this can be
%  done by hand. Many other functions in Horace will not be meaningful.


% Original author: T.G.Perring  2 August 2013: quick fix for LET
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)


% Check input arguments
% ---------------------
if nargin==6    % assume arguments are (spe_file, par_file, sqw_file, efix, gs, gl) to catch original quick-fix for LET, c. 1 Aug 2013
    emode=1;
    clatt=1;
    omega=0;
    gl=varargin{1};
    gs=varargin{2};
elseif nargin==9
    emode=varargin{1};
    clatt=varargin{2};
    omega=varargin{3};
    gl=varargin{4};
    gs=varargin{5};
else
    error('Check the number of arguments')
end

alatt=[2*pi,2*pi,clatt];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
psi=0;
dpsi=0;
if ~iscell(spe_file)
    spe_file={spe_file};    % for compatibility with older versions of Horace
end

nfiles=numel(spe_file);
[efix,ok,mess]=make_array(efix,nfiles);
if ~ok, error(['efix ',mess]), end
[omega,ok,mess]=make_array(omega,nfiles);
if ~ok, error(['omega ',mess]), end
[gl,ok,mess]=make_array(gl,nfiles);
if ~ok, error(['gl ',mess]), end
[gs,ok,mess]=make_array(gs,nfiles);
if ~ok, error(['ga ',mess]), end


% Create temporary files, all on a 1x1x1x1 grid
% ---------------------------------------------
if nfiles==1
    tmp_file={sqw_file};     % make cell array
else
    % Names of temporary files (Horace v2 convention)
    tmp_file=cell(size(spe_file));
    sqw_dir=fileparts(sqw_file);
    for i=1:numel(tmp_file)
        [dummy,spe_name]=fileparts(spe_file{i});
        tmp_file{i}=fullfile(sqw_dir,[spe_name,'.tmp']);
    end
end

% Process files
grid=[1,1,1,1];     % need to force to be one bin for the algorithm to work
for i=1:numel(spe_file)
    gen_sqw (spe_file(i), par_file, tmp_file{i}, efix(i), emode,...
        alatt, angdeg, u, v, psi, omega(i), dpsi, gl(i), gs(i), grid);
end


% The special part: replace u1 with sqrt(u1^2+u2^2) and set u2=0 - this allows for cylindrical symmetry
% -----------------------------------------------------------------------------------------------------
% Get range of data (is an overestimate, but will certainly contain all the data)
head=cell(1,nfiles);
urange=zeros(2,4,nfiles);
for i=1:nfiles
    head{i}=head_sqw(tmp_file{i});
    urange(:,:,i)=head{i}.urange;
end
sgn=sign(urange(1,:,:).*urange(2,:,:)); % +1 if range does not include zero
abs_urange_min=min(abs(urange),[],1);
abs_urange_min(sgn<1)=0;
abs_urange=[abs_urange_min;max(abs(urange),[],1)];
abs_urange(:,1,:)=sqrt(abs_urange(:,1,:).^2 + abs_urange(:,2,:).^2);
Qip_min=min(abs_urange(1,1,:));
Qip_max=max(abs_urange(2,1,:));
Qz_min=min(urange(1,3,:));
Qz_max=max(urange(2,3,:));
eps_min=min(urange(1,4,:));
eps_max=max(urange(2,4,:));

% Choose suitable rebinning for the final sqw file
nQbin_def=33;
nepsbin_def=33;
head_full=head_sqw(tmp_file{1},'-full');

ndet=numel(head_full.detpar.group);
nqbin=min(max(1,round(sqrt(ndet)/2)),nQbin_def);     % A reasonable number of bins along each Q axis
dQip=round_to_vals((Qip_max-Qip_min)/nqbin);
dQz=round_to_vals((Qz_max-Qz_min)/nqbin);
small=1e-10;
Qip_bins=[dQip*(floor((Qip_min-small)/dQip)+0.5),dQip,dQip*(ceil((Qip_max+small)/dQip)-0.5)];
Qz_bins=[dQz*(floor((Qz_min-small)/dQz)+0.5),dQz,dQz*(ceil((Qz_max+small)/dQz)-0.5)];

if nfiles==1 && (numel(head_full.header.en)-1)<=50  % one spe file and 50 energy bins or less
    epsbins=0;           % Use intrinsic energy bins
else
    deps=round_to_vals((eps_max-eps_min)/nepsbin_def);
    epsbins=[eps_min-deps/2,deps,eps_max+deps/2];
end

% Compute Qip and Qz for each tmp file, and save all the tmp files onto the same grid
proj.u=[1,0,0];
proj.v=[0,1,0];
proj.type='rrr';
proj.lab={'Q_{ip}','dummy','Q_z','E'};

for i=1:nfiles
    % Read in
    w=read_sqw(tmp_file{i});
    % Compute new coordinates
    data=w.data;
    data.pix(1:2,:)=[sqrt(sum(data.pix(1:2,:).^2,1));zeros(1,size(data.pix,2))];
    data.urange(:,1:2)=[min(data.pix(1:2,:),[],2)';max(data.pix(1:2,:),[],2)'];
    data.iax=2;   % second axis becomes integration axis
    data.iint=[-Inf;Inf];
    data.pax=[1,3,4];
    data.p=[{data.urange(:,1)},data.p([3,4])];
    data.dax=[1,2,3];
    data.ulabel={'Q_{ip}','dummy','Q_z','E'};
    w.data=data;
    % Rebin
    w=cut_sqw(w,proj,Qip_bins,[-Inf,Inf],Qz_bins,epsbins);
    % Save to the same tmpfile
    save(w,tmp_file{i})
end


% Combne all the tmp files into the final sqw file
% ------------------------------------------------
if nfiles==1
    % Single spe file, so no recombining needs to be done
    tmp_file='';    % temporary file not created, so to avoid misleading return argument, set to empty string
else
    % Multiple files
    il = get(hor_config,'log_level');
    if il>-1
        disp('--------------------------------------------------------------------------------')
        disp('Creating final output sqw file:')
    end
    write_nsqw_to_sqw (tmp_file, sqw_file);
    if il>-1
        disp('--------------------------------------------------------------------------------')
    end
end


% Delete temporary files if requested
% -----------------------------------
if get(hor_config,'delete_tmp')
if ~isempty(tmp_file)   % will be empty if only one spe file
    delete_error=false;
    for i=1:numel(tmp_file)
        try
            delete(tmp_file{i})
        catch
            if delete_error==false
                delete_error=true;
                disp('One or more temporary sqw files not deleted')
            end
        end
    end
end
end


% Clear output arguments if nargout==0 to have a silent return
% ------------------------------------------------------------
if nargout==0
    clear tmp_file grid_size urange
end

%==================================================================================================
function [val_out,ok,mess]=make_array(val,n)
% Make a vector length n if scalar, or check length is n if not
if isscalar(val)
    val_out=val*ones(1,n);
    ok=true;
    mess='';
elseif numel(val)==n
    val_out=val;
    ok=true;
    mess='';
else
    val_out=val;
    ok=false;
    mess='must be a scalar or a vector with same number of elements as spe files';
end
