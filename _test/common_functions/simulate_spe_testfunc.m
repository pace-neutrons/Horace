function spe_file=simulate_spe_testfunc (en, par_file, spe_file, sqwfunc, pars, scale, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs,run_id)
% Simulate an spe file using an sqw model, with reproducible random looking noise
%
% >>spe_file=simulate_spe_testfunc (en, par_file, spe_file, sqwfunc, pars, scale, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
%
% The usual definitions, but in addition:
%
%   scale       Scale value for error bars. A value of 0.3 is a good choice
%
% T.G.Perring

% store/restore complex rnd seeds, which may be different for different OS

seed_dir   = fileparts(which('simulate_spe_testfunc.m'));
seeds_file = fullfile(seed_dir,'sim_spe_testfun_seeds_file.mat');

persistent rseq_store;
if isempty(rseq_store)
    if isfile(seeds_file)
        storage = load(seeds_file);
        rseq_store = storage.rseq_store;
        seed_defined = true;
    else
        seed_defined = false;
        rseq_store = struct();
    end
else
    seed_defined = true;
end
if ~exist('run_id,'var')
    run_id= 1000;
end
%-----------------------------------------------------------------
%----- store/restore seed or random sequence for random signal function
[~,seed_key] = fileparts(spe_file);
sk = regexp(seed_key,'(\d+)','tokens');
sk = [sk{:}];
if isempty(sk)
    seed_key = ['key_',seed_key];
else
    seed_key =['key_', [sk{:}]];
end
if seed_defined
    if isfield(rseq_store,seed_key)
        rseq = rseq_store.(seed_key);
    else
        seed_defined = false;
        rseq_store.(seed_key) = [];
    end
end

% Create sqw file
%sqw_file=fullfile(tmp_dir,['test_spe_testfun',str_random(12),'.sqw']);
%clo = onCleanup(@()delete(sqw_file));
w= dummy_sqw (en, par_file, '', efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs,run_id);
if ~seed_defined || numel(rseq) ~= w{1}.pix.num_pixels
    wrs = sqw_eval(w{1},@gen_rseq,[]);
    rseq = wrs.pix.signal;
    rseq_store.(seed_key) = rseq;
    save(seeds_file,'rseq_store');
end
% Simulate on the sqw object
%w=read_sqw(sqw_file);
wcalc=sqw_eval(w{1},sqwfunc,pars);
clear w

% Add random looking, but deterministic, noise
peak=max(abs(wcalc.pix.signal));
if peak==0
    peak=10; % Case of all signal==0
end
%peak = 0; -- make it not-random

par = [0,1];
wran=sqw_eval(wcalc,@(qh,qk,ql,en,par)sqw_rand_like(qh,qk,ql,en,par,rseq),par); % range is -0.5 to +0.5
%save(wran,'c:/temp/rand_sqw_new.sqw');
wcalc.pix.signal   = wcalc.pix.signal+(0.1*peak)*wran.pix.signal;  % spread is 10% of peak
wcalc.pix.variance = (0.05*peak*scale)*(1+wran.pix.signal);

% Convert to equivalent spe data
wspe=rundatah(wcalc);

% Write to spe file
wspe.saveNXSPE(spe_file);

function rseq = gen_rseq(qh,qk,ql,en,rseq)
% Get a number in the range 0 to 1 that is very sensitive to the values of qh,qk,ql,en
if nargin == 5 && numel(qh) == numel(rseq)
    return
end
fac=1+exp(sqrt(0.6374993));
f1=fac^(sqrt(1.109));
f2=fac^(16/15);
f3=fac^(pi/3);
f4=fac^(exp(1)/2.5);
dval=mod(cos(1e5*(fac+sum(f1*qh(:)+f2*qk(:)+f3*ql(:)+f4*en(:)))),1);
val0 = rand_like('fetch');        % get current seed
seed = val0+dval;
rand_like('start',seed);   % set reproducible starting point in sequence
rseq = rand_like(size(qh));


%========================================================================================
function weight = sqw_rand_like (qh,qk,ql,en,par,rseq)
% Apparently random looking sqw. Very crude - will not work in many cases
%
%   >> weight = sqw_random_looking (qh,qk,ql,en,par)
%
% Input:
% ------
%   qh,qk,ql,en Arrays of h,k,l
%   par         Parameters:
%                   par(1)  Mean S(Q,w)
%                   par(2)  FWHH of S(Q,w)
%   rseq        random numbers sequence of size qh
%
% Output:
% -------
%   weight      S(Q,w) calculation
%               The weight for eah element will lie in the range
%                   par(1)-par(2)/2 to par(1)+par(2)/2

% generate random sequence sensitive to q, or retrieve existing one.
rseq = gen_rseq(qh,qk,ql,en,rseq);
% Get weight

weight=(par(1)-par(2)/2) + par(2)*rseq;
% return seed in the rand_like structure
