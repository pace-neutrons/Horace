classdef test_gen_runfiles< TestCase
    %
    % $Revision: 334 $ ($Date: 2014-01-16 13:40:57 +0000 (Thu, 16 Jan 2014) $)
    %
    
    properties
        nfiles_max = 6;
        en;
        efix;
        psi;
        omega;
        dpsi;
        gl;
        gs;
        emode;
        alatt;
        angdeg;
        u;
        v;
        
        test_data_path;
        par_file;
        test_files;
    end
    methods
        function this=gen_test_files(this,ndet)
            this.test_files = cell(this.nfiles_max,1);
            mf = memfile();
            
            for i=1:this.nfiles_max
                this.test_files{i}=['TestFile',num2str(i),'.memfile'];
                mf.efix = this.efix(i);
                mf.en   = this.en{i};
                nen = numel(this.en{i})-1;
                S = ones(nen,ndet);
                S(:,1) = NaN;
                S(:,10) = NaN;
                
                mf.psi  = this.psi(i);
                mf.S   = S;
                mf.ERR = ones(nen ,ndet);
                mf.save(this.test_files{i});
            end
        end
        function this=test_gen_runfiles(name)
            this = this@TestCase(name);
            
            
            rootpath=fileparts(which('herbert_init.m'));
            this.test_data_path = fullfile(rootpath,'_test/common_data');
            this.par_file = fullfile(this.test_data_path,'demo_par.par');
            
            this.en=cell(1,this.nfiles_max);
            this.efix=zeros(1,this.nfiles_max);
            this.psi=zeros(1,this.nfiles_max);
            this.omega=zeros(1,this.nfiles_max);
            this.dpsi=zeros(1,this.nfiles_max);
            this.gl=zeros(1,this.nfiles_max);
            this.gs=zeros(1,this.nfiles_max);
            for i=1:this.nfiles_max
                this.efix(i)=35+0.5*i;                       % different ei for each file
                this.en{i}=0.05*this.efix(i):0.2+i/50:0.95*this.efix(i);  % different energy bins for each file
                this.psi(i)=90-i+1;
                this.omega(i)=10+i/2;
                this.dpsi(i)=0.1+i/10;
                this.gl(i)=3-i/6;
                this.gs(i)=2.4+i/7;
            end
            this.psi=90:-1:90-this.nfiles_max+1;
            
            this.emode=1;
            this.alatt=[4.4,5.5,6.6];
            this.angdeg=[100,105,110];
            this.u=[1.02,0.99,0.02];
            this.v=[0.025,-0.01,1.04];
            
            ldd= asciipar_loader(this.par_file);
            ndet = ldd.n_detectors();
            this=gen_test_files(this,ndet);
        end
        
        function test_runfiles(this)
            
            
            run_files = gen_runfiles(this.test_files,this.par_file,this.efix,this.emode,this.alatt,this.angdeg,...
                this.u,this.v,this.psi,this.omega,this.dpsi,this.gl,this.gs);
            
            assertEqual(run_files{1}.det_par,run_files{end}.det_par);
            
            for i=1:this.nfiles_max
                assertTrue(isempty(run_files{i}.S));
                assertTrue(isempty(run_files{i}.ERR));
                [efixl,enl,emodel,ndetl,alattl,angdegl,ul,vl,psil,omegal,dpsil,gll,gsl,detl]=get_rundata(run_files{i},...
                    'efix','en','emode','n_detectors','alatt','angdeg','u','v','psi','omega','dpsi','gl','gs','det_par',...
                    '-rad');
                assertEqual(efixl,this.efix(i));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,this.emode);
                assertEqual(28160,ndetl);
                assertEqual(alattl,this.alatt);
                assertEqual(angdegl,this.angdeg*(pi/180));
                assertEqual(ul,this.u);
                assertEqual(vl,this.v);
                assertEqual(psil,this.psi(i)*(pi/180));
                assertEqual(omegal,this.omega(i)*(pi/180));
                assertEqual(dpsil,this.dpsi(i)*(pi/180));
                assertEqual(gll,this.gl(i)*(pi/180));
                assertEqual(gsl,this.gs(i)*(pi/180));
                assertEqual(detl,run_files{i}.det_par);
                
                
                [Sl,ERRl,enl,efixl,emodel,alattl,angdegl,ul,vl,psil,omegal,dpsil,gll,gsl,detl]=...
                    get_rundata(run_files{i},'S','ERR','en','efix','emode','alatt','angdeg','u','v',...
                    'psi','omega','dpsi','gl','gs','det_par','-rad','-nonan');
                
                nen = numel(this.en{i})-1;
                oneS=ones(nen,28160-2);
                
                assertEqual(Sl,oneS);
                assertEqual(ERRl,oneS);
                %
                assertEqual(efixl,this.efix(i));
                assertEqual(enl,this.en{i}');
                assertEqual(emodel,this.emode);
                %assertEqual(ndetl,28158);
                assertEqual(alattl,this.alatt);
                assertEqual(angdegl,this.angdeg*(pi/180));
                assertEqual(ul,this.u);
                assertEqual(vl,this.v);
                assertEqual(psil,this.psi(i)*(pi/180));
                assertEqual(omegal,this.omega(i)*(pi/180));
                assertEqual(dpsil,this.dpsi(i)*(pi/180));
                assertEqual(gll,this.gl(i)*(pi/180));
                assertEqual(gsl,this.gs(i)*(pi/180));
                % assertEqual(detl,run_files{i}.det_par);
                assertEqual(28158,numel(detl.x2));
                
            end
            
            
        end
    end
end
