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

% Create sqw file
sqw_file=fullfile(tempdir,['test_',str_random(12),'.sqw']);
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

rand_like('start',42);  % set reproducible starting point in sequence
wran=sqw_eval(wcalc,@sqw_rand_like,[0,1]); % range is -0.5 to +0.5
wcalc.data.pix(8,:)=wcalc.data.pix(8,:)+(0.1*peak)*wran.data.pix(8,:);  % spread is 10% of peak

wran=sqw_eval(wcalc,@sqw_rand_like,[0,1]);
wcalc.data.pix(9,:)=(0.05*peak*scale)*(1+wran.data.pix(8,:));

% Convert to equivalent spe data
wspe=rundata(wcalc);

% Write to spe file
wspe.saveNXSPE(spe_file);

% Delete temporary sqw file
try
    delete(sqw_file)
catch
    disp([mfilename,': unable to delete temporary sqw file'])
end

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
fac=1+exp(sqrt(0.6374993));
f1=fac^(sqrt(1.109));
f2=fac^(16/15);
f3=fac^(pi/3);
f4=fac^(exp(1)/2.5);
dval=mod(cos(1e5*(fac+sum(f1*qh(:)+f2*qk(:)+f3*ql(:)+f4*en(:)))),1);
val0=rand_like('fetch');        % get current seed
rand_like('start',val0+dval);   % change seed

% Get weight
weight=(par(1)-par(2)/2) + par(2)*rand_like(size(qh));
