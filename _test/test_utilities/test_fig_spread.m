classdef test_fig_spread < TestCase
    % Unit tests to check fig_spread class
    
    properties
        n_fig = 3;
    end
    
    methods
        function ps = test_fig_spread(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_fig_spread';
            end
            ps = ps@TestCase(name);
        end
        function pl = gen_fig(obj)
            pl = cell(obj.n_fig);
            for i=1:obj.n_fig
                pl{i} = figure('Name',sprintf('test_fig_handle#%d',i));
                hold on;
            end
        end
        function test_default_operations(obj)
            ps = fig_spread();
            figs = obj.gen_fig;
            for i=1:obj.n_fig
                ps = ps.place_fig(figs{i});
            end
            ps = fig_spread();
            for i=1:obj.n_fig
                ps = ps.place_fig(figs{i},'-rise');
            end
            ps = ps.hide_n_fig();
            ps = ps.show_n_fig();
            
            
            ps = ps.hide_n_fig(1);
            ps = ps.hide_n_fig(3);
            ps = ps.show_n_fig(2);
            ps = ps.show_n_fig();
            
            
            fh = ps.get_fig_handles();
            close(fh{2});
            
            ps = ps.replot_figs();
            
            valid = ps.get_valid_ind();
            assertEqual(valid,logical([1,0,1]));
            
            clOb = onCleanup(@()ps.close_all());
        end
        
        function test_fig_pos(obj)
            ps = fig_spread();
            ss= get(0,'ScreenSize');
            
            fig_size = ps.fig_size;
            size_x=fig_size(1);
            size_y=fig_size(2);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(2,size_x,size_y);
            assertEqual(ix,ps.left_border+size_x);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            sc = ps.screen_capacity_nfig;
            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1),size_x,size_y);
            assertEqual(ix,ps.left_border+size_x*(sc(1)-1));
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1)+1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-2*size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1)*sc(2),size_x,size_y);
            assertEqual(ix,ps.left_border+size_x*(sc(1)-1));
            assertEqual(iy,ss(4)-ps.top_border-size_y*sc(2));
            assertEqual(n_frame,0);

            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1)*sc(2)+1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,1);
            

            %-------------------------------------------------------------
            size_x=size_x+10;            
            size_y=size_y+10;
            ps.fig_size = [size_x,size_y];
            sc(1) = sc(1) -1;
            sc(2) = sc(2) -1;            
            
            [ix,iy,n_frame] = ps.calc_fig_pos(1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(2,size_x,size_y);
            assertEqual(ix,ps.left_border+size_x);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1),size_x,size_y);
            assertEqual(ix,ps.left_border+size_x*(sc(1)-1));
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1)+1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-2*size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1)*sc(2),size_x,size_y);
            assertEqual(ix,ps.left_border+size_x*(sc(1)-1));
            assertEqual(iy,ss(4)-ps.top_border-size_y*sc(2));
            assertEqual(n_frame,0);

            [ix,iy,n_frame] = ps.calc_fig_pos(sc(1)*sc(2)+1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,1);                        
        end
    end
    
end

