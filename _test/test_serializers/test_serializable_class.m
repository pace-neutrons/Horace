classdef test_serializable_class < TestCase
    properties
        wk_dir = tmp_dir()
    end
    methods
        
        function obj = test_serializable_class(name)
            if ~exist('name', 'var')
                name = 'test_serializable_class ';
            end
            obj = obj@TestCase(name);
        end
        function test_new_version_saveobj_loadobj_array_recursive(~)
            % prepare reference data
            tc = serializableTester2();
            tc = repmat(tc,2,2);
            tc2 = serializableTester1();
            for i=1:numel(tc)
                tc(i).Prop_level2_1 = i*10;
                tc(i).Prop_level2_2 = repmat(tc2,1,2*i);
            end
            % prepara data to store
            tc_struct = saveobj(tc);
            
            % modify the class version assuming new class version appeared
            ver = serializableTester2.version_holder();
            serializableTester2.version_holder(ver+1);
            
            % recover data stored as old version using new version class
            tc_rec = serializableTester2.loadobj(tc_struct);
            % check successful recovery
            assertEqual(size(tc_rec),size(tc));
            for i=1:numel(tc)
                assertEqual(tc(i),tc_rec(i));
            end
        end
        function test_serialize_classes_array_recursive(~)
            tc = serializableTester1();
            tc = repmat(tc,2,2);
            tc2 = serializableTester2();
            for i=1:numel(tc)
                tc(i).Prop_level1_1 = i*10;
                tc(i).Prop_level1_2 = repmat(tc2,1,2*i);
            end
            
            tc_bytes = tc.serialize();
            tc_size  = tc.serial_size();
            assertEqual(numel(tc_bytes),tc_size);
            
            [tc_rec,nbytes] = serializable.deserialize(tc_bytes);
            
            assertEqual(size(tc_rec),size(tc));
            assertEqual(tc_size,nbytes);
            for i=1:numel(tc)
                assertEqual(tc(i),tc_rec(i));
                assertEqual(class(tc(i)),class(tc_rec(i)));
                assertEqual(class(tc(i).Prop_level1_2),...
                    class(tc_rec(i).Prop_level1_2));
            end
        end
        
        
        function test_to_from_to_struct_classes_array_recursive(~)
            tc = serializableTester1();
            tc = repmat(tc,2,2);
            tc2 = serializableTester2();
            for i=1:numel(tc)
                tc(i).Prop_level1_1 = i*10;
                tc(i).Prop_level1_2 = repmat(tc2,1,2*i);
            end
            tc_struct = to_struct(tc);
            
            tc_rec = serializable.from_struct(tc_struct);
            assertEqual(size(tc_rec),size(tc));
            for i=1:numel(tc)
                assertEqual(tc(i),tc_rec(i));
            end
        end
        
        function test_save_load_single_class(obj)
            tc = serializableTester1();
            tc.Prop_level1_1 = 20;
            tc.Prop_level1_2 = cell(1,10);
            test_file = fullfile(obj.wk_dir,'test_serializable_single_class.mat');
            clob = onCleanup(@()delete(test_file));
            save(test_file,'tc');
            ld_dat = load(test_file);
            
            assertEqual(tc,ld_dat.tc);
        end
        
        function test_saveobj_loadobj_single_class(~)
            tc = serializableTester1();
            tc.Prop_level1_1 = 20;
            tc.Prop_level1_2 = cell(1,10);
            tc_struct = saveobj(tc);
            
            tc_rec = serializableTester1.loadobj(tc_struct);
            assertEqual(tc,tc_rec);
        end
        
        function test_serialize_classes_array(~)
            tc = serializableTester1();
            tc = repmat(tc,2,2);
            for i=1:numel(tc)
                tc(i).Prop_level1_1 = i*10;
                tc(i).Prop_level1_2 = cell(1,2*i);
            end
            
            tc_bytes = tc.serialize();
            tc_size  = tc.serial_size();
            assertEqual(numel(tc_bytes),tc_size);
            
            [tc_rec,nbytes] = serializable.deserialize(tc_bytes);
            assertEqual(tc,tc_rec);
            assertEqual(tc_size,nbytes);
        end
        
        function test_to_from_to_struct_classes_array(~)
            tc = serializableTester1();
            tc = repmat(tc,2,2);
            for i=1:numel(tc)
                tc(i).Prop_level1_1 = i*10;
                tc(i).Prop_level1_2 = cell(1,2*i);
            end
            tc_struct = to_struct(tc);
            
            tc_rec = serializable.from_struct(tc_struct);
            assertEqual(size(tc_rec),size(tc));
            for i=1:numel(tc)
                assertEqual(tc(i),tc_rec(i));
            end
        end
        function test_serialize_native_single_class(~)
            tc = serializableTester1();
            tc.Prop_level1_1 = 20;
            tc.Prop_level1_2 = cell(1,10);
            
            tc_bytes = tc.serialize();
            tc_size  = tc.serial_size();
            assertEqual(numel(tc_bytes),tc_size);
            
            [tc_rec,nbytes] = serializable.deserialize(tc_bytes);
            assertEqual(tc,tc_rec);
            assertEqual(tc_size,nbytes);
        end
        
        function test_to_from_to_struct_single_class(~)
            tc = serializableTester1();
            tc.Prop_level1_1 = 20;
            tc.Prop_level1_2 = cell(1,10);
            tc_struct = to_struct(tc);
            
            tc_rec = serializable.from_struct(tc_struct);
            assertEqual(tc,tc_rec);
        end
    end
end
