function spe_file=simulate_spe_testfunc (en, par_file, spe_file, sqwfunc, pars, scale, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
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
persistent rnd_storage;
if isempty(rnd_storage)
    rnd_storage = struct();
    rnd_storage.dir = fileparts(which('simulate_spe_testfunc.m'));
    seeds_file = fullfile(rnd_storage.dir,'sim_spe_testfun_seeds_file.mat');
    if exist(seeds_file,'file')==2
        rnd_storage = load(seeds_file);
        rnd_storage = rnd_storage.rnd_storage;
        seed_defined = true;
    else
        seed_defined = false;
        rnd_storage.seeds = struct();
    end
else
    seed_defined = true;
end
%-----------------------------------------------------------------
[~,seed_key] = fileparts(spe_file);
if seed_defined
    if isfield(rnd_storage.seeds,seed_key)
        seed = rnd_storage.seeds.(seed_key);
    else
        seed_defined = false;
        rnd_storage.seeds.(seed_key) = 0;
    end
end
if ~seed_defined
    seed = 42;
end




% Create sqw file
sqw_file=fullfile(tempdir,['test_spe_testfun',str_random(12),'.sqw']);
clo = onCleanup(@()delete(sqw_file));
fake_sqw (en, par_file, sqw_file, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs);

% Simulate on the sqw object
w=read_sqw(sqw_file);
wcalc=sqw_eval(w,sqwfunc,pars);
clear w

% Add random looking, but determinisitic, noise
peak=max(abs(wcalc.data.pix(8,:)));
if peak==0
    peak=10; % Case of all signal==0
end

rand_like('start',seed);  % set reproducible starting point in sequence
if seed_defined
    par = [0,1,false,seed];
else
    par = [0,1,true];
end
wran=sqw_eval(wcalc,@sqw_rand_like,par); % range is -0.5 to +0.5
wcalc.data.pix(8,:)=wcalc.data.pix(8,:)+(0.1*peak)*wran.data.pix(8,:);  % spread is 10% of peak

if ~seed_defined
    si = Singleton.instance();   
    rnd_storage.seeds.(seed_key) = si.singleton_data;
    seeds_file = fullfile(rnd_storage.dir,'sim_spe_testfun_seeds_file.mat');    
    save(seeds_file,'rnd_storage');
end
%----- store seed for second random function
if seed_defined
    seed_key = [seed_key,'_fun'];
    if isfield(rnd_storage.seeds,seed_key)
        seed = rnd_storage.seeds.(seed_key);
    else
        seed_defined = false;
        rnd_storage.seeds.(seed_key) = 0;
    end
end
if seed_defined    
    par = [0,1,false,seed];
else
    par = [0,1,true];
end

wran=sqw_eval(wcalc,@sqw_rand_like,par);

if ~seed_defined
    si = Singleton.instance();   
    rnd_storage.seeds.(seed_key) = si.singleton_data;
    seeds_file = fullfile(rnd_storage.dir,'sim_spe_testfun_seeds_file.mat');    
    save(seeds_file,'rnd_storage');
end

wcalc.data.pix(9,:)=(0.05*peak*scale)*(1+wran.data.pix(8,:));

% Convert to equivalent spe data
wspe=rundata(wcalc);

% Write to spe file
wspe.saveNXSPE(spe_file);


%========================================================================================
function weight = sqw_rand_like (qh,qk,ql,en,par)
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
%
% Output:
% -------
%   weight      S(Q,w) calculation
%               The weight for eah element will lie in the range
%                   par(1)-par(2)/2 to par(1)+par(2)/2

% Get a number in the range 0 to 1 that is very sensitive to the values of qh,qk,ql,en
if numel(par) < 4
    fac=1+exp(sqrt(0.6374993));
    f1=fac^(sqrt(1.109));
    f2=fac^(16/15);
    f3=fac^(pi/3);
    f4=fac^(exp(1)/2.5);
    dval=mod(cos(1e5*(fac+sum(f1*qh(:)+f2*qk(:)+f3*ql(:)+f4*en(:)))),1);
    val0=rand_like('fetch');        % get current seed
    seed = val0+dval;
else
    seed = par(4);
end
store = par(3);
rand_like('start',seed);   % change seed

% Get weight
weight=(par(1)-par(2)/2) + par(2)*rand_like(size(qh));
% return seed in the rand_like structure
if store
    si = Singleton.instance();
    si.singleton_data = seed;
end
