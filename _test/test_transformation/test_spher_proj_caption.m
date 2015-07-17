classdef test_spher_proj_caption<TestCase
    % The test class to verify how projection works
    %
    properties
        data
    end
    
    methods
        function this=test_spher_proj_caption(name)
            this=this@TestCase(name);
            %sqw/dnd data structure with fields used in caption
            this.data= struct('filename','_a_file','filepath','_a_path',...
                'title','_a_titile',...
                'alatt',[3.3,3.3,3.3],...
                'angdeg',[90,90,90], 'uoffset',[],...
                'u_to_rlu',eye(3),'ulen',[], 'ulabel',[],...
                'iax',[], 'iint',[], 'pax',[],'p',[],'dax',[], 's',[],'e',[],...
                'npix',[],'urange',[],'pix',[],'axis_caption',[]);
        end
        function xtest_cube_caption(this)
            
            capt = an_axis_caption();
            assertTrue(capt.changes_aspect_ratio);
            
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.data);
            
            
        end
        
        
        function xtest_spher_caption(this)
            
            capt = spher_proj_caption();
            assertFalse(capt.changes_aspect_ratio);
            
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.data);
            
        end
    end
end