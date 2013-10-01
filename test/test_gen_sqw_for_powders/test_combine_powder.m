function test_combine_powder(varargin)
% Test combining powder cylinder sqw files
%   >> test_combine_powder           % Compare with previously saved results in test_combine_pow_output.mat
%                                 % in the same folder as this function
%   >> test_combine_powder ('save')  % Save to test_combine_pow_output.mat in tempdir (type >> help tempdir
%                                 % for information about the system specific location returned by tempdir)

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
% Create spe files:
par_file='map_4to1_dec09.par';
sqw_file=fullfile(tempdir,'test_combine_pow.sqw');
spe_file_1=fullfile(tempdir,'test_combine_pow_1.spe');
spe_file_2=fullfile(tempdir,'test_combine_pow_2.spe');

efix=100;
emode=1;
alatt=2*pi*[1,1,1];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0; dpsi=0; gl=0; gs=0;

% Simulate first file, with reproducible random looking noise
% -----------------------------------------------------------
en=-5:1:90;
psi_1=0;
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi_1, omega, dpsi, gl, gs);
w=read_sqw(sqw_file);
wcalc=sqw_eval(w,@sqw_cylinder,[10,1]);

wran=sqw_eval(w,@sqw_random_looking,[0.2,0.8,1]);
ave_err=sum(wran.data.pix(8,:))/numel(wran.data.pix(8,:));
wcalc.data.pix(8,:)=wcalc.data.pix(8,:)+wran.data.pix(8,:)-ave_err;

wran=sqw_eval(w,@sqw_random_looking,[0.2,0.8,1]);
wcalc.data.pix(9,:)=wran.data.pix(8,:);

wspe=spe(wcalc);    % convert to equivalent spe data

% Write to spe file
save(wspe,spe_file_1)


% Simulate second file, with reproducible random looking noise
% -------------------------------------------------------------
en=-9.5:2:95;
psi_2=30;
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi_2, omega, dpsi, gl, gs);
w=read_sqw(sqw_file);
wcalc=sqw_eval(w,@sqw_cylinder,[10,1]);

wran=sqw_eval(w,@sqw_random_looking,[0.2,0.8,1]);
ave_err=sum(wran.data.pix(8,:))/numel(wran.data.pix(8,:));
wcalc.data.pix(8,:)=wcalc.data.pix(8,:)+wran.data.pix(8,:)-ave_err;

wran=sqw_eval(w,@sqw_random_looking,[0.2,0.8,1]);
wcalc.data.pix(9,:)=wran.data.pix(8,:);

wspe=spe(wcalc);    % convert to equivalent spe data

% Write to spe file
save(wspe,spe_file_2)


% Create sqw files, combine and check results
% -------------------------------------------
sqw_file_1=fullfile(tempdir,'test_pow_1.sqw');
sqw_file_2=fullfile(tempdir,'test_pow_2.sqw');
sqw_file_tot=fullfile(tempdir,'test_pow_tot.sqw');

gen_sqw_powder_test (spe_file_1, par_file, sqw_file_1, efix, emode);
gen_sqw_powder_test (spe_file_2, par_file, sqw_file_2, efix, emode);
gen_sqw_powder_test ({spe_file_1,spe_file_2}, par_file, sqw_file_tot, efix, emode);

w2_1=cut_sqw(sqw_file_1,[0,0.05,8],0,'-nopix');
w2_2=cut_sqw(sqw_file_2,[0,0.05,8],0,'-nopix');
w2_tot=cut_sqw(sqw_file_tot,[0,0.05,8],0,'-nopix');

w1_1=cut_sqw(sqw_file_1,[0,0.05,3],[40,50],'-nopix');
w1_2=cut_sqw(sqw_file_2,[0,0.05,3],[40,50],'-nopix');
w1_tot=cut_sqw(sqw_file_tot,[0,0.05,3],[40,50],'-nopix');

%--------------------------------------------------------------------------------------------------
% Visually inspect
% acolor k
% dd(w1_1)
% acolor b
% pd(w1_2)
% acolor r
% pd(w1_tot)
%--------------------------------------------------------------------------------------------------

% =====================================================================================================================
% Compare with saved output
% ====================================================================================================================== 
if ~save_output
    disp('====================================')
    disp('    Comparing with saved output')
    disp('====================================')
    output_file=fullfile(rootpath,'test_combine_pow_output.mat');
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
    
    output_file=fullfile(tempdir,'test_combine_pow_output.mat');
    save(output_file, 'w2_1', 'w2_2', 'w2_tot', 'w1_1', 'w1_2', 'w1_tot')
    
    disp(' ')
    disp(['Output saved to ',output_file])
    disp(' ')
end
