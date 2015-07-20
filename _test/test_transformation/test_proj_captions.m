classdef test_proj_captions<TestCase
    % The test class to verify how projection works
    %
    properties
        data
    end
    
    methods
        function this=test_proj_captions(name)
            this=this@TestCase(name);
            %sqw/dnd data structure with fields used in caption
            this.data= data_sqw_dnd();
        end
        function test_cube_caption(this)
            
            capt = an_axis_caption();
            assertTrue(capt.changes_aspect_ratio);
            
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.data);
            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,2]);
            %
            assertTrue(iscell(title_pax));
            assertTrue(isempty(title_pax));
            %
            assertTrue(iscell(title_iax));
            assertEqual(size(title_iax),[4,1]);
            %
            assertTrue(iscell(display_pax));
            assertTrue(isempty(display_pax));
            %
            assertTrue(iscell(display_iax));
            assertEqual(size(display_iax),[4,1]);
            %
            assertEqual(energy_axis,4);
        end
        
        
        function test_spher_caption(this)
            capt = spher_proj_caption();
            assertFalse(capt.changes_aspect_ratio);
            this.data.ulabel={'\ro'  '\theta'  '\phi'  'E'};
            
            [title_main, title_pax, title_iax, display_pax, display_iax, energy_axis]=...
                capt.data_plot_titles(this.data);

            assertTrue(iscell(title_main));
            assertEqual(size(title_main),[1,2]);
            %
            assertTrue(iscell(title_pax));
            assertTrue(isempty(title_pax));
            %
            assertTrue(iscell(title_iax));
            assertEqual(size(title_iax),[4,1]);
            %
            assertTrue(iscell(display_pax));
            assertTrue(isempty(display_pax));
            %
            assertTrue(iscell(display_iax));
            assertEqual(size(display_iax),[4,1]);
            %
            assertEqual(energy_axis,4);
            
        end
    end
end