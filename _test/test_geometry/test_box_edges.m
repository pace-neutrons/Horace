classdef test_box_edges < TestCase
    %
    properties
        rot2D = @(theta)([cosd(theta),-sind(theta);sind(theta),cosd(theta)])
        rot3Dz = @(theta)([cosd(theta),-sind(theta),0;...
            sind(theta),cosd(theta),0;...
            0,0,1])
        rot4Dz = @(theta)([cosd(theta),-sind(theta),0,0;...
            sind(theta),cosd(theta),0,0;...
            0,0,1,0;...
            0,0,0,1])
        
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
        function test_edges4D_build_from_expanded_nodes(obj)
            box = [-ones(1,4)/sqrt(2);ones(1,4)/sqrt(2)]';
            box = expand_box(box(:,1),box(:,2));
            box = obj.rot4Dz(-45)*box;
            
            [~,edge_pts] = get_geometry(4);
            assertEqual(size(edge_pts,2),4*16/2)
            sq2 = sqrt(2)/2;
            % test imcomplete. TODO: finish it
            ref_edges = {...
                [-1,0,-sq2,-sq2;0,-1,-sq2,-sq2]',[-1,0,-sq2,-sq2;0,1,-sq2,-sq2]'};
            for i=1:numel(ref_edges)
                edge = edge4D(box,edge_pts(:,i));
                assertElementsAlmostEqual(ref_edges{i},edge,...
                    sprintf('edge N:%d mismutch',i));
            end
        end
        
        function test_edges4D_generated_in_selected_order(~)
            box = [zeros(1,4);ones(1,4)]';
            %
            [~,edge_pts] = get_geometry(4);
            assertEqual(size(edge_pts,2),4*16/2)
            % test imcomplete. TODO: finish it
            ref_edges = {...
                [0,0,0,0;1,0,0,0]',[0,0,0,0;0,1,0,0]',...
                [1,0,0,0;1,1,0,0]',[0,1,0,0;1,1,0,0]'};
            
            for i=1:numel(ref_edges)
                edge = edge4D(box,edge_pts(:,i));
                assertElementsAlmostEqual(ref_edges{i},edge,...
                    sprintf('edge N:%d mismutch',i));
            end
        end
        %
        function test_edges4D_throw_invalid_arguments(~)
            box = [zeros(1,4);ones(1,4);ones(1,4)]';
            [~,edge_pts] = get_geometry(4);
            assertExceptionThrown(@()edge4D(box,edge_pts(:,1)),...
                'HERBERT:geometry:invalid_argument');
        end
        %--------------------------------------------------------------------------
        function test_edges3D_throw_invalid_arguments(~)
            box = [zeros(1,3);ones(1,3);ones(1,3)]';
            [~,edge_pts] = get_geometry(3);
            assertExceptionThrown(@()edge3D(box,edge_pts(:,1)),...
                'HERBERT:geometry:invalid_argument');
        end
        %
        function test_edges3D_build_from_expanded_nodes(obj)
            box = [-ones(1,3)/sqrt(2);ones(1,3)/sqrt(2)]';
            box = expand_box(box(:,1),box(:,2));
            box = obj.rot3Dz(-45)*box;
            
            [~,edge_pts] = get_geometry(3);
            assertEqual(size(edge_pts,2),3*8/2)
            sq2 = sqrt(2)/2;
            %ref_edges = {[-1,0;0,-1]',[-1,0;0,1]',[0,-1;1,0]',[0,1;1,0]'};
            ref_edges = {...
                [-1,0,-sq2;0,-1,-sq2]',[-1,0,-sq2;0,1,-sq2]',[0,-1,-sq2;1,0,-sq2]',[0,1,-sq2;1,0,-sq2]',...
                [-1,0,-sq2;-1,0,sq2]',[0,-1,-sq2;0,-1,sq2]',[-1,0,sq2,;0,-1,sq2]',[0,1,-sq2;0,1,sq2]',...
                [-1,0,sq2;0,1,sq2]',[1,0,-sq2;1,0,sq2]',[0,-1,sq2;1,0,sq2]',[0,1,sq2;1,0,sq2]'};
            for i=1:size(edge_pts,2)
                edge = edge3D(box,edge_pts(:,i));
                assertElementsAlmostEqual(ref_edges{i},edge,...
                    sprintf('edge N:%d mismutch',i));
            end
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
                assertElementsAlmostEqual(ref_edges{i},edge,sprintf(' Edge %d mismatch',i));
            end
        end
        %--------------------------------------------------------------------------
        function test_edges2D_build_from_expanded_nodes(obj)
            box = [-ones(1,2)/sqrt(2);ones(1,2)/sqrt(2)]';
            box = expand_box(box(:,1),box(:,2));
            box = obj.rot2D(-45)*box;
            %box = [-1,0;0,-1;0,1;1,0]';
            
            [~,edge_pts] = get_geometry(2);
            assertEqual(size(edge_pts,2),2*4/2)
            ref_edges = {[-1,0;0,-1]',[-1,0;0,1]',[0,-1;1,0]',[0,1;1,0]'};
            for i=1:size(edge_pts,2)
                edge = edge2D(box,edge_pts(:,i));
                assertElementsAlmostEqual(ref_edges{i},edge);
            end
        end
        function test_edges2D_throw_invalid_arguments(~)
            box = [zeros(1,2);ones(1,2);ones(1,2)]';
            [~,edge_pts] = get_geometry(2);
            assertExceptionThrown(@()edge2D(box,edge_pts(:,1)),...
                'HERBERT:geometry:invalid_argument');
        end
        %
        function test_edges2D_generated_in_selected_order(~)
            box = [zeros(1,2);ones(1,2)]';
            [~,edge_pts] = get_geometry(2);
            assertEqual(size(edge_pts,2),2*4/2)
            ref_edges = {[0,0;1,0]',[0,0;0,1]',[1,0;1,1]',[0,1;1,1]'};
            for i=1:size(edge_pts,2)
                edge = edge2D(box,edge_pts(:,i));
                assertElementsAlmostEqual(ref_edges{i},edge);
            end
        end
        %--------------------------------------------------------------------------
    end
end
