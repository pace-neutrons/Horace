classdef test_cut_sqw_sym < TestCaseWithSave
% Test of various operations associated with symmetrisation
    properties
        log_level
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
            obj.ubin2 = [0, 0.05, 0.5];
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

        function test_cut_sym_with_pix(obj)
        % Test symmetrisation, keeping pixels
            w2sym = cut(obj.data, obj.proj, obj.bin,...
                        obj.width, obj.width, obj.ebins, obj.sym);

            obj.assertEqualToTolWithSave(w2sym, obj.tol_sp,'ignore_str',1);
        end

        function test_cut_sym_with_nopix(obj)
        % Test symmetrisation, without keeping pixels
            d2sym = cut(obj.data, obj.proj, obj.bin,...
                        obj.width, obj.width, obj.ebins, obj.sym, '-nopix');

            obj.assertEqualToTolWithSave(d2sym, obj.tol_sp,'ignore_str',1);
        end

        function test_cut_sqw_sym_P2__1_3(obj)
        % Test multiple overlapping symmetry related cuts, some of
        % which contribute zero pixels to the result.

            c = cut(obj.data2, obj.proj2, ...
                    obj.ubin2, obj.vbin2, obj.wbin2, obj.ebin2, ...
                    obj.sym2);

            obj.assertEqualToTolWithSave(c, obj.tol_sp,'ignore_str',1);
        end

        %------------------------------------------------------------------------
        % Tests to add:
        % - cut from a file with no pixels, overlapping limits, outside limits
        % - cut from objects, not files
        % - handcraft a symmetrised cut, using the private combine
        %------------------------------------------------------------------------
    end

end
