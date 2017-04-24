function file_list=setup_demo_data()
%
% Internal routine for demo - generates some spe files that can then be
% used in the Horace demo suite.
%

demo_dir=pwd;

en=[-80:8:760];
par_file=[demo_dir,filesep,'4to1_124.par'];
sqw_file_single=[demo_dir,filesep,'single.sqw'];
efix=800;
emode=1;
alatt=[2.87,2.87,2.87];
angdeg=[90,90,90];
u=[1,0,0];
v=[0,1,0];
omega=0;dpsi=0;gl=0;gs=0;

psi=0:4:90;
nxspe_limit = numel(psi); %numel(psi)+2;
file_list = cell(1,numel(psi));

hil=get(hor_config,'log_level');
set(hor_config,'log_level',-Inf);
clob = onCleanup(@()set(hor_config,'log_level',hil));
%
disp('Getting data for Horace demo... Please wait a few minutes');
try
    for i=1:numel(psi)
        if i<=nxspe_limit
            file_list{i} = [demo_dir,filesep,'HoraceDemoDataFile',num2str(i),'.nxspe'];            
        else
            file_list{i} = [demo_dir,filesep,'HoraceDemoDataFile',num2str(i),'.spe'];            
        end
        if exist(file_list{i},'file')
            continue;
        end
        fake_sqw(en, par_file, sqw_file_single, efix, emode, alatt, angdeg,...
                         u, v, psi(i), omega, dpsi, gl, gs);

        w=read_sqw(sqw_file_single);
        %Make the fake data:
        w=sqw_eval(w,@demo_FM_spinwaves,[300 0 2 10 2]);%simulate spinwave cross-section 
        w=noisify(w,1);%add some noise to simulate real data
        if i<=nxspe_limit
            d = rundatah(w+0.74);
            saveNXSPE(d,file_list{i});
        else
            d=spe(w+0.74);%also add a constant background
            save(d,file_list{i});
        end
        %remove intermediate file
    end
catch err
    set(hor_config,'log_level',hil);
    delete(sqw_file_single);
    fprintf('Error producing fake_sqw data: %s Reason: %s\n',err.identifier,err.message);
    disp('Problem generating data for Horace demo - check that 4to1_124.PAR file is present in current (demo) directory');
end


%horace_info_level(hil)
if exist(sqw_file_single,'file')
    delete(sqw_file_single);
end

    
