classdef test_get_unique_fields < TestCase
    % tests use of get-unique_field for unique_references_container
    
    methods
        
        function obj = test_get_unique_fields(name)
            obj = obj@TestCase(name);
        end
        
        function test_get_unique_fields_1(~)
            a = unique_fields_example_class('333',IX_inst('name','333'));
            b = unique_fields_example_class('666',IX_inst('name','666'));
            u1 = unique_references_container('HHH','unique_fields_example_class');
            u1 = u1.add(a);
            u1 = u1.add(a);
            u1 = u1.add(b);

            assertTrue( strcmp('333',u1{1}.myfield.name ));
            assertTrue( strcmp('333',u1{2}.myfield.name ));
            assertTrue( strcmp('666',u1{3}.myfield.name ));
            assertEqual( u1.n_runs, 3 );

            u3 = test_get_unique_fields.bing(u1);
            assertTrue( isa( u3{1}, 'IX_inst') );
            assertTrue( strcmp(u3{1}.name, '333') );
            assertEqual( u3.n_runs, 2 );
            
            u2 = u1.get_unique_field('myfield');
            assertEqual(u2.n_runs, 3);
            assertTrue( isa(u2{1}, 'IX_inst'));
            assertTrue( strcmp(u3{2}.name, '666') );            
        end
    end

    methods(Static)
        function poss_field_values = bing(urc)
            % partial implementation of urc.get_unique_fields which only
            % goes as far as extracting the unique fields rather than the
            % multiple instances which map to the original urc
            s1=urc.get(1);
            v=s1.('myfield');
            cls = class(v);

            uix = unique( urc.idx_, 'stable' );
            glc = urc.global_container('value', urc.global_name_);
            urc.global_container('CLEAR','HHH_IX_inst');

            poss_field_values = unique_references_container(['HHH_',cls],cls);
            for ii=1:numel(uix)
                sii = glc( uix(ii) );

                v = sii.('myfield');
                [poss_field_values,nuix] = poss_field_values.add_single_(v);
            end

        end
         
    end
end