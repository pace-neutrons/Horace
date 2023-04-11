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
            this@TestCaseWithSave(name)

            % Get Horace log level
            this.log_level = get(hor_config,'log_level');

            % Read in data
            this_path = fileparts(mfilename('fullpath'));
            this.data_source = fullfile(this_path,'test_cut_sqw_sym.sqw');
            this.data = read_horace(this.data_source);

            % Cut projection and ranges etc
            s100 = SymopReflection([1,0,0],[0,0,1],[1,1,0]);
            sdiag= SymopReflection([1,1,0],[0,0,1],[1,1,0]);
            this.sym = {sdiag,s100,[sdiag,s100]};

            this.proj = ortho_proj([1,-1,0], [1,1,0]/sqrt(2), 'offset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            this.bin = [range(1)+step/2,step,range(2)-step/2];
            this.width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            this.ebins = [105,0,115];

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
            this.sym2 = squeeze(cellfun(@Symop, Ws, 'UniformOutput', false));
            % setup projection and binning specifications
            this.proj2 = ortho_proj([1,0,0],[0,1,0]);
            this.ubin2 = [0, 0.05, 0.5];
            this.vbin2 = [-0.1, 0.1];
            this.wbin2 = [-0.1, 0.1];
            this.ebin2 = [-2, 2];


            % Tolerance
            this.tol_sp = [1e-6,1e-6];

            % Save line - must be the last line
            obj.save();
        end

        %------------------------------------------------------------------------
        % Tests
        %------------------------------------------------------------------------
        %------------------------------------------------------------------------
        function test_cut_sym_with_pix(obj)
            % Test symmetrisation, keeping pixels
            w2sym = cut(obj.data, obj.proj, obj.bin,...
                        obj.width, obj.width, obj.ebins, obj.sym);

            w2sym = cut_sqw_sym (this.data_source, this.proj, this.bin,...
                this.width, this.width, this.ebins, this.sym, '-pix');
            this.assertEqualToTolWithSave (w2sym, this.tol_sp,'ignore_str',1);
        end
        %------------------------------------------------------------------------
        function test_cut_sym_with_nopix (this)
            % Test symmetrisation, without keeping pixels
            skipTest("cut_sym needs modification to work with new cut #805")
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output

            d2sym = cut_sqw_sym (this.data_source, this.proj, this.bin,...
                this.width, this.width, this.ebins, this.sym, '-nopix');
            this.assertEqualToTolWithSave (d2sym, this.tol_sp,'ignore_str',1);
        end

        %------------------------------------------------------------------------
        function test_cut_sqw_sym_ptgr(this)
            % Test multiple overlapping symmetry related cuts, some of
            % which contribute zero pixels to the result.
            skipTest("cut_sym needs modification to work with new cut #805")
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output

            [c, s] = cut_sqw_sym(this.data2, this.proj2, ...
                this.ubin2, this.vbin2, this.wbin2, this.ebin2, ...
                this.sym2(2:end)); % skip the superfluous first (identity) operation
            this.assertEqualToTolWithSave(c, this.tol_sp,'ignore_str',1);
            this.assertEqualToTolWithSave(s, this.tol_sp,'ignore_str',1);
        end
        %
        function test_cut_with_pix (this)
            % Test a simple cut keeping pixels

            w2 = cut_sqw (this.data_source, this.proj, this.bin,...
                this.width, this.width, this.ebins, '-pix');
            this.assertEqualToTolWithSave (w2, this.tol_sp,'ignore_str',1);
        end

        %------------------------------------------------------------------------
        function test_cut_with_nopix (this)
            % Test a simple cut without keeping pixels
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output

            d2 = cut_sqw (this.data_source, this.proj, this.bin,...
                this.width, this.width, this.ebins, '-nopix');
            skipTest('Re #892 There is issue with cut alignment in master, sorted within the ticket #892')
            this.assertEqualToTolWithSave (d2, this.tol_sp,'ignore_str',1);
        end

        %------------------------------------------------------------------------
        % Tests to add:
        % - cut from a file with no pixels, overlapping limits, outside limits
        % - cut from objects, not files
        % - handcraft a symmetrised cut, using the private combine
        %------------------------------------------------------------------------
    end

end
