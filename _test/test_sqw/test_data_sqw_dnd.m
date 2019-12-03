classdef test_data_sqw_dnd < TestCase
    % Series of tests to check work of mex files against Matlab files
    
    properties
        out_dir=tmp_dir();
        
    end
    
    methods
        function this=test_data_sqw_dnd(varargin)
            if nargin<1
                name = 'test_data_sqw_dnd';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
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
    end
end