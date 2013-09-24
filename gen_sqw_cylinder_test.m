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
% Meaning of gl and gs: they give the direction of the Az axis. If gl=gs=0 then Qz is
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
% $Revision: 691 $ ($Date: 2013-03-28 17:48:23 +0000 (Thu, 28 Mar 2013) $)


% % Gateway routine that calls sqw method
% ---------------------------------------
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

alatt=[2*pi,2*pi,2*pi/clatt];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
psi=0;
dpsi=0;
grid=[1,1,1,1];     % need to force to be one bin for the algorithm to work
if ~iscell(spe_file)
    spe_file={spe_file};    % for compatibility with older versions of Horace
end

gen_sqw (sqw, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, grid);


% The special part: replace u1 with sqrt(u1^2+u2^2) and set u2=0 - this allows for cylindrical symmetry
% -----------------------------------------------------------------------------------------------------
w=read_sqw(sqw_file);

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


% Rebin the data so can call plot straightaway with useful bins
% --------------------------------------------------------------
ndet=numel(w.detpar.group);
nbin=min(max(1,round(sqrt(ndet)/2)),33);     % A reasonable number of bins along each Q axis
qiprange=diff(w.data.urange(:,1));
qzrange=diff(w.data.urange(:,3));
dqip=round_to_vals(qiprange/nbin);
dqz=round_to_vals(qzrange/nbin);

proj.u=[1,0,0];
proj.v=[0,1,0];
proj.type='rrr';
proj.lab={'Q_{ip}','dummy','Q_z','E'};

if w.main_header.nfiles==1
    ne=numel(w.header.en)-1;
else
    ne=numel(w.header{1}.en)-1;
end
if ne>50
    erange=diff(w.data.urange(:,4));
    de=round_to_vals(erange/33);
    w=cut_sqw(w,proj,dqip,[-Inf,Inf],dqz,de);
else
    w=cut_sqw(w,proj,dqip,[-Inf,Inf],dqz,0);           % Use intrinsic energy bins
end


% Save back out to the same file
% ------------------------------
save(w,sqw_file);

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
