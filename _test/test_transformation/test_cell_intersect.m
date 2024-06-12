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
                    name = fullfile(fileparts(mfilename("fullpath")),name);
                end
                argi = {'-save',name};
            else
                argi = {name};
            end
            obj = obj@TestCaseWithSave(argi{:});
            obj.save();
        end
        %==================================================================
        function test_line_spher_proj_targ_compat(obj)
            bin_base = {[0,0.1,6],...
                [-2,0.1,2],...
                [-3,3],[0,10]};
            bin_targ= {[0,0.1,2],[0,1,90],[-180,180],[0,10]};

            base_proj = line_proj('alatt',2*pi,'angdeg',90);
            targ_proj = sphere_proj([0,1,0],[0,0,1],'offset',[3,-2,0],'alatt',2*pi,'angdeg',90);

            ax_base = base_proj.get_proj_axes_block(cell(1,4),bin_base);
            npix    = ones(ax_base.dims_as_ssize);
            ax_targ = targ_proj.get_proj_axes_block(cell(1,4),bin_targ);

            targ_cell = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            assertEqualWithSave(obj,targ_cell)
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

            targ_cell = base_proj.get_nrange(npix,ax_base,ax_targ,targ_proj);
            assertEqualWithSave(obj,targ_cell)
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

            assertTrue(all(ismember(ref_cell,test_cell)));
            assertTrue(all(test_size>=ref_size));            
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

            assertElementsAlmostEqual(ref_cell,test_cell);
            assertTrue(all(test_size>=ref_size));
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

            assertElementsAlmostEqual(ref_cell,test_cell);
            assertTrue(all(test_size>=ref_size));
        end
    end
end
