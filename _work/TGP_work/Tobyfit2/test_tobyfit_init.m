function test_tobyfit_init (opt)
% Set up to test Tobyfit
%
%   >> test_tobyfit_init (opt)
%
%   tobyfit     opt = 1
%   tobyfit     opt = 2

rootpath = fileparts(which(mfilename));
tf1_dir = 'T:\SVN_area\Horace_trunk\Tobyfit';
tf2_dir = 'T:\SVN_area\Horace_trunk\_work\TGP_work\Tobyfit2';
mfclass_dir = 'T:\SVN_area\Herbert_trunk\_work\TGP_work\applications\multifit';

if nargin==0 || (ischar(opt) && strncmpi(opt,'off',numel(opt)))
    start_app ('tobyfit1','-off')
    start_app ('tobyfit2','-off')

elseif opt==1
    start_app ('tobyfit2','-off')
    start_app ('tobyfit',tf1_dir)
    addpath(rootpath)
    
elseif opt==2
    start_app ('tobyfit','-off')
    start_app ('tobyfit2',tf2_dir)
    start_app ('mfclass',mfclass_dir)
    addpath(rootpath)
    
else
    error('Unrecognised option')
end
