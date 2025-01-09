classdef test_unique_objects_2 < TestCase
    properties
        u1
        idx
        u2
        u3
        o2
        o3
    end

    methods
        function obj=test_unique_objects_2(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_unique_objects_2';
            end
            obj = obj@TestCase(name);

            % clear the urc global container for id HHH
            % NB urc == unique_references_container
            unique_obj_store.instance().clear('unique_fields_example_class');

            % create 3 objects of unique_fields_example_class (available in
            % this directory) containing IX_insts with distinguishing
            % names
            ec333 =unique_fields_example_class('333',IX_inst('name','333'));
            ec666 =unique_fields_example_class('666',IX_inst('name','666'));
            ec999 =unique_fields_example_class('999',IX_inst('name','999'));
            % place them in the HHH urc which we create
            u1 = unique_references_container('unique_fields_example_class');

            % add 3 objects to u1. this just makes a container with 3
            % elements we can index - could have used an array or cell
            u1 = u1.add(ec333);
            u1 = u1.add(ec666);
            u1 = u1.add(ec999);
            % store u1 in class for use in tests
            obj.u1 = u1;
            % make a set of indices which can populate 17 elements of aa
            % containers with random-ish distribution of multiple copies of
            % our 3 objects in u1
            obj.idx = [1 2 3 3 2 1 2 2 3 1 1 1 3 3 1 2 2];
            % make anothr urc which can store these
            % unique_fields_example_class objects
            obj.u2 = unique_references_container('unique_fields_example_class');
            % fill it with copies from u1 according to the index values in
            % idx
            for ii=1:numel(obj.idx)
                obj.u2{ii} = u1{ obj.idx(ii) };
            end
            obj.o2 = unique_objects_container('unique_fields_example_class');
            for ii=1:numel(obj.idx)
                obj.o2{ii} = u1{ obj.idx(ii) };
            end

            % repeat the process - ec999 now has the same myfield value as
            % ec333 but ec333 and ec999 differ in the mydisc field so urcs
            % of ec values will differ between these but an urc of their
            % myfield values will have them the same
            ec333 =unique_fields_example_class('333',IX_inst('name','333'));
            ec666 =unique_fields_example_class('666',IX_inst('name','666'));
            ec999 =unique_fields_example_class('999',IX_inst('name','333'));
            u1 = unique_references_container('unique_fields_example_class');
            u1 = u1.add(ec333);
            u1 = u1.add(ec666);
            u1 = u1.add(ec999);
            obj.u1 = u1;
            obj.u3 = unique_references_container('unique_fields_example_class');
            for ii=1:numel(obj.idx)
                obj.u3{ii} = u1{ obj.idx(ii) };
            end
            obj.o3 = unique_objects_container('unique_fields_example_class');
            for ii=1:numel(obj.idx)
                obj.o3{ii} = u1{ obj.idx(ii) };
            end
        end
        function delete(~)
            unique_obj_store.instance().clear('unique_fields_example_class');
        end
        %
        %------------------------------------------------------------------
        function test_contains_object(obj)
            % teest contents of u1
            u1 = obj.u1;
            assertEqual(u1{1}.myfield.name,'333');
            assertEqual(u1{2}.myfield.name,'666');
            assertEqual(u1{3}.myfield.name,'333');

            % test copies of u2 according to the name of its myfield
            % property
            u2 = obj.u2;
            for ii=1:numel(obj.idx)
                name = u2{ii}.myfield.name;
                if obj.idx(ii)==1
                    assertEqual(name,'333');
                elseif obj.idx(ii)==2
                    assertEqual(name,'666');
                elseif obj.idx(ii)==3
                    assertEqual(name,'999');
                else
                    error('HORACE:test_unique_objects_2:bad_test_construction', ...
                        'myfield name should be 333 666 or 999');
                end
            end
        end
        %
    end
end
