classdef test_rebin_operations < TestCase
    % Validate the dnd symmetrisation, combination and rebin routines

    properties
        % What we actually want to do is to simulate some cross-section that is
        % symmetric so that we can compare results easily.
        stiffness=80;
        gam=0.1;
        amp=10;
        testdir;
        this_folder;
        data_dir 

        % Tolerance to use when comparing single floats
        FLOAT_TOL = 4e-6;
    end

    methods
        function this=test_rebin_operations(name)
            this=this@TestCase(name);
            this.testdir = fileparts(mfilename('fullpath'));
            this.data_dir = fullfile(fileparts(this.testdir),'common_data');
        end

        function this=prepare_test_data(this)
            % Create the data (should not need to do this again)
            % Use sqw file on RAE's laptop to perform tests. Data saved to a .mat file on SVN server
            % for validation by others.
            data_source='C:\Russell\PCMO\ARCS_Oct10\Data\SQW\ei140.sqw';
            proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';

            %To ensure some of the catches for dnd symmetrisation work properly, need
            %to add some errorbars to all of the data points as well. Take from the
            %original data. Errorbars are rescaled to be appropriate size for new
            %signal array

            % Three-dimensional data sets
            w3d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[0,1.4,100]);
            w3d_sqw=sqw_eval(w3d_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            errs=w3d_sqw.data.pix.signal;
            w3d_sqw.data.pix.variance=errs;
            w3d_sqw=cut(w3d_sqw,[-1,0.025,1],[-1,0.025,1],[0,1.4,100]);
            w3d_d3d=d3d(w3d_sqw);

            % Two-dimensional data sets
            w2d_qe_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[0,1.4,100]);
            w2d_qe_sqw=sqw_eval(w2d_qe_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            errs=w2d_qe_sqw.data.pix.signal;
            w2d_qe_sqw.data.pix.variance=errs;
            w2d_qe_sqw=cut(w2d_qe_sqw,[-1,0.025,1],[0,1.4,100]);
            w2d_qe_d2d=d2d(w2d_qe_sqw);

            w2d_qq_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[30,40]);
            w2d_qq_sqw=sqw_eval(w2d_qq_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            errs=w2d_qq_sqw.data.pix.signal;
            w2d_qq_sqw.data.pix.variance=errs;
            w2d_qq_sqw=cut(w2d_qq_sqw,[-1,0.025,1],[-1,0.025,1]);
            w2d_qq_d2d=d2d(w2d_qq_sqw);

            % One-dimensional data sets
            w1d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[30,40]);
            w1d_sqw=sqw_eval(w1d_sqw,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);
            errs=w1d_sqw.data.pix.signal;
            w1d_sqw.data.pix.variance=errs;
            w1d_sqw=cut(w1d_sqw,[-1,0.025,1]);
            w1d_d1d=d1d(w1d_sqw);

            w2d_qq_small_sqw=cut_sqw(data_source,proj,[0,0.025,0.4],[0,0.025,0.4],[-Inf,Inf],[30,40]);
            w2d_qq_small_d2d=d2d(w2d_qq_small_sqw);

            % Save data
            save(w3d_sqw,[this.testdir,filesep,'w3d_sqw.sqw']);
            save(w3d_d3d,[this.testdir,filesep,'w3d_d3d.sqw']);
            save(w2d_qe_sqw,[this.testdir,filesep,'w2d_qe_sqw.sqw']);
            save(w2d_qe_d2d,[this.testdir,filesep,'w2d_qe_d2d.sqw']);
            save(w2d_qq_sqw,[this.testdir,filesep,'w2d_qq_sqw.sqw']);
            save(w2d_qq_d2d,[this.testdir,filesep,'w2d_qq_d2d.sqw']);
            save(w1d_sqw,[this.testdir,filesep,'w1d_sqw.sqw']);
            save(w1d_d1d,[this.testdir,filesep,'w1d_d1d.sqw']);
            %
            save(w2d_qq_small_sqw,[this.testdir,filesep,'w2d_qq_small_sqw.sqw']);
            save(w2d_qq_small_d2d,[this.testdir,filesep,'w2d_qq_small_d2d.sqw']);
        end

        % ------------------------------------------------------------------------------------------------
        % Tests
        % ------------------------------------------------------------------------------------------------
        function this = test_rebin_sqw_steps(this)
            % sqw rebinning
            w2d_qe_sqw=sqw(fullfile(this.data_dir,'w2d_qe_sqw.sqw'));

            w2d_qe_sqw_reb=rebin_sqw(w2d_qe_sqw,[-0.5,0.05,1],[10,0.7,80]);

            % Cut the input arg, and we should get something identical
            proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';
            w2d_qe_sqw_cut=cut_sqw(w2d_qe_sqw,proj,[-0.5,0.05,1],[-0.1,0.1],[-Inf,Inf],[10,0.7,80]);

            [ok,mess]=equal_to_tol(w2d_qe_sqw_cut,w2d_qe_sqw_reb,3e-9,'ignore_str', 1);
            assertTrue(ok,['rebin sqw using lo,step,hi syntax fails: ',mess])
        end

        % ------------------------------------------------------------------------------------------------
        function this = test_rebin_sqw_template(this)
            % sqw rebinning
            w2d_qq_sqw=sqw(fullfile(this.data_dir,'w2d_qq_sqw.sqw'));
            w2d_qq_small_sqw=sqw(fullfile(this.data_dir,'w2d_qq_small_sqw.sqw'));

            w2d_qq_small_sqw_1=rebin_sqw(w2d_qq_small_sqw,[0,0.04,0.4],[0,0.04,0.4]);
            skipTest('DND rebinning disabled unil #798 is fixed')            
            w2d_qq_sqw_reb=rebin_sqw(w2d_qq_sqw,w2d_qq_small_sqw_1);

            % Compare output with a direct simulation
            w2d_qq_sqw_reb_check=sqw_eval(w2d_qq_sqw_reb,@fake_cross_sec,[this.stiffness,this.gam,this.amp]);

            % Fixup involving rigging the error arrays from a simulation:
            w2d_qq_sqw_reb_check.data.e=w2d_qq_sqw_reb.data.e;
            w2d_qq_sqw_reb_check.data.pix.variance=w2d_qq_sqw_reb.data.pix.variance;

            [ok,mess]=equal_to_tol(w2d_qq_sqw_reb_check,w2d_qq_sqw_reb,-this.FLOAT_TOL,'ignore_str', 1);
            assertTrue(ok,['rebin sqw using template object fails: ',mess])
        end

        % ------------------------------------------------------------------------------------------------
        function this = test_rebin_dnd_steps(this)
            skipTest('DND rebinning disabled unil #798 is fixed')
            % dnd rebinning
            w2d_qe_sqw=sqw(fullfile(this.data_dir,'w2d_qe_sqw.sqw'));
            w2d_qe_d2d=read_dnd(fullfile(this.data_dir,'w2d_qe_d2d.sqw'));

            w2d_qe_d2d_reb=rebin_horace_2d(w2d_qe_d2d,[-1.025,0.05,1.025],[-2.8,2.8,100+3.6]);

            % Compare to pre-prepared dataset:
            proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';
            w2d_qe_d2d_compare=cut_sqw(w2d_qe_sqw,proj,[-1,0.05,1],[-0.1,0.1],[-Inf,Inf],[-1.4,2.8,100+2.8],'-nopix');

            c1=cut(w2d_qe_d2d_reb,[0.4,0.6],[]);
            c2=cut(w2d_qe_d2d_compare,[0.4,0.6],[]);

            mf1 = multifit_sqw (c1);
            mf1 = mf1.set_fun (@fake_cross_sec, [80,0.1,10]);
            [~, fitdata1] = mf1.fit();

            mf2 = multifit_sqw (c2);
            mf2 = mf2.set_fun (@fake_cross_sec, [80,0.1,10]);
            [~, fitdata2] = mf2.fit();

            [ok,mess]=equal_to_tol(fitdata1.p,fitdata2.p,-5e-3,'ignore_str', 1);
            assertTrue(ok,['rebin dnd using lo,step,hi syntax fails: ',mess])
        end

        % ------------------------------------------------------------------------------------------------
        function this = test_rebin_d1d(this)
            skipTest('Needs fit_sqw to be implemented.')

            % Special case of d1d rebin
            w1d_sqw=read_sqw(fullfile(this.data_dir,'w1d_sqw.sqw'));
            w1d_d1d=read_dnd(fullfile(this.data_dir,'w1d_d1d.sqw'));

            reb_ax=[0.05,0.0125,0.033];

            w1d_d1d_reb = cell(3, 1);
            w1d_sqw_reb = cell(3, 1);
            wfit_d1d_old = cell(3, 1);
            wfit_sqw_old = cell(3, 1);
            wfit_d1d = cell(3, 1);
            wfit_sqw = cell(3, 1);
            fitdata_d1d_old = cell(3, 1);
            fitdata_sqw_old = cell(3, 1);
            fitdata_d1d = cell(3, 1);
            fitdata_sqw = cell(3, 1);

            for i=1:3
                w1d_d1d_reb{i}=rebin_horace_1d(w1d_d1d,reb_ax(i));
                w1d_sqw_reb{i}=cut(w1d_sqw,reb_ax(i));
                if i==2
                    w1d_d1d_reb{i}=rebin_horace_1d(w1d_d1d_reb(i),0.025);
                end
                [wfit_d1d_old{i},fitdata_d1d_old{i}]=fit_sqw(w1d_d1d_reb{i},@fake_cross_sec,[80,0.1,10]);
                [wfit_sqw_old{i},fitdata_sqw_old{i}]=fit_sqw(w1d_sqw_reb{i},@fake_cross_sec,[80,0.1,10]);

                mf_d1d = multifit_sqw (w1d_d1d_reb(i));
                mf_d1d = mf_d1d.set_fun (@fake_cross_sec, 0.9*[80,0.1,10]);
                [wfit_d1d(i), fitdata_d1d(i)] = mf_d1d.fit();
                mf_sqw = multifit_sqw (w1d_sqw_reb(i));
                mf_sqw = mf_sqw.set_fun (@fake_cross_sec, 0.9*[80,0.1,10]);
                [wfit_sqw{i}, fitdata_sqw{i}] = mf_sqw.fit();
            end

            [ok,mess]=equal_to_tol(fitdata_d1d{1}.p,fitdata_d1d{2}.p,-2e-3,'ignore_str', 1);
            assertTrue(ok,['rebin d1d using step syntax fails: ',mess])

            [ok,mess]=equal_to_tol(fitdata_d1d{1}.p,fitdata_d1d{3}.p,-5e-3,'ignore_str', 1);
            assertTrue(ok,['rebin d1d using step syntax fails: ',mess])

            [ok,mess]=equal_to_tol(fitdata_sqw(1).p,fitdata_sqw(2).p,-1e-6,'ignore_str', 1);
            assertTrue(ok,['rebin d1d using step syntax fails: ',mess])

            [ok,mess]=equal_to_tol(fitdata_sqw{1}.p,fitdata_sqw{3}.p,-1e-6,'ignore_str', 1);
            assertTrue(ok,['rebin d1d using step syntax fails: ',mess])

        end
    end
end
