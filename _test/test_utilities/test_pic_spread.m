classdef test_pic_spread < TestCase
    % Unit tests to check pic_spread class
    
    properties
        n_pic = 3;
    end
    
    methods
        function ps = test_pic_spread(varargin)
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
            ps = pic_spread();
            figs = obj.gen_pic;
            for i=1:obj.n_pic
                ps = ps.place_pic(figs{i});
            end
            ps = pic_spread();
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
    end    
    
end

