classdef test_cell_intersect < TestCaseWithSave
    % Series of tests for cell intersection algoritm applied for different
    % projections (coordinate systems)
    %
    %
    % The basic operations for any cut (get_nrange method)
    properties
    end

    methods
        function obj=test_cell_intersect(varargin)
            name = 'test_cell_intersect';
            if nargin>0 && strncmp(varargin{1},'-save',max(strlength(varargin{1}),2))
                if nargin == 2
                    name = varargin{2};
                else
                    name = fullfile(fileparts(mfilename("fullpath")),[name,'_output']);
                end
                argi = {'-save',name};
            else
                argi = {name};
            end
            obj = obj@TestCaseWithSave(argi{:});
            obj.save();
        end
        %==================================================================
        function test_line_spher_proj_box_shift(~)
            bin_base = {[0,0.1,6],...
                [-2,0.1,2],...
                [-4,4],[0,2,100]};
            bin_test = {[0,0.1,6],...
                [-2,0.1,2],...
                [-2,6],[0,2,100]};

            bin_targ= {[0,0.1,1.5],[30,1,60],[-180,180],[0,10]};

            base_proj = line_proj('alatt',2*pi,'angdeg',90);
            targ_proj = sphere_proj('alatt',2*pi,'angdeg',90);

            % two axes blocks with integraded dimension shifted 
            % by two, but bins should be the same.
            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin_base);
            ax_test = base_proj.get_proj_axes_block(cell(1,4),bin_test);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin_targ);

            [ref_cell ,ref_size]  = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            [test_cell,test_size] = base_proj.get_nrange(npix,ax_test,ax_targ,targ_proj);

            assertEqual(ref_cell,test_cell);
            assertEqual(ref_size,test_size);
        end

        function test_line_spher_proj_targ_compat_with_offset(obj)
            bin_base = {[0,0.1,6],...
                [-2,0.1,2],...
                [-3,3],[0,10]};
            bin_targ= {[0,0.1,2],[0,1,90],[-180,180],[0,10]};

            base_proj = line_proj('alatt',2*pi,'angdeg',90);
            targ_proj = sphere_proj([0,1,0],[0,0,1],'offset',[3,-2,0],'alatt',2*pi,'angdeg',90);

            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin_base);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin_targ);

            [targ_cell,block_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            assertEqualWithSave(obj,targ_cell)
            assertEqualWithSave(obj,block_size)
        end

        function test_line_spher_proj_targ_compat_no_offset(obj)
            bin_base = {[-1,0.1,1],...
                [-2,0.1,2],...
                [-3,3],[0,10]};
            bin_targ= {[0,0.1,0.8],[0,1,90],[-180,180],[0,10]};

            base_proj = line_proj('alatt',2*pi,'angdeg',90);
            targ_proj = sphere_proj([0,1,0],[0,0,1],'alatt',2*pi,'angdeg',90);

            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin_base);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin_targ);

            [targ_cell,block_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            % sample selected on basis of analyzing image
            assertEqualWithSave(obj,targ_cell)
            assertEqualWithSave(obj,block_size)
        end


        %------------------------------------------------------------------
        function test_line_line_proj_targ_larger_2D(~)
            dbr = [0,-2,-3,0;5,2,3,10];
            bin_base = {[dbr(1,1),0.1,dbr(2,1)],[dbr(1,2),0.1,dbr(2,2)],...
                [dbr(1,3),dbr(2,3)],[dbr(1,4),1,dbr(2,4)]};
            bin_targ= {[dbr(1,1),0.5,dbr(2,1)],[dbr(1,2),0.5,dbr(2,2)],...
                [dbr(1,3),dbr(2,3)],[dbr(1,4),1,dbr(2,4)]};

            base_proj = line_proj('alatt',3,'angdeg',90);
            targ_proj = line_proj([-1,1,0],[1,1,0],'alatt',3,'angdeg',90);

            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin_base);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin_targ);

            [ref_cell,ref_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            base_proj.convert_targ_to_source = false;

            [test_cell,test_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);

            coincide = ismember(test_cell,ref_cell);
            assertEqual(numel(ref_cell),sum(coincide));
            assertTrue(all(test_size(coincide)>=ref_size));
        end

        function test_line_line_proj_targ_smaller_2D(~)
            dbr = [0,-2,-3,0;5,2,3,10];
            bin_base = {[dbr(1,1),0.2,dbr(2,1)],[dbr(1,2),0.2,dbr(2,2)],...
                [dbr(1,3),dbr(2,3)],[dbr(1,4),1,dbr(2,4)]};
            bin_targ= {[dbr(1,1),0.02,dbr(2,1)],[dbr(1,2),0.02,dbr(2,2)],...
                [dbr(1,3),dbr(2,3)],[dbr(1,4),1,dbr(2,4)]};

            base_proj = line_proj('alatt',3,'angdeg',90);
            targ_proj = line_proj([-1,1,0],[1,1,0],'alatt',3,'angdeg',90);

            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin_base);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin_targ);

            [ref_cell,ref_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            base_proj.convert_targ_to_source = false;

            [test_cell,test_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);

            coincide = ismember(test_cell,ref_cell);
            assertEqual(numel(ref_cell),sum(coincide));
            assertTrue(all(test_size(coincide)>=ref_size));
        end

        function test_line_line_proj_comparible_2D(~)
            dbr = [0,-2,-3,0;5,2,3,10];
            bin0 = {[dbr(1,1),0.2,dbr(2,1)],[dbr(1,2),0.2,dbr(2,2)],...
                [dbr(1,3),dbr(2,3)],[dbr(1,4),1,dbr(2,4)]};
            base_proj = line_proj('alatt',3,'angdeg',90);
            targ_proj = line_proj([-1,1,0],[1,1,0],'alatt',3,'angdeg',90);

            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin0);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin0);

            [ref_cell,ref_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            base_proj.convert_targ_to_source = false;

            [test_cell,test_size] = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);

            coincide = ismember(test_cell,ref_cell);
            assertEqual(numel(ref_cell),sum(coincide));
            assertTrue(all(test_size(coincide)>=ref_size));
        end
    end
end
