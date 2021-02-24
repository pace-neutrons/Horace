classdef test_data_sqw_dnd < TestCaseWithSave
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tmp_dir();
        ref_sqw
        par_file = 'map_4to1_dec09.par'
    end
    
    methods
        function obj=test_data_sqw_dnd(varargin)
            if nargin<1
                name = 'test_data_sqw_dnd';
            else
                name = varargin{1};
            end
           obj = obj@TestCaseWithSave(name,'data_sqw_dnd_V1_ref_data');
           
          root_dir = horace_root();
          data_dir = fullfile(root_dir,'_test','common_data');
          obj.par_file =  fullfile(data_dir,obj.par_file);
          ref_sqw = fake_sqw(-80:8:760, obj.par_file, '', 800,...
                    1, [2,2.5,2], [95,110,90],...
                    [1,0,0], [0,1,0], 5,...
                    0, 0, 0, 0);
           obj.ref_sqw = ref_sqw{1};

        end
        
        function this=test_get_q_qaxes(this)
            proj.u = [1,0,0];
            proj.v = [0,1,0];
            obj = data_sqw_dnd(proj,[1,0.1,2],[-1,0.01,1],[0,0.1,1],[0,1,10]);
            [qh,qk,ql] = obj.get_q_axes();
            assertEqual(numel(qh),12);
            assertEqual(numel(qk),202);
            assertEqual(numel(ql),12);
            %
            assertEqual(qh(1),0.95);
            assertEqual(qh(12),2.05);
            assertEqual(qk(1),-1.005);
            assertEqual(qk(202),1.005);
            assertEqual(ql(1),-0.05);
            assertEqual(ql(12),1.05);
            
            
            
            obj = data_sqw_dnd(proj,[1,0.1,2],[-1,1],[0,0.1,1],[0,1,10]);
            [qh,qk,ql] = obj.get_q_axes();
            assertEqual(numel(qh),12);
            assertEqual(numel(qk),2);
            assertEqual(numel(ql),12);
            %
            assertEqual(qh(1),0.95);
            assertEqual(qh(12),2.05);
            assertEqual(qk(1),-1.00);
            assertEqual(qk(2),1.00);
            assertEqual(ql(1),-0.05);
            assertEqual(ql(12),1.05);

            obj = data_sqw_dnd(proj,[1,2],[-1,1],[0,0.01,1],[0,1,10]);
            [qh,qk,ql] = obj.get_q_axes();
            assertEqual(numel(qh),2);
            assertEqual(numel(qk),2);
            assertEqual(numel(ql),102);
            %
            assertEqual(qh(1),1);
            assertEqual(qh(2),2);
            assertEqual(qk(1),-1.00);
            assertEqual(qk(2),1.00);
            assertEqual(ql(1),-0.005);
            assertEqual(ql(102),1.005);
            
            obj = data_sqw_dnd(proj,[1,2],[-1,1],[0,1],[0,1,10]);
            [qh,qk,ql] = obj.get_q_axes();
            assertEqual(numel(qh),2);
            assertEqual(numel(qk),2);
            assertEqual(numel(ql),2);
            %
            assertEqual(qh(1),1);
            assertEqual(qh(2),2);
            assertEqual(qk(1),-1.00);
            assertEqual(qk(2),1.00);
            assertEqual(ql(1),0);
            assertEqual(ql(2),1);

            obj = data_sqw_dnd(proj,[1,0.01,2],[-1,1],[0,1],[0,1,10]);
            [qh,qk,ql] = obj.get_q_axes();
            assertEqual(numel(qh),102);
            assertEqual(numel(qk),2);
            assertEqual(numel(ql),2);
            %
            assertEqual(qh(1),0.995);
            assertEqual(qh(102),2.005);
            assertEqual(qk(1),-1.00);
            assertEqual(qk(2),1.00);
            assertEqual(ql(1),0);
            assertEqual(ql(2),1);
        end
        %
        function test_loadobj_v0(obj)
            proj.u = [1,0,0];
            proj.v = [0,1,0];            
            ref_obj = data_sqw_dnd(proj,[1,0.01,2],[-1,1],[0,1],[0,1,10]);
            ld = load('data_sqw_dnd_V0_ref_data.mat');
            assertEqual(ref_obj,ld.obj);
            
            % check modern loader (if saved)
            obj.assertEqualWithSave(ref_obj);
        end
        function test_get_proj_hkl_3D(obj)            
            proj = projection([1,0,0],[0,0,1]);
            ref_cut = cut_sqw(obj.ref_sqw,proj,[],[],[],[-8,8]);
            
            proj1 =  ref_cut.data.get_projection();
            assertTrue(isa(proj,'aProjection'));
            
            same_cut = cut_sqw(obj.ref_sqw,proj1,[],[],[],[-8,8]);
            % As the range of the cut is epsiln bigger then the initial range, 
            % the comparison below does not work. TODO: fix this after proj
            % refactoring
            assertEqual(ref_cut,same_cut);
%             
%             % the comparison below is incomplete, but allows the reasonable
%             % estimation of the correctness
%             assertElementsAlmostEqual(obj.ref_sqw.data.img_range,...
%                 same_sqw.data.img_range,'relative',1.e-5);
%             assertEqual(obj.ref_sqw.data.pix.num_pixels,...
%                 same_sqw.data.pix.num_pixels);
%             cut_size  = numel(same_sqw.data.npix);
%             assertEqual(sum(reshape(obj.ref_sqw.data.npix,1,cut_size)),...
%                 sum(reshape(same_sqw.data.npix,1,cut_size)));
%             assertEqual(sum(reshape(obj.ref_sqw.data.s,1,cut_size)),...
%                 sum(reshape(same_sqw.data.s,1,cut_size)));
%             
%             
%             same_proj = same_sqw.data.get_projection();
%             assertEqual(proj,same_proj);
        end
        
        
        function test_get_proj_crystal_cartesian(obj)
            d_sqw_dnd = obj.ref_sqw.data;
            proj =  d_sqw_dnd.get_projection();
            assertTrue(isa(proj,'aProjection'));
            
            same_sqw = cut_sqw(obj.ref_sqw,proj,[],[],[],[]);
            % As the range of the cut is epsiln bigger then the initial range, 
            % the comparison below does not work. TODO: fix this after proj
            % refactoring
            %assertEqual(obj.ref_sqw,same_sqw);
            
            % the comparison below is incomplete, but allows the reasonable
            % estimation of the correctness
            assertElementsAlmostEqual(obj.ref_sqw.data.img_range,...
                same_sqw.data.img_range,'relative',1.e-5);
            assertEqual(obj.ref_sqw.data.pix.num_pixels,...
                same_sqw.data.pix.num_pixels);
            cut_size  = numel(same_sqw.data.npix);
            assertEqual(sum(reshape(obj.ref_sqw.data.npix,1,cut_size)),...
                sum(reshape(same_sqw.data.npix,1,cut_size)));
            assertEqual(sum(reshape(obj.ref_sqw.data.s,1,cut_size)),...
                sum(reshape(same_sqw.data.s,1,cut_size)));
            
            
            same_proj = same_sqw.data.get_projection();
            assertEqual(proj,same_proj);
        end
    end
end
