classdef test_aProjection_methods <TestCase
    % The test class to verify how projection works
    %
    properties
    end
    
    methods
        function this=test_aProjection_methods(varargin)
            if nargin == 0
                name = 'test_aProjection_methods';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        %------------------------------------------------------------------
        function test_set_label_type_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.label= [200,10,10];
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        function test_serialize_deserialize(~)
            ap = aProjectionTester();
            ser_str = ap.serialize();
            ap_rec = serializable.deserialize(ser_str);
            
            assertEqual(ap,ap_rec);
        end
        function test_constructor_some_fields_and_extra_throws(~)
            par = {'offset', [1,0,0,0],'lab2','b','extra','blabla','extra1_no_value'};
            assertExceptionThrown(@()aProjectionTester(par{:}),...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_constructor_some_fields_and_extra(~)
            par = {'offset', [1,0,0,0],'lab2','b','extra','blabla','extra1','cryacrya'};
            [ap,extra_par] =aProjectionTester(par{:});
            assertEqual(ap.label ,{'Q_h','b','Q_l','En'});
            assertEqual(ap.offset ,[1,0,0,0]);
            assertEqual(extra_par,{'extra','blabla','extra1','cryacrya'});
        end
        
        function test_constructor_all_fields(~)
            par = {'offset', [1,0,0,0],'label',{'a','b','c','d'}};
            [ap,extra_par] =aProjectionTester(par{:});
            assertEqual(ap.label ,{'a','b','c','d'});
            assertEqual(ap.offset ,[1,0,0,0]);
            assertTrue(isempty(extra_par));
        end
        
        function test_default_set_single_label(~)
            ap = aProjectionTester();
            assertEqual(ap.label ,{'Q_h', 'Q_k', 'Q_l', 'En'});
            ap.label{3} = 'e';
            assertEqual(ap.label ,{'Q_h', 'Q_k', 'e', 'En'});
        end
        
        function test_set_labels_col(~)
            ap = aProjectionTester();
            ap.label = {'a';'b';'c';'d'};
            assertEqual(ap.label ,{'a','b','c','d'});
        end
        function test_set_labels_row(~)
            ap = aProjectionTester();
            ap.label = {'a','b','c','d'};
            assertEqual(ap.label ,{'a','b','c','d'});
        end
        
        %------------------------------------------------------------------
        function test_set_angdeg_large_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.angdeg= [200,10,10];
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_angdeg_zero_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.angdeg= 0;
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_angdeg_empty_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.angdeg= [];
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_angdeg_matrix_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.angdeg= 40*ones(3);
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_angdeg_col(~)
            ap = aProjectionTester();
            ap.angdeg = [30;60;90];
            assertEqual(ap.angdeg,[30,60,90]);
        end
        
        function test_set_angdeg_row(~)
            ap = aProjectionTester();
            ap.angdeg = [70,30,80];
            assertEqual(ap.angdeg,[70,30,80]);
        end
        
        function test_set_angdeg_1elem(~)
            ap = aProjectionTester();
            ap.angdeg = 90;
            assertEqual(ap.angdeg,[90,90,90]);
        end
        %------------------------------------------------------------------
        function test_set_lattice_zero_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.alatt= 0;
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_lattice_empty_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.alatt= [];
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_lattice_matrix_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.alatt= ones(3);
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_lattice_col(~)
            ap = aProjectionTester();
            ap.alatt = [3;3;3];
            assertEqual(ap.alatt,[3,3,3]);
        end
        
        function test_set_lattice_row(~)
            ap = aProjectionTester();
            ap.alatt = [3,3,3];
            assertEqual(ap.alatt,[3,3,3]);
        end
        
        function test_set_lattice_1elem(~)
            ap = aProjectionTester();
            ap.alatt = 3;
            assertEqual(ap.alatt,[3,3,3]);
        end
        %------------------------------------------------------------------
        function test_offset_matrix_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.offset = ones(3);
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_offset_nonnum_throws(~)
            ap = aProjectionTester();
            function sap()
                ap.offset = 'a';
            end
            assertExceptionThrown(@sap,...
                'HORACE:aProjection:invalid_argument');
        end
        function test_set_offset_one_member_noz(~)
            ap = aProjectionTester();
            ap.offset = 1;
            assertEqual(ap.offset,[1,1,1,1]);
        end
        
        function test_set_offset_one_member(~)
            ap = aProjectionTester();
            ap.offset = 0;
            assertEqual(ap.offset,[0,0,0,0]);
        end
        
        function test_set_offset_col(~)
            ap = aProjectionTester();
            ap.offset = [1;1.e-13;1.e-13;1.e-13];
            assertEqual(ap.offset,[1,0,0,0]);
        end
        
        function test_set_offset_row(~)
            ap = aProjectionTester();
            ap.offset = [1,0,0,0];
            assertEqual(ap.offset,[1,0,0,0]);
        end
        
        function test_set_offset_empty_char(~)
            ap = aProjectionTester();
            ap.offset = '';
            assertEqual(ap.offset,[0,0,0,0]);
        end
        
        function test_set_offset_one_empty(~)
            ap = aProjectionTester();
            ap.offset = [];
            assertEqual(ap.offset,[0,0,0,0]);
        end
        function test_set_throws_wrong_numel(~)
            ap = aProjectionTester();
            assertFalse(ap.do_generic);
            
            function setter()
                ap.do_generic = [1,10];
            end
            assertExceptionThrown(@setter,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_throws_wrong_type(~)
            ap = aProjectionTester();
            assertFalse(ap.do_generic);
            
            function setter()
                ap.do_generic = 'b';
            end
            assertExceptionThrown(@setter,...
                'HORACE:aProjection:invalid_argument');
        end
        
        function test_set_get_generic(~)
            ap = aProjectionTester();
            assertFalse(ap.do_generic);
            
            ap.do_generic = true;
            assertTrue(ap.do_generic);
        end
    end
end
