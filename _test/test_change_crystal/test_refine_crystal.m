classdef test_refine_crystal < TestCase
    % Some tests that refine_crystal is doing its job properly
    %
    % Author: T.G.Perring
    properties
        % The expected accurate positons of the Bragg peaks to align crystal
        %
        bragg_peak_expected=[1,0,0; 0,1,0; 0,0,1];
        %
        alatt_base=[5,5,5];
        angdeg_base=[90,90,90];

        bragg_peak_measured;  % simulated postions of the Bragg peaks, identified from
        %     % test "experiment"
        ref_data
        bragg_peak_mnoise;  % rlu with noise
        answer_r
    end

    methods
        function obj=test_refine_crystal(varargin)
            if nargin == 0
                name = 'test_refine_crystal';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

            ang_dev=0;
            rad_dev=0;
            rotvec=[0,0,0];
            obj.bragg_peak_measured = obj.make_rlu(obj.bragg_peak_expected, [obj.alatt_base,obj.angdeg_base], ...
                [obj.alatt_base,obj.angdeg_base], rotvec, ang_dev, rad_dev);
            obj.ref_data = struct('rlu_corr',eye(3),'alatt',obj.alatt_base,'angdeg',obj.angdeg_base,'rotmat',eye(3));

            % Introduce random noise and a rotation
            % -------------------------------------
            % The random noise requis a large tolerance in the test of the fit
            ang_dev=0.02;
            rad_dev=0.005;
            rotvec=[pi/2,0,0];
            obj.bragg_peak_mnoise = obj.make_rlu(obj.bragg_peak_expected, [obj.alatt_base,obj.angdeg_base], ...
                [obj.alatt_base,obj.angdeg_base], rotvec, ang_dev, rad_dev);
            obj.answer_r = struct('rlu_corr',[1,0,0;0,0,1;0,-1,0],'alatt',obj.alatt_base, ...
                'angdeg',obj.angdeg_base,'rotmat',[1,0,0;0,0,1;0,-1,0]);

        end
        function test_exact_fit(obj)
            % Case where exact fit should be possible
            % ---------------------------------------
            % The refinement involves a least-squares fit, so will not be exact, hence the large tolerance

            algn_inf = refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base,obj.bragg_peak_measured);
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.ref_data,1e-9);
        end
        function test_fit_from_different_lattice_and_angle(obj)

            algn_inf = refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base, ...
                obj.bragg_peak_measured,[5.1,5.2,5.3],[92,88,91]);
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.ref_data,1e-9);
        end
        function test_fit_from_different_lattice(obj)


            algn_inf= refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base, ...
                obj.bragg_peak_measured,[5.1,5.2,5.3],[90,90,90]);
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.ref_data,1e-9);
        end
        function test_fit_from_different_lattice_fix_angles(obj)

            algn_inf = refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base, ...
                obj.bragg_peak_measured,[5.1,5.2,5.3],[90,90,90],'fix_ang');
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.ref_data,1e-9);
        end

        function test_fit_with_rotation_fix_ang(obj)

            algn_inf = refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base, ...
                obj.bragg_peak_mnoise,'fix_ang');
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.answer_r,-3e-2,'min_denominator',1);
        end
        function test_fit_with_rot_latt_guess_fix_ang(obj)

            algn_inf = refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base, ...
                obj.bragg_peak_mnoise,[5.1,5.2,5.3],[90,90,90],'fix_ang');
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.answer_r,-3e-2,'min_denominator',1);
        end

        function test_fit_with_rot_free_alatt(obj)

            algn_inf  = refine_crystal( ...
                obj.bragg_peak_expected,obj.alatt_base,obj.angdeg_base, ...
                obj.bragg_peak_mnoise,[5.1,5.2,5.3],[90,90,90],'free_alatt',[1,0,1]);
            algn_inf.legacy_mode = true;
            proj = ortho_proj('alatt',obj.alatt_base,'angdeg',obj.angdeg_base);
            fit_data = struct('rlu_corr',algn_inf.get_corr_mat(proj), ...
                'alatt',algn_inf.alatt,'angdeg',algn_inf.angdeg, ...
                'rotmat',algn_inf.rotmat);

            assertEqualToTol(fit_data,obj.answer_r,-5e-2,'min_denominator',1);
        end
    end
    methods(Static,Access=private)
        function rlu = make_rlu (rlu0, lattice0, lattice, rotvec, ang_dev, rad_dev)
            % Create input rlu for testing refine_orientation
            %
            %   >> rlu = make_rlu (rlu0, lattice0, lattice, rotvec, ang_dev, rad_dev)
            %
            % Input:
            % ------
            %   rlu0        Positions of Bragg peaks as h,k,l in reference lattice
            %                  (n x 3 matrix, n=no. reflections)
            %   lattice0    Reference lattice parameters [a,b,c,alf,bet,gam] (Angstroms and degrees)
            %   lattice     True lattice parameters [a,b,c,alf,bet,gam] (Angstroms and degrees)
            %   rotvec      Rotation vector that rotates crystal Cartesian frame of
            %                  reference lattice to that for true lattice (radians)
            %   ang_dev     Maximum deviation of random components of rotation vector
            %                  use to give random transverse errors to output rlu (radians)
            %                  Each rlu vector is given diffrerent random error
            %   rad_dev     Maximum random fractional error in radial length of output rlu
            %                  Each rlu vector is given diffrerent random error
            %
            % Author: T.G.Perring

            b0 = bmatrix(lattice0(1:3),lattice0(4:6));
            b = bmatrix(lattice(1:3),lattice(4:6));

            rotmat=rotvec_to_rotmat2(rotvec);
            vcryst=rotmat*b0*rlu0';

            nv=size(rlu0,1);
            for iv=1:nv
                drotvec=2*(rand(3,1)-0.5)*ang_dev;
                drotmat=rotvec_to_rotmat2(drotvec);
                vcryst_tmp=drotmat*vcryst(:,iv);  % random rotation
                vcryst_tmp=vcryst_tmp*(1+rad_dev*2*(rand(1)-0.5));
                vcryst(:,iv)=vcryst_tmp;
            end

            rlu= (b \ vcryst)';
        end

    end
end