classdef test_cut_sqw_sym < TestCaseWithSave
% Test of various operations associated with symmetrisation
    properties
        data_source
        data
        sym
        proj
        bin
        width
        ebins
        tol_sp
        data2_source
        sym2
        data2
        proj2
        ubin2
        vbin2
        wbin2
        ebin2

    end

    methods

        function obj = test_cut_sqw_sym(name)
            if nargin<1
                name = 'test_cut_sqw_sym';
            end
            obj@TestCaseWithSave(name)

            % Get Horace log level
            obj.log_level = get(hor_config,'log_level');

            % Read in data
            this_path = fileparts(mfilename('fullpath'));
            obj.data_source = fullfile(this_path,'test_cut_sqw_sym.sqw');
            obj.data = read_horace(obj.data_source);

            % Cut projection and ranges etc
            s100 = SymopReflection([1,0,0],[0,0,1],[1,1,0]);
            sdiag= SymopReflection([1,1,0],[0,0,1],[1,1,0]);
            obj.sym = {sdiag,s100,[sdiag,s100]};

            obj.proj = ortho_proj([1,-1,0], [1,1,0]/sqrt(2), 'offset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            obj.bin = [range(1)+step/2,step,range(2)-step/2];
            obj.width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            obj.ebins = [105,0,115];

            %%% New tests:
            % Read the stored pixel data
            obj.data2_source = fullfile(this_path, 'test_sym_op.sqw');
            obj.data2 = read_horace(obj.data2_source);
            % Construct the pointgroup operations of P 2_1 3:
            Ws = [1 -1  1 -1  0  0  0  0  0  0  0  0
                  0  0  0  0  1 -1  1 -1  0  0  0  0
                  0  0  0  0  0  0  0  0  1 -1  1 -1
                  0  0  0  0  0  0  0  0  1 -1 -1  1
                  1 -1 -1  1  0  0  0  0  0  0  0  0
                  0  0  0  0  1 -1 -1  1  0  0  0  0
                  0  0  0  0  1  1 -1 -1  0  0  0  0
                  0  0  0  0  0  0  0  0  1  1 -1 -1
                  1  1 -1 -1  0  0  0  0  0  0  0  0];
            Ws = mat2cell(reshape(Ws,[3,3,12]),3,3,ones(12,1));
            obj.sym2 = squeeze(cellfun(@SymopGeneral, Ws, 'UniformOutput', false));
            % setup projection and binning specifications
            obj.proj2 = ortho_proj([1,0,0],[0,1,0]);
            obj.ubin2 = [-0.5, 0.05, 0.5];
            obj.vbin2 = [-0.1, 0.1];
            obj.wbin2 = [-0.1, 0.1];
            obj.ebin2 = [-2, 2];

            % Tolerance
            obj.tol_sp = [1e-6,1e-6];

            % Save line - must be the last line
            obj.save()
        end

        function setUp(obj)
            set(hor_config,'log_level',-1);  % turn off output
        end

        function tearDown(obj)
            set(hor_config,'log_level',obj.log_level);
        end

        %------------------------------------------------------------------------
        % Tests
        %------------------------------------------------------------------------

        function test_cut_sym_identity_stripped(obj)
            tsqw = sqw.generate_cube_sqw(10);

            res_sqw = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                          [-5 5], [0 1 1.5], [-1.5 1 1.5], [-5 5]);
            res_sqw2 = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                           [-5 5], [0 1 1.5], [-1.5 1 1.5], [-5 5], ...
                           {SymopIdentity()});
            res_sqw3 = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                           [-5 5], [0 1 1.5], [-1.5 1 1.5], [-5 5], ...
                           SymopIdentity());

            assertEqual(res_sqw, res_sqw2)
            assertEqual(res_sqw, res_sqw3)

        end

        function test_cut_sym_no_dup_2_identity(obj)
        % Test symmetrisation, does not duplicate pixels
        % Even if we cut identity twice.
        % `id` is defined as 2 identical reflections because
        % `SymopIdentity`s are filtered from ops.


            op = SymopReflection([1 0 0], [0 1 0], [0 0 0]);
            id = [op, op]; % Reflect reflect back
            tsqw = sqw.generate_cube_sqw(10);

            res_sqw = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                          [-5 5], [0 1 1.5], [-1.5 1 1.5], [-5 5]);
            res_sqw2 = cut(tsqw, ortho_proj([1 0 0], [0 1 0]), ...
                           [-5 5], [0 1 1.5], [-1.5 1 1.5], [-5 5], ...
                           {id});

            assertEqual(res_sqw.data, res_sqw2.data)

        end

        function test_cut_sym_reflect_half_to_whole_cut(obj)
            op = SymopReflection([0 1 0], [0 0 1], [0 0 0]);

            data = sqw.generate_cube_sqw(10);
            wtmp = symmetrise_sqw(data, [0 1 0], [0 0 1], [0 0 0]);
            proj = ortho_proj([1 0 0], [0 1 0]);
            ubin_half = [2 1 5];

            w1sym = cut(wtmp, proj, ubin_half, ...
                        obj.vbin2, obj.wbin2, obj.ebin2);

            w2sym = cut(data, proj, ubin_half, ...
                        obj.vbin2, obj.wbin2, obj.ebin2, ...
                        {SymopIdentity(), op});

            [ok, mess] = equal_to_tol(w1sym.data.s, w2sym.data.s, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
            [ok, mess] = equal_to_tol(w1sym.data.e, w2sym.data.e, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
            [ok, mess] = equal_to_tol(w1sym.data.npix, w2sym.data.npix, 'ignore_str', 1);
            if ~ok
                error(mess)
            end

        end

        function test_cut_sym_with_pix(obj)
        % Test symmetrisation, keeping pixels
            w2sym = cut(obj.data, obj.proj, obj.bin,...
                        obj.width, obj.width, obj.ebins, obj.sym);

            w2symref = obj.getReferenceDataset('test_cut_sym_with_pix', 'w2sym');

            [ok, mess] = equal_to_tol(w2sym.data.s, w2symref.data.s, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
            [ok, mess] = equal_to_tol(w2sym.data.e, w2symref.data.e, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
            [ok, mess] = equal_to_tol(w2sym.data.npix, w2symref.data.npix, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
        end

        function test_cut_sym_with_nopix(obj)
        % Test symmetrisation, without keeping pixels
            d2sym = cut(obj.data, obj.proj, obj.bin,...
                        obj.width, obj.width, obj.ebins, obj.sym, '-nopix');

            obj.assertEqualToTolWithSave(d2sym, obj.tol_sp,'ignore_str',1);
        end

        function test_cut_sqw_sym_ptgr(obj)
        % Test multiple overlapping symmetry related cuts, some of
        % which contribute zero pixels to the result.

            obj.data2.pix = PixelDataMemory(obj.data2.pix);
            c = cut(obj.data2, obj.proj2, ...
                    obj.ubin2, obj.vbin2, obj.wbin2, obj.ebin2, ...
                    obj.sym2);

            cref = obj.getReferenceDataset('test_cut_sqw_sym_ptgr', 'c');

            c.data.s
            cref.data.s
            [ok, mess] = equal_to_tol(c.data.s, cref.data.s, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
            [ok, mess] = equal_to_tol(c.data.e, cref.data.e, 'ignore_str', 1);
            if ~ok
                error(mess)
            end
            [ok, mess] = equal_to_tol(c.data.npix, cref.data.npix, 'ignore_str', 1);
            if ~ok
                error(mess)
            end

%             obj.assertEqualToTolWithSave(c, obj.tol_sp,'ignore_str',1);
        end

        function test_multicut_1(obj)
        % Test multicut capability for cuts that are adjacent
        % Note that the last cut has no pixels retained - a good test too!
            skipTest("New dnd (d2d) not supported yet #878");

            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.data, obj.proj, obj.bin,...
                     obj.width, obj.width, [106,4,114,4], '-pix');
            w2 = repmat(sqw,[3,1]);
            for i=1:3
                tmp = cut(obj.data, obj.proj, obj.bin,...
                          obj.width, obj.width, 102+4*i+[-2,2], '-pix');
                w2(i) = tmp;
            end
            assertEqualToTol(w1, w2, obj.tol_sp,'ignore_str',1)

            % Save dnd only to save disk space
            d1=dnd(w1);
            obj.assertEqualToTolWithSave(d1, obj.tol_sp,'ignore_str',1);
            d2=dnd(w2);
            obj.assertEqualToTolWithSave(d2, obj.tol_sp,'ignore_str',1);
        end

        function test_multicut_2(obj)
        % Test multicut capability for cuts that are adjacent
        % Last couple of cuts have no pixels read or are even outside the range
        % of the input data

        % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.data, obj.proj, obj.bin,...
                     obj.width, obj.width, [110,2,118,2], '-pix');
            w2 = repmat(sqw,[5,1]);
            for i=1:5
                w2(i) = cut(obj.data, obj.proj, obj.bin,...
                            obj.width, obj.width, 108+2*i+[-1,1], '-pix');
            end
            assertEqualToTol(w1, w2, obj.tol_sp,'ignore_str',1)

            % Save dnd only to save disk space
            d1=dnd(w1);
            obj.assertEqualToTolWithSave(d1, obj.tol_sp,'ignore_str',1);
            d2=dnd(w2);
            obj.assertEqualToTolWithSave(d2, obj.tol_sp,'ignore_str',1);
        end

        function test_multicut_3(obj)
        % Test multicut capability for cuts that overlap adjacent cuts

        % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut(obj.data, obj.proj, obj.bin,...
                          obj.width, obj.width, [106,4,114,8], '-pix');
            w2 = repmat(sqw,[3,1]);
            for i=1:3
                w2(i) = cut(obj.data, obj.proj, obj.bin,...
                                 obj.width, obj.width, 102+4*i+[-4,4], '-pix');
            end
            assertEqualToTol(w1, w2, obj.tol_sp,'ignore_str',1)

            % Save dnd only to save disk space
            d1=dnd(w1);
            obj.assertEqualToTolWithSave(d1, obj.tol_sp,'ignore_str',1);
            d2=dnd(w2);
            obj.assertEqualToTolWithSave(d2, obj.tol_sp,'ignore_str',1);
        end

        function test_cut_with_pix(obj)
        % Test a simple cut keeping pixels

            w2 = cut(obj.data, obj.proj, obj.bin,...
                     obj.width, obj.width, obj.ebins, '-pix');
            obj.assertEqualToTolWithSave(w2, obj.tol_sp,'ignore_str',1);
        end

        function test_cut_with_nopix(obj)
        % Test a simple cut without keeping pixels

            d2 = cut(obj.data, obj.proj, obj.bin,...
                     obj.width, obj.width, obj.ebins, '-nopix');
            obj.assertEqualToTolWithSave(d2, obj.tol_sp,'ignore_str',1);
        end

        %------------------------------------------------------------------------
        % Tests to add:
        % - cut from a file with no pixels, overlapping limits, outside limits
        % - cut from objects, not files
        % - handcraft a symmetrised cut, using the private combine
        %------------------------------------------------------------------------
    end

end
