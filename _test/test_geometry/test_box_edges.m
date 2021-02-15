classdef test_box_edges < TestCase
    %
    properties
    end
    
    methods
        %--------------------------------------------------------------------------
        function self = test_box_edges(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_box_edges';
            end
            self = self@TestCase(name);
        end
        
        %--------------------------------------------------------------------------
        function test_edges4D_generated_in_selected_order(~)
            %box = [zeros(1,4);ones(1,4)]';
            [~,edge_pts] = get_geometry(4);
            assertEqual(size(edge_pts,2),4*16/2)
            % test imcomplete. TODO: finish it
            %
            %             ref_edges = {...
            %                 [0,0,0;1,0,0]',[0,0,0;0,1,0]',[1,0,0;1,1,0]',...
            %                 [0,1,0;1,1,0]',[0,0,0;0,0,1]',[1,0,0;1,0,1]',...
            %                 [0,0,1;1,0,1]',[0,1,0;0,1,1]',[0,0,1;0,1,1]',...
            %                 [1,1,0;1,1,1]',[1,0,1;1,1,1]',[0,1,1;1,1,1]'};
            %             for i=1:size(edge_pts,2)
            %                 edge = edge3D(box,edge_pts(:,i));
            %                 assertEqual(ref_edges{i},edge,sprintf(' Edge %d mismatch',i));
            %             end
        end
        %
        function test_edges3D_generated_in_selected_order(~)
            box = [zeros(1,3);ones(1,3)]';
            [~,edge_pts] = get_geometry(3);
            assertEqual(size(edge_pts,2),3*8/2)
            ref_edges = {...
                [0,0,0;1,0,0]',[0,0,0;0,1,0]',[1,0,0;1,1,0]',...
                [0,1,0;1,1,0]',[0,0,0;0,0,1]',[1,0,0;1,0,1]',...
                [0,0,1;1,0,1]',[0,1,0;0,1,1]',[0,0,1;0,1,1]',...
                [1,1,0;1,1,1]',[1,0,1;1,1,1]',[0,1,1;1,1,1]'};
            for i=1:size(edge_pts,2)
                edge = edge3D(box,edge_pts(:,i));
                assertEqual(ref_edges{i},edge,sprintf(' Edge %d mismatch',i));
            end
        end
        %
        function test_edges2D_generated_in_selected_order(~)
            box = [zeros(1,2);ones(1,2)]';
            [~,edge_pts] = get_geometry(2);
            assertEqual(size(edge_pts,2),2*4/2)
            ref_edges = {[0,0;1,0]',[0,0;0,1]',[1,0;1,1]',[0,1;1,1]'};
            for i=1:size(edge_pts,2)
                edge = edge2D(box,edge_pts(:,i));
                assertEqual(ref_edges{i},edge);
            end
        end
        
        %--------------------------------------------------------------------------
        %--------------------------------------------------------------------------
    end
end
