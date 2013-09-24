function gen_sqw_powder_test (spe_file, par_file, sqw_file, efix, emode)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
%   >> gen_sqw_powder_test (spe_file, par_file, sqw_file, efix)
%
% *** TEST ROUTINE
%       This was created rapidly as a fix-up during an experiment. A polished version is
%      marked for addition at a later date.
%
% Input: (in the following, nfile = number of spe files)
% ------
%   spe_file        Full file name of spe file - character string or cell array of
%                  character strings for more than one file
%   par_file        Full file name of detector parameter file (Tobyfit format)
%   sqw_file        Full file name of output sqw file
%   efix            Fixed energy (meV)                 [scalar or vector length nfile]
%   emode           Direct geometry=1, indirect geometry=2, elastic=0    [scalar]
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
% - This sqw object that is created is a 2D object, with axes (|Q|, eps)
% 
% - Use cut_sqw and @sqw/cut WITHOUT the proj option. All other use may lead to
%  unexpected behaviour. Many functions in Horace will not be meaningful.


% Original author: T.G.Perring  2 August 2013: quick fix for LET
%
% $Revision: 691 $ ($Date: 2013-03-28 17:48:23 +0000 (Thu, 28 Mar 2013) $)


% % Gateway routine that calls sqw method
% ---------------------------------------
alatt=[2*pi,2*pi,2*pi];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;
grid=[1,1,1,1];     % need to force to be one bin for the algorithm to work
if ~iscell(spe_file)
    spe_file={spe_file};    % for compatibility with older versions of Horace
end

gen_sqw (sqw, spe_file, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, grid);


% The special part: replace u1 with sqrt(u1^2+u2^2) and set u2=0 - this allows for cylindrical symmetry
% -----------------------------------------------------------------------------------------------------
w=read_sqw(sqw_file);

data=w.data;
data.pix(1:3,:)=[sqrt(sum(data.pix(1:3,:).^2,1));zeros(2,size(data.pix,2))];
data.urange(:,1:3)=[min(data.pix(1:3,:),[],2)';max(data.pix(1:3,:),[],2)'];
data.iax=[2,3];   % second and third axes become integration axes
data.iint=[-Inf,-Inf;Inf,Inf];
data.pax=[1,4];
data.p=[{data.urange(:,1)},data.p(4)];
data.dax=[1,2];
data.ulabel={'|Q|','dummy','dummy','E'};
w.data=data;


% Rebin the data so can call plot straightaway with useful bins
% --------------------------------------------------------------
ndet=numel(w.detpar.group);
nbin=min(max(1,round(ndet/2)),100);     % A reasonable number of bins
qrange=diff(w.data.urange(:,1));
dq=round_to_vals(qrange/nbin);

if w.main_header.nfiles==1
    ne=numel(w.header.en)-1;
else
    ne=numel(w.header{1}.en)-1;
end
if ne>250
    erange=diff(w.data.urange(:,4));
    de=round_to_vals(erange/125);
    w=cut_sqw(w,dq,de);
else
    w=cut_sqw(w,dq,0);           % Use intrinsic energy bins
end


% Save back out to the same file
% ------------------------------
save(w,sqw_file);

% Clear output arguments if nargout==0 to have a silent return
if nargout==0
    clear tmp_file grid_size urange
end
