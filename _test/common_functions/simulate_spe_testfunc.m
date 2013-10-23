function simulate_spe_testfunc (en, par_file, spe_file, sqwfunc, pars, scale, efix, emode, alatt, angdeg, u, v, psi, omega, dpsi, gl, gs)
% Simulate an spe file using an sqw model, with reproducible random looking noise

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
wspe=spe(wcalc);

% Write to spe file
save(wspe,spe_file)

% Delete temporary sqw file
try
    delete(sqw_file)
catch
    disp([mfilename,': unable to delete temporary sqw file'])
end
