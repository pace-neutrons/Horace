classdef test_symm < TestCase
    % Validate the dnd symmetrisation routines

    properties
        % What we actually want to do is to simulate some cross-section that is
        % symmetric so that we can compare results easily.
        stiffness=80;
        gam=0.1;
        amp=10;
        testdir;
    end

    methods
        function obj=test_symm(name)
            obj=obj@TestCase(name);

            hp = horace_paths;
            obj.testdir = hp.test_common;
        end

        function obj=prepare_test_data(obj)
            % Create the data (should not need to do this again)
            % Use sqw file on RAE's laptop to perform tests. Data saved to a .mat file on SVN server
            % for validation by others.
            data_source='C:\Russell\PCMO\ARCS_Oct10\Data\SQW\ei140.sqw';
            proj.u=[1,1,0]; proj.v=[-1,1,0]; proj.type='rrr';

            % To ensure some of the catches for dnd symmetrisation work properly, need
            % to add some errorbars to all of the data points as well. Take from the
            % original data. Errorbars are rescaled to be appropriate size for new
            % signal array

            % Three-dimensional data sets
            w3d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[0,1.4,100]);
            w3d_sqw=sqw_eval(w3d_sqw,@fake_cross_sec,[obj.stiffness,obj.gam,obj.amp]);
            errs=w3d_sqw.data.pix.signal;
            w3d_sqw.data.pix.variance=errs;
            w3d_sqw=cut(w3d_sqw,[-1,0.025,1],[-1,0.025,1],[0,1.4,100]);
            w3d_d3d=d3d(w3d_sqw);

            % Two-dimensional data sets
            w2d_qe_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[0,1.4,100]);
            w2d_qe_sqw=sqw_eval(w2d_qe_sqw,@fake_cross_sec,[obj.stiffness,obj.gam,obj.amp]);
            errs=w2d_qe_sqw.data.pix.signal;
            w2d_qe_sqw.data.pix.variance=errs;
            w2d_qe_sqw=cut(w2d_qe_sqw,[-1,0.025,1],[0,1.4,100]);
            w2d_qe_d2d=d2d(w2d_qe_sqw);

            w2d_qq_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-1,0.025,1],[-Inf,Inf],[30,40]);
            w2d_qq_sqw=sqw_eval(w2d_qq_sqw,@fake_cross_sec,[obj.stiffness,obj.gam,obj.amp]);
            errs=w2d_qq_sqw.data.pix.signal;
            w2d_qq_sqw.data.pix.variance=errs;
            w2d_qq_sqw=cut(w2d_qq_sqw,[-1,0.025,1],[-1,0.025,1]);
            w2d_qq_d2d=d2d(w2d_qq_sqw);

            w2d_qq_small_sqw=cut_sqw(data_source,proj,[0,0.025,0.4],[0,0.025,0.4],[-Inf,Inf],[30,40]);
            w2d_qq_small_d2d=d2d(w2d_qq_small_sqw);

            % One-dimensional data sets
            w1d_sqw=cut_sqw(data_source,proj,[-1,0.025,1],[-0.1,0.1],[-Inf,Inf],[30,40]);
            w1d_sqw=sqw_eval(w1d_sqw,@fake_cross_sec,[obj.stiffness,obj.gam,obj.amp]);
            errs=w1d_sqw.data.pix.signal;
            w1d_sqw.data.pix.variance=errs;
            w1d_sqw=cut(w1d_sqw,[-1,0.025,1]);
            w1d_d1d=d1d(w1d_sqw);

            % Save data
            save(w3d_sqw,[obj.testdir,filesep,'w3d_sqw.sqw']);
            save(w3d_d3d,[obj.testdir,filesep,'w3d_d3d.sqw']);

            save(w2d_qe_sqw,[obj.testdir,filesep,'w2d_qe_sqw.sqw']);
            save(w2d_qe_d2d,[obj.testdir,filesep,'w2d_qe_d2d.sqw']);
            save(w2d_qq_sqw,[obj.testdir,filesep,'w2d_qq_sqw.sqw']);
            save(w2d_qq_d2d,[obj.testdir,filesep,'w2d_qq_d2d.sqw']);

            save(w1d_sqw,[obj.testdir,filesep,'w1d_sqw.sqw']);
            save(w1d_d1d,[obj.testdir,filesep,'w1d_d1d.sqw']);

            save(w2d_qq_small_sqw,[obj.testdir,filesep,'w2d_qq_small_sqw.sqw']);
            save(w2d_qq_small_d2d,[obj.testdir,filesep,'w2d_qq_small_d2d.sqw']);
        end

        % ----------------------------------------------------------------------
        % Tests
        % ----------------------------------------------------------------------

        function obj = test_sym_sqw(obj)
            % sqw symmetrisation:
            w3d_sqw = read_sqw(fullfile(obj.testdir,'w3d_sqw.sqw'));

            % one pixel lost, pity, but bearable.
            w3d_sqw_sym = symmetrise_sqw(w3d_sqw, [0,0,1], [-1,1,0], [0,0,0]);
            assertEqual(w3d_sqw.pix.num_pixels-1, w3d_sqw_sym.pix.num_pixels);

            w3d_sqw_sym2 = symmetrise_sqw(w3d_sqw_sym, [1,1,0], [0,0,1], [0,0,0]);
            assertEqual(w3d_sqw_sym.pix.num_pixels, w3d_sqw_sym2.pix.num_pixels);

            w3d_sqw_sym3 = symmetrise_sqw(w3d_sqw_sym2, [0,0,1], [-1,1,0], [0,0,0]);
            assertEqual(w3d_sqw_sym3.pix.num_pixels, w3d_sqw_sym2.pix.num_pixels);

            w3d_sqw_sym
            w3d_sqw_sym.pix
            w3d_sqw_sym.dimensions

            cc1 = cut(w3d_sqw_sym,  [0.2,0.025,1], [-0.1,0.1], [0,1.4,99.8]);
            cc2 = cut(w3d_sqw_sym3, [0.2,0.025,1], [-0.1,0.1], [0,1.4,99.8]);

            assertEqualToTol(d2d(cc1), d2d(cc2), 'relative', 1e-6, 'ignore_str', 1);
        end

        function obj = test_sym_d2d(obj)
            % d2d symmetrisation:
            skipTest('Symmetrize DND is disabled until DND is refactored #878')
            w2d_qe_d2d = read_dnd(fullfile(obj.testdir,'w2d_qe_d2d.sqw'));
            w2d_qq_d2d = read_dnd(fullfile(obj.testdir,'w2d_qq_d2d.sqw'));

            w2_1 = symmetrise_horace_2d(w2d_qe_d2d,[0,NaN]);
            w2_2 = symmetrise_horace_2d(w2d_qq_d2d,[-0.005,NaN]);

            w2_1a = symmetrise_horace_2d(w2d_qe_d2d,[0,0,1],[-1,1,0],[0,0,0]);
            w2_2a = symmetrise_horace_2d(w2d_qq_d2d,[0,0,1],[-1,1,0],[-0.005,-0.005,0]);

            % Confirm that if we symmetrise about an existing axis, then routines above
            % are consistent.
            assertEqualToTol(w2_1, w2_1a, 'relative', 1e-8)
            assertEqualToTol(w2_2,w2_2a, 'relative', 1e-8)

            % Compare symmetrisation along a diagonal (shoelace vs sqw symm). These are
            % actually unlikely to be the same, because the methodology is totally
            % different...
            % Diagonal symm axis
            w2d_qq_sqw=sqw(fullfile(obj.testdir,'w2d_qq_sqw.sqw'));
            w2_2b_s=d2d(symmetrise_sqw(w2d_qq_sqw,[0,0,1],[0,1,0],[0,0,0]));
            w2_2b_s=cut(w2_2b_s,[-1,0,1],[-1,0,1]);

            w2d_qq_d2d=d2d(fullfile(obj.testdir,'w2d_qq_d2d.sqw'));
            w2_2b=symmetrise_horace_2d(w2d_qq_d2d,[0,0,1],[0,1,0],[0,0,0]);
            w2_2b=cut(w2_2b,[-1,0,1],[-1,0,1]);

            % Is a solution to validating these running a fit with our original sqw
            % function?
            mf = multifit_sqw(w2_2b);
            mf = mf.set_fun (@fake_cross_sec, [0.9*obj.stiffness,obj.gam,obj.amp],[1,0,0]);
            [wfit_2b,fitdata_2b] = mf.fit();

            mf_s = multifit_sqw (w2_2b_s);
            mf_s = mf_s.set_fun (@fake_cross_sec, [0.9*obj.stiffness,obj.gam,obj.amp],[1,0,0]);
            [wfit_2b_s,fitdata_2b_s] = mf_s.fit();

            assertEqualToTol(fitdata_2b.p(1), fitdata_2b_s.p(1), 'relative', 3e-2)

        end

        function obj=test_random_symax(obj)
            skipTest('Symmetrize DND is disabled until DND is refactored #878')
            w2d_qq_small_d2d=read_dnd(fullfile(obj.testdir,'w2d_qq_small_d2d.sqw'));

            % Random symm axis (ensure shoelace algorithm is actually tested)
            w2_2c=symmetrise_horace_2d(w2d_qq_small_d2d,[0,0,1],[0.5,1,0],[0,0,0]);
            w2_2c2=symmetrise_horace_2d(w2_2c,[0,0,1],[0.5,1,0],[1,0,0]);
            w2_2c3=symmetrise_horace_2d(w2_2c2,[0.5,1,0],[0,0,1],[1,0,0]);

            c1=cut(w2_2c,[0,0.6],[-0.4,0.2]);
            c2=cut(w2_2c3,[0,0.6],[-0.4,0.2]);

            assertEqualToTol(c1.s, c2.s, 'relative', 0.005,'ignore_str', 1);
        end

        function obj=test_d1d_sym(obj)
            skipTest('Symmetrize DND is disabled until DND is refactored #878')
            w1d_sqw=read_sqw(fullfile(obj.testdir,'w1d_sqw.sqw'));
            w1d_d1d=read_dnd(fullfile(obj.testdir,'w1d_d1d.sqw'));

            % d1d symmetrisation (a whole lot easier)
            w1_1=symmetrise_horace_1d(w1d_d1d,0.25);
            w1_1s=symmetrise_sqw(w1d_sqw,[0,0,1],[-1,1,0],[0.25,0.25,0]);

            mf = multifit_func (w1_1);
            mf = mf.set_fun (@mgauss, [20,0.75,0.062,20,1.25,0.062], [1,1,0,1,1,0]);
            mf = mf.set_bfun (@quad_bg, [8.95,-5.3,0.1], [1,1,1]);
            mf = mf.set_mask ('keep',[0.5,1.5]);
            [wfit1_1,fitdata1_1] = mf.fit();

            mfs = multifit_func (w1_1s);
            mfs = mfs.set_fun (@mgauss, [20,0.75,0.062,20,1.25,0.062], [1,1,0,1,1,0]);
            mfs = mfs.set_bfun (@quad_bg, [8.95,-5.3,0.1], [1,1,1]);
            mfs = mfs.set_mask ('keep',[0.5,1.5]);
            [wfit1_1s,fitdata1_1s] = mfs.fit();


            toterr = sqrt(fitdata1_1.sig.^2 + fitdata1_1s.sig.^2);
            fitdiff = abs(fitdata1_1.p - fitdata1_1s.p);

            % NB - test here is very fiddly, the fitting to gaussians is not great, but
            % we are within 2 s.d. on the peak position with suspiciously small
            % errorbar...

            assertTrue(all(fitdiff<=2*toterr),'d1d symmetrisation about midpoint failed')
        end
    end
end
