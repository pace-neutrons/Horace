classdef test_fig_spread < TestCase
    % Unit tests to check pic_spread class
    
    properties
        n_pic = 3;
    end
    
    methods
        function ps = test_fig_spread(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = 'test_pic_spread';
            end
            ps = ps@TestCase(name);
        end
        function pl = gen_pic(obj)
            pl = cell(obj.n_pic);
            for i=1:obj.n_pic
                pl{i} = figure('Name',sprintf('test_fig_handle#%d',i));
                hold on;
            end
        end
        function test_default_operations(obj)
            ps = fig_spread();
            figs = obj.gen_pic;
            for i=1:obj.n_pic
                ps = ps.place_pic(figs{i});
            end
            ps = fig_spread();
            for i=1:obj.n_pic
                ps = ps.place_pic(figs{i},'-rise');
            end
            ps = ps.hide_n_pic();
            ps = ps.show_n_pic();
            
            
            ps = ps.hide_n_pic(1);
            ps = ps.hide_n_pic(3);
            ps = ps.show_n_pic(2);
            ps = ps.show_n_pic();
            
            
            fh = ps.get_pic_handles();
            close(fh{2});
            
            valid = ps.get_valid_ind();
            assertEqual(valid,logical([1,0,1]));
            
            clOb = onCleanup(@()ps.close_all());
        end
        
        function test_pic_pos(obj)
            ps = fig_spread();
            ss= get(0,'ScreenSize');
            
            pic_size = ps.pic_size;
            size_x=pic_size(1);
            size_y=pic_size(2);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(1,size_x,size_y);
            assertEqual(ix,ps.left_border);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            [ix,iy,n_frame] = ps.calc_fig_pos(2,size_x,size_y);
            assertEqual(ix,ps.left_border+size_x);
            assertEqual(iy,ss(4)-ps.top_border-size_y);
            assertEqual(n_frame,0);
            
            sc = ps.screen_capacity_npic;
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
            ps.pic_size = [size_x,size_y];
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

