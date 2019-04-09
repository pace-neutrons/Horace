classdef test_parce_input_zone_param< TestCase
    %
    % $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_parce_input_zone_param(name)
            this = this@TestCase(name);
        end
        % tests themself
        function test_cut_transf_input_add_cp(this)
            %ctr = {cut_transf(0.1,1),cut_transf(0.1,1)};
            
            transf = zone_param_parcer([1,1,0],0.01,[0,2,100],{[1,-1,0],[-1,1,0]});
            assertEqual(numel(transf{1}.qh_range),3)
            %
            assertElementsAlmostEqual(transf{1}.qh_range,[0,0.01,2])
            assertElementsAlmostEqual(transf{1}.qk_range,[-2,0.01,0])
            assertElementsAlmostEqual(transf{1}.ql_range,[-1,0.01,1])
            assertElementsAlmostEqual(transf{1}.de_range,[0,2,100])
            %
            assertElementsAlmostEqual(transf{3}.qh_range,[0,0.01,2])
            assertElementsAlmostEqual(transf{3}.qk_range,[0,0.01,2])
            assertElementsAlmostEqual(transf{3}.ql_range,[-1,0.01,1])
            assertElementsAlmostEqual(transf{3}.de_range,[0,2,100])
            %
            assertEqual(numel(transf{2}.cut_range),4)
            assertElementsAlmostEqual(transf{2}.cut_range{1},[-2,0.01,0])
            assertElementsAlmostEqual(transf{2}.cut_range{2},[0,0.01,2])
            assertElementsAlmostEqual(transf{2}.cut_range{3},[-1,0.01,1])
            assertElementsAlmostEqual(transf{2}.cut_range{4},[0,2,100])
            
            
            assertEqual(transf{1}.transf_matrix,[1,0,0;0,-1,0;0,0,1]);
            assertEqual(transf{2}.transf_matrix,[-1,0,0;0,1,0;0,0,1]);
            assertEqual(transf{3}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
        end
        function test_cut_transf_input_cp_exist(this)
            %ctr = {cut_transf(0.1,1),cut_transf(0.1,1)};
            
            transf = zone_param_parcer([1,1,0],[0.1,0.2,0.3],[0,2,100],{[1,1,0],[1,0,-1]});
            assertEqual(numel(transf),2)
            %
            assertElementsAlmostEqual(transf{1}.qh_range,[0,0.1,2])
            assertElementsAlmostEqual(transf{1}.qk_range,[0,0.2,2])
            assertElementsAlmostEqual(transf{1}.ql_range,[-1,0.3,1])
            assertElementsAlmostEqual(transf{1}.de_range,[0,2,100])
            %
            assertElementsAlmostEqual(transf{2}.qh_range,[0,0.1,2])
            assertElementsAlmostEqual(transf{2}.qk_range,[-1,0.2,1])
            assertElementsAlmostEqual(transf{2}.ql_range,[-2,0.3,0])
            assertElementsAlmostEqual(transf{2}.de_range,[0,2,100])
            %
            assertEqual(numel(transf{2}.cut_range),4)
            assertElementsAlmostEqual(transf{2}.cut_range{1},[0,0.1,2])
            assertElementsAlmostEqual(transf{2}.cut_range{2},[-1,0.2,1])
            assertElementsAlmostEqual(transf{2}.cut_range{3},[-2,0.3,0])
            assertElementsAlmostEqual(transf{2}.cut_range{4},[0,2,100])
            
            
            assertEqual(transf{1}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertEqual(transf{2}.transf_matrix,[0,0,-1;1,0,0;0,1,0]);
            assertEqual(transf{2}.shift,[0,0,0]);
        end
        
        function test_cut_transf_input_shifts(this)
            %ctr = {cut_transf(0.1,1),cut_transf(0.1,1)};
            cf = @(x)(disp(x)); % any function; does not matter
            % it is not invoked here, just to get it set up
            
            transf = zone_param_parcer([1,1,0],....
                {[-0.5,0.5],[-1.2,0.1,1.2],[-2,0.2,2]},[0,2,100],...
                {[1,1,0],[1,0,-1]},'correct_fun',cf,'symmetry_type','shift');
            assertEqual(numel(transf),2)
            %
            assertElementsAlmostEqual(transf{1}.qh_range,[0.5,1.5])
            assertElementsAlmostEqual(transf{1}.qk_range,[-0.2,0.1,2.2])
            assertElementsAlmostEqual(transf{1}.ql_range,[-2,0.2,2])
            assertElementsAlmostEqual(transf{1}.de_range,[0,2,100])
            %
            assertElementsAlmostEqual(transf{2}.qh_range,[0.5,1.5])
            assertElementsAlmostEqual(transf{2}.qk_range,[-1.2,0.1,1.2])
            assertElementsAlmostEqual(transf{2}.ql_range,[-3,0.2,1])
            assertElementsAlmostEqual(transf{2}.de_range,[0,2,100])
            %
            assertEqual(numel(transf{2}.cut_range),4)
            
            assertElementsAlmostEqual(transf{2}.cut_range{1},[0.5,1.5])
            assertElementsAlmostEqual(transf{2}.cut_range{2},[-1.2,0.1,1.2])
            assertElementsAlmostEqual(transf{2}.cut_range{3},[-3,0.2,1])
            assertElementsAlmostEqual(transf{2}.cut_range{4},[0,2,100])
            
            assertEqual(transf{1}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertEqual(transf{1}.shift,[0,0,0]);
            assertEqual(transf{2}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertEqual([1,1,0],transf{2}.shift+transf{2}.zone_center);
            
        end
        
        function test_cut_transf_input_lists(this)
            %ctr = {cut_transf(0.1,1),cut_transf(0.1,1)};
            
            transf = zone_param_parcer([0,2,0],....
                {[-0.5,0.5],[-1.2,0.1,1.2],[-2,0.2,2]},[0,4,300],...
                {[1,1,0],[1,0,-1]},'symmetry_type','shift');
            assertEqual(numel(transf),3)
            %
            assertElementsAlmostEqual(transf{1}.qh_range,[0.5,1.5])
            assertElementsAlmostEqual(transf{1}.qk_range,[-0.2,0.1,2.2])
            assertElementsAlmostEqual(transf{1}.ql_range,[-2,0.2,2])
            assertElementsAlmostEqual(transf{1}.de_range,[0,4,300])
            %
            assertElementsAlmostEqual(transf{2}.qh_range,[0.5,1.5])
            assertElementsAlmostEqual(transf{2}.qk_range,[-1.2,0.1,1.2])
            assertElementsAlmostEqual(transf{2}.ql_range,[-3,0.2,1])
            assertElementsAlmostEqual(transf{2}.de_range,[0,4,300])
            %
            assertEqual(numel(transf{2}.cut_range),4)
            
            assertEqual(transf{1}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertElementsAlmostEqual(transf{1}.shift,[-1,1,0]);
            assertEqual(transf{2}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertElementsAlmostEqual([0,2,0],transf{2}.shift+transf{2}.zone_center);
            
            cf = @(x)(disp(x)); % any function; does not matter
            % it is not invoked here, just to get it set up
            transf = zone_param_parcer([0,2,0],transf,[],'correct_fun',cf);
            %
            assertElementsAlmostEqual(transf{1}.qh_range,[0.5,1.5])
            assertElementsAlmostEqual(transf{1}.qk_range,[-0.2,0.1,2.2])
            assertElementsAlmostEqual(transf{1}.ql_range,[-2,0.2,2])
            assertElementsAlmostEqual(transf{1}.de_range,[0,4,300])
            %
            assertElementsAlmostEqual(transf{2}.qh_range,[0.5,1.5])
            assertElementsAlmostEqual(transf{2}.qk_range,[-1.2,0.1,1.2])
            assertElementsAlmostEqual(transf{2}.ql_range,[-3,0.2,1])
            assertElementsAlmostEqual(transf{2}.de_range,[0,4,300])
            
            assertEqual(transf{1}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertElementsAlmostEqual([0,2,0],transf{1}.shift+transf{1}.zone_center);
            assertEqual(transf{2}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertElementsAlmostEqual([0,2,0],transf{2}.shift+transf{2}.zone_center);
            assertEqual(transf{1}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            assertElementsAlmostEqual([0,2,0],transf{3}.shift+transf{3}.zone_center);
            assertEqual(transf{3}.transf_matrix,[1,0,0;0,1,0;0,0,1]);
            
            
        end
        
        
    end
end

