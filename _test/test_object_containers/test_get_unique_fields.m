classdef test_get_unique_fields < TestCase
    % tests use of get-unique_field for unique_references_container

    % something with absiolutely unclear purpose.
    %
    properties
        IX_inst_stor
    end
    methods

        function obj = test_get_unique_fields(name)
            obj = obj@TestCase(name);
            obj.IX_inst_stor =  unique_obj_store.instance().get_objects('IX_inst');
            unique_obj_store.instance().clear('IX_inst');
        end

        function test_get_unique_fields_1(~)

            a = unique_fields_example_class('333',IX_inst('name','333'));
            b = unique_fields_example_class('666',IX_inst('name','666'));
            u1 = unique_references_container('unique_fields_example_class');
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

            % Why would you want this? Especially using unique references
            % container
            u2 = u1.get_unique_field('myfield');
            assertEqual(u2.n_runs, 3);
            assertTrue( isa(u2{1}, 'IX_inst'));
            assertTrue( strcmp(u2{3}.name, '666') );
        end
        function delete(obj)
            % avoid side effects from this test
            unique_obj_store.instance().clear('unique_fields_example_class');
            unique_obj_store.instance().clear('IX_inst');
            unique_obj_store.instance().set_objects(obj.IX_inst_stor);
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
            glc = unique_obj_store.instance().get_objects(urc.baseclass);


            poss_field_values = unique_references_container(cls);
            for ii=1:numel(uix)
                sii = glc( uix(ii) );

                v = sii.('myfield');
                poss_field_values = poss_field_values.add(v);
            end

        end

    end
end