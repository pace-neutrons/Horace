function gen_sqw_powder_test (spe_file, par_file, sqw_file, efix, emode)
% Read one or more spe files and a detector parameter file, and create an output sqw file.
%
%   >> gen_sqw_cylinder_test (spe_file, par_file, sqw_file, efix, emode)
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
%  unexpected behaviour. The symmetrisation routines may not work, but the only
%  symmetrisation that is meaningful is to add +ve and -ve Qz, so this can be
%  done by hand. Many other functions in Horace will not be meaningful.


% Original author: T.G.Perring  2 August 2013: quick fix for LET
%
% $Revision$ ($Date$)


alatt=[2*pi,2*pi,2*pi];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
psi=0;
omega=0; dpsi=0; gl=0; gs=0;
if ~iscell(spe_file)
    spe_file={spe_file};    % for compatibility with older versions of Horace
end

nfiles=numel(spe_file);
[efix,ok,mess]=make_array(efix,nfiles);
if ~ok, error(['efix ',mess]), end


% Create temporary files, all on a 1x1x1x1 grid
% ---------------------------------------------
if nfiles==1
    tmp_file={sqw_file};    % make cell array
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
    gen_sqw (sqw, spe_file(i), par_file, tmp_file{i}, efix(i), emode,...
        alatt, angdeg, u, v, psi, omega, dpsi, gl, gs, grid);
end


% The special part: replace u1 with sqrt(u1^2+u2^2+u3^2) and set u2=u3=0
% ----------------------------------------------------------------------
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
abs_urange(:,1,:)=sqrt(abs_urange(:,1,:).^2 + abs_urange(:,2,:).^2 + abs_urange(:,3,:).^2);
Q_min=min(abs_urange(1,1,:));
Q_max=max(abs_urange(2,1,:));
eps_min=min(urange(1,4,:));
eps_max=max(urange(2,4,:));

% Choose suitable rebinning for the final sqw file
nQbin_def=100;
nepsbin_def=100;
head_full=head_sqw(tmp_file{1},'-full');

ndet=numel(head_full.detpar.group);
nqbin=min(max(1,round(sqrt(ndet)/2)),nQbin_def);     % A reasonable number of bins along each Q axis
dQ=round_to_vals((Q_max-Q_min)/nqbin);
small=1e-10;
Q_bins=[dQ*(floor((Q_min-small)/dQ)+0.5),dQ,dQ*(ceil((Q_max+small)/dQ)-0.5)];

if nfiles==1 && (numel(head_full.header.en)-1)<=200  % one spe file and 150 energy bins or less
    epsbins=0;           % Use intrinsic energy bins
else
    deps=round_to_vals((eps_max-eps_min)/nepsbin_def);
    epsbins=[eps_min-deps/2,deps,eps_max+deps/2];
end

% Compute |Q| for each tmp file, and save all the tmp files onto the same grid
proj.u=[1,0,0];
proj.v=[0,1,0];
proj.type='rrr';
proj.lab={'|Q|','dummy','dummy','E'};

for i=1:nfiles
    % Read in
    w=read_sqw(tmp_file{i});
    % Compute new coordinates
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
    % Rebin
    w=cut_sqw(w,proj,Q_bins,[-Inf,Inf],[-Inf,Inf],epsbins);
    % Save to the same tmpfile
    save(w,tmp_file{i})
end


% Combne all the tmp files into the final sqw file
% ------------------------------------------------
if nfiles==1
    % Single spe file, so no recombining needs to be done
    tmp_file='';    % temporary file not created, so to avoid misleading return argument, set to empty string
else
    il = get(hor_config,'horace_info_level');
    if il>-1
        % Multiple files
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
