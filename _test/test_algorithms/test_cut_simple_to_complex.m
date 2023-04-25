classdef test_cut_simple_to_complex < TestCaseWithSave
    % Testing cuts from simple one to complex
    % and comparing the results against the reference cuts.
    %
    % Intended for debugging issues in cuts while cut algorithm is
    % refactored
    %
    % Reference cut is generated in the constructor if '-save' option is
    % provided
    properties
        FLOAT_TOL = 1e-5;
        ref_par_file = 'MAP11014.nxspe'; % located in common data
        this_dir;
        ref1d_cut
        sqw_4D_artificial
    end
    
    methods
        
        function obj = test_cut_simple_to_complex(varargin)
            if nargin == 0
                name = 'test_cut_simple_to_complex';
            else
                name = varargin{1};
            end
            obj = obj@TestCaseWithSave(name);
            
            %
            %
            obj.this_dir = fileparts(mfilename('fullpath'));
            par_file = fullfile(fileparts(obj.this_dir),...
                'common_data',obj.ref_par_file);
            en = -5:1:80;
            efix = 85;
            alatt = [2.83,2.83,2.83];
            angdeg = [90,90,90];
            wtmp = dummy_sqw(en,par_file,'',efix,1,...
                alatt,angdeg,[0,0,1],[0,-1,0],0,0,0,0,0,[50,50,50,50]);
            
            obj.sqw_4D_artificial = sqw_eval(wtmp{1},@make_bragg_blobs,...
                {[10,1,1],[alatt,angdeg],[alatt,angdeg],[0,0,0],0});
            % test with save method, updating references if '-save' option
            % provided
            obj.save();
        end
        function test_simple1Dcut_from_cut(obj)
            sqw_obj = obj.sqw_4D_artificial;
            pr = struct('u',[1,0,0],'v',[0,1,0]);
            ref_file = fullfile(obj.this_dir,'test_cut_simple_to_complex_output.mat');
            if is_file(ref_file)
                ld = load(ref_file);
                fn  = 'test_simple1Dcut_from_newly_generated_sqw_object';
                if isfield(ld,fn)
                    tr = ld.(fn);
                    cut0 = tr.cut1D_ng;
                else
                    cut0 = [];
                end
            else
                cut0 = [];
            end
            if isempty(cut0)
                cut0 = cut(sqw_obj,pr,[-1.5,0.02,1.5],[-0.1,0.1],...
                    [-0.1,0.1],[-5,5]);
            end
            cut1_fc = cut(cut0,pr,[0,0.02,1.5],[-0.1,0.1],[-0.1,0.1],[-5,5]);
            
            assertEqualWithSave(obj,cut1_fc,'ignore_str',1);
        end        
        
        function test_simple1Dcut_from_newly_generated_sqw_object(obj)
            sqw_obj = obj.sqw_4D_artificial;
            pr = struct('u',[1,0,0],'v',[0,1,0]);
            cut1D_ng = cut(sqw_obj,pr,[-1.5,0.02,1.5],[-0.1,0.1],[-0.1,0.1],[-5,5]);
            
            assertEqualToTolWithSave(obj,cut1D_ng,'ignore_str',1,'tol',1.e-9);
        end

        function test_nranges(obj)
            source_ab = obj.sqw_4D_artificial.data.axes;
            source_proj = obj.sqw_4D_artificial.data.proj;

            targ_proj = ortho_proj([1,0,0],[0,1,0],'alatt',source_proj.alatt,'angdeg',source_proj.angdeg);
            targ_ax   = targ_proj.get_proj_axes_block(source_ab.get_cut_range(), ...
                {[-1.5,0.02,1.5],[-0.1,0.1],[-0.1,0.1],[-5,5]});
            npix = ones(source_ab.dims_as_ssize);
            %
            source_proj.disable_srce_to_targ_optimization = true;
            [startpos_gen,block_size_gen] = source_proj.get_nrange(npix,source_ab,targ_ax,targ_proj);

            source_proj.disable_srce_to_targ_optimization = false;            
            [startpos_spec,block_size_spec] = source_proj.get_nrange(npix,source_ab,targ_ax,targ_proj);            
            assertEqual(startpos_gen,startpos_spec);
            assertEqual(block_size_gen,block_size_spec);            

            assertEqualWithSave(obj,startpos_gen);
            assertEqualWithSave(obj,block_size_gen);            
        end
    end
    
end
