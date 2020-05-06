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
        % Constructor
        function this = test_cut_sqw_sym (name)
            % First line - must always be here
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
            s100 = symop([1,0,0],[0,0,1],[1,1,0]);
            sdiag= symop([1,1,0],[0,0,1],[1,1,0]);
            this.sym = {sdiag,s100,[sdiag,s100]};
            
            this.proj = projaxes([1,-1,0], [1,1,0], 'uoffset', [1,1,0], 'type', 'paa');
            range = [0,0.2];    % range of cut
            step = 0.01;        % Q step
            this.bin = [range(1)+step/2,step,range(2)-step/2];
            this.width = [-0.15,0.15];  % Width in Ang^-1 of cuts
            this.ebins = [105,0,115];
            
            %%% New tests:
            % Read the stored pixel data
            this.data2_source = fullfile(this_path, 'test_sym_op.sqw');
            this.data2 = read_horace(this.data2_source);
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
            this.sym2 = squeeze(cellfun(@symop, Ws, 'UniformOutput', false));
            % setup projection and binning specifications
            this.proj2 = projaxes([1,0,0],[0,1,0]);
            this.ubin2 = [0, 0.05, 0.5];
            this.vbin2 = [-0.1, 0.1];
            this.wbin2 = [-0.1, 0.1];
            this.ebin2 = [-2, 2];
            
            
            % Tolerance
            this.tol_sp = [1e-6,1e-6];
            
            % Save line - must be the last line
            this.save()
        end
        
        %------------------------------------------------------------------------
        % Tests
        %------------------------------------------------------------------------
        function test_cut_with_pix (this)
            % Test a simple cut keeping pixels
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
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
            this.assertEqualToTolWithSave (d2, this.tol_sp,'ignore_str',1);
        end
        
        %------------------------------------------------------------------------
        function test_cut_sym_with_pix (this)
            % Test symmetrisation, keeping pixels
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
            w2sym = cut_sqw_sym (this.data_source, this.proj, this.bin,...
                this.width, this.width, this.ebins, this.sym, '-pix');
            this.assertEqualToTolWithSave (w2sym, this.tol_sp,'ignore_str',1);
        end
        %------------------------------------------------------------------------
        function test_cut_sym_with_nopix (this)
            % Test symmetrisation, without keeping pixels
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
            d2sym = cut_sqw_sym (this.data_source, this.proj, this.bin,...
                this.width, this.width, this.ebins, this.sym, '-nopix');
            this.assertEqualToTolWithSave (d2sym, this.tol_sp,'ignore_str',1);
        end
        
        %------------------------------------------------------------------------
        function test_multicut_1 (this)
            % Test multicut capability for cuts that are adjacent
            % Note that the last cut has no pixels retained - a good test too!
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut_sqw (this.data_source, this.proj, this.bin,...
                this.width, this.width, [106,4,114,4], '-pix');
            w2 = repmat(sqw,[3,1]);
            for i=1:3
                w2(i) = cut_sqw (this.data_source, this.proj, this.bin,...
                    this.width, this.width, 102+4*i+[-2,2], '-pix');
            end
            assertEqualToTol (w1, w2, this.tol_sp,'ignore_str',1)
            
            % Save dnd only to save disk space
            d1=dnd(w1);
            this.assertEqualToTolWithSave (d1, this.tol_sp,'ignore_str',1);
            d2=dnd(w2);
            this.assertEqualToTolWithSave (d2, this.tol_sp,'ignore_str',1);
        end
        
        %------------------------------------------------------------------------
        function test_multicut_2 (this)
            % Test multicut capability for cuts that are adjacent
            % Last couple of cuts have no pixels read or are even outside the range
            % of the input data
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut_sqw (this.data_source, this.proj, this.bin,...
                this.width, this.width, [110,2,118,2], '-pix');
            w2 = repmat(sqw,[5,1]);
            for i=1:5
                w2(i) = cut_sqw (this.data_source, this.proj, this.bin,...
                    this.width, this.width, 108+2*i+[-1,1], '-pix');
            end
            assertEqualToTol (w1, w2, this.tol_sp,'ignore_str',1)
            
            % Save dnd only to save disk space
            d1=dnd(w1);
            this.assertEqualToTolWithSave (d1, this.tol_sp,'ignore_str',1);
            d2=dnd(w2);
            this.assertEqualToTolWithSave (d2, this.tol_sp,'ignore_str',1);
        end
        
        %------------------------------------------------------------------------
        function test_multicut_3 (this)
            % Test multicut capability for cuts that overlap adjacent cuts
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
            % Must use '-pix' to properly handle pixel double counting in general
            w1 = cut_sqw (this.data_source, this.proj, this.bin,...
                this.width, this.width, [106,4,114,8], '-pix');
            w2 = repmat(sqw,[3,1]);
            for i=1:3
                w2(i) = cut_sqw (this.data_source, this.proj, this.bin,...
                    this.width, this.width, 102+4*i+[-4,4], '-pix');
            end
            assertEqualToTol (w1, w2, this.tol_sp,'ignore_str',1)
            
            % Save dnd only to save disk space
            d1=dnd(w1);
            this.assertEqualToTolWithSave (d1, this.tol_sp,'ignore_str',1);
            d2=dnd(w2);
            this.assertEqualToTolWithSave (d2, this.tol_sp,'ignore_str',1);
        end

        %------------------------------------------------------------------------
        function test_cut_sqw_sym_ptgr(this)
            % Test multiple overlapping symmetry related cuts, some of
            % which contribute zero pixels to the result.
            
            % Turn off output, but return to input value when exit or cntl-c
            finishup = onCleanup(@() set(hor_config,'log_level',this.log_level));
            set(hor_config,'log_level',-1);  % turn off output
            
            [c, s] = cut_sqw_sym(this.data2, this.proj2, ...
                this.ubin2, this.vbin2, this.wbin2, this.ebin2, ...
                this.sym2(2:end)); % skip the superfluous first (identity) operation
            this.assertEqualToTolWithSave(c, this.tol_sp,'ignore_str',1);
            this.assertEqualToTolWithSave(s, this.tol_sp,'ignore_str',1);
        end
        %------------------------------------------------------------------------
        % Tests to add:
        % - cut from a file with no pixels, overlapping limits, outside limits
        % - cut from objects, not files
        % - handcraft a symmetrised cut, using the private combine
        %------------------------------------------------------------------------
    end
end
