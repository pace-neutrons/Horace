function test_gen_sqw_cylinder(varargin)
% Test cylinder sqw file
%   >> test_gen_sqw_cylinder           % Compare with previously saved results in test_gen_sqw_cylinder_output.mat
%                                    % in the same folder as this function
%   >> test_gen_sqw_cylinder ('save')  % Save to test_gen_sqw_cylinder_output.mat in tempdir (type >> help tempdir
%                                    % for information about the system specific location returned by tempdir)

% Check input argument
if nargin==1
    if ischar(varargin{1}) && size(varargin{1},1)==1 && isequal(lower(varargin{1}),'save')
        save_output=true;
    else
        error('Unrecognised option')
    end
elseif nargin==0
    save_output=false;
else
    error('Check number of input arguments')
end

% Set up paths:
rootpath=fileparts(mfilename('fullpath'));

% =====================================================================================================================
% Create sqw file:
en=0:1:90;
par_file='map_4to1_dec09.par';
sqw_file=fullfile(tempdir,'test_gen_sqw_cylinder.sqw');
efix=100;
emode=1;
alatt=[5,5,5];
angdeg=[90,90,90];
u=[1,1,0];
v=[0,0,1];
psi=20;
omega=0; dpsi=0; gl=0; gs=0;
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

% Simulate dispersion relation with deterministic but random looking 'noise'
w=read_sqw(sqw_file);
ampl=10; SJ=8; gap=5;
wcalc=disp2sqw_eval(w,@HFM_simple_cubic_nn,[ampl,SJ,gap],5);

wran=sqw_eval(w,@sqw_random_looking,[0.2,0.8,1]);
ave_err=sum(wran.data.pix(8,:))/numel(wran.data.pix(8,:));
wcalc.data.pix(8,:)=wcalc.data.pix(8,:)+wran.data.pix(8,:)-ave_err;

wran=sqw_eval(w,@sqw_random_looking,[0.2,0.8,1]);
wcalc.data.pix(9,:)=wran.data.pix(8,:);

wspe=spe(wcalc);    % convert to equivalent spe data

% Write to spe file
spe_file=fullfile(tempdir,'test_gen_sqw_cylinder.spe');
save(wspe,spe_file)


%--------------------------------------------------------------------------------------------------
% Perform a cylinder average in Horace
sqw_cyl_file=fullfile(tempdir,'test_cyl_4to1.sqw');
gen_sqw_cylinder_test (spe_file, par_file, sqw_cyl_file, efix, emode, 1.5, 0, 0, 0);

%--------------------------------------------------------------------------------------------------
% Visual inspection
% Plot the cylinder averaged sqw data
wcyl=read_sqw(sqw_cyl_file);
w2=cut_sqw(wcyl,[0,0.03,7],0,'-nopix');
% plot(w2)
% lz 0 0.5
w1=cut_sqw(wcyl,[2,0.03,6.5],[53,57],'-nopix');
% dd(w1)
%--------------------------------------------------------------------------------------------------

% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(rootpath,'test_gen_sqw_cylinder_output.mat');
    old=load(output_file);
    nam=fieldnames(old);
    tol=-1.0e-13;
    for i=1:numel(nam)
        [ok,mess]=equal_to_tol(eval(nam{i}),  old.(nam{i}), tol, 'ignore_str', 1); if ~ok, error(['[',nam{i},']',mess]), end
    end
    disp(' ')
    disp('Matches within requested tolerances')
    disp(' ')
end


% =====================================================================================================================
% Save data
% ====================================================================================================================== 
if save_output
    disp('===========================')
    disp('    Save output')
    disp('===========================')
    
    output_file='c:\temp\test_gen_sqw_cylinder_output.mat';
    save(output_file, 'w1', 'w2', 'w1rings', 'w2rings')
    
    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
