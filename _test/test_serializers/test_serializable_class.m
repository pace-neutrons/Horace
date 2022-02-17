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
        %
        function test_ser_serializeble_obj_array_class2(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            setCl2 = serializableTester2();
            setCl2.Prop_class2_1 = 10;
            setCl2.Prop_class2_2 = 20;
            for i=1:numel(serCl)
                serCl(i).Prop_class1_1 = i*10;
                serCl(i).Prop_class1_2 = repmat(setCl2,1,2*i);
            end
            %--------------------------------------------------------------
            % Serialize using Matlab
            ser =  hlp_serialise(serCl);
            serCl_rec = hlp_deserialise(ser);

            assertEqual(serCl, serCl_rec)

            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));
            %--------------------------------------------------------------
            % Serialize using C++
            skipTest('C++ serializers crashes over arrays of objects #394')
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj_array');
            end
            ser_c     = c_serialise(serCl);
            serCl_rec = c_deserialise(ser_c);

            assertEqual(serCl, serCl_rec)
            assertEqual(ser_c,ser);

            size_c = c_serial_size(serCl);
            assertEqual(size_c,numel(ser));
        end
        %
        function test_ser_serializeble_obj_array_class1_obj_class2(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            for i=1:numel(serCl)
                setCl2 = serializableTester2();
                setCl2.Prop_class2_1 = 5*i;
                setCl2.Prop_class2_2 = 20*i;
                serCl(i).Prop_class1_1 = i*10;
                serCl(i).Prop_class1_2 =setCl2;
            end
            %--------------------------------------------------------------
            % Serialize using Matlab
            ser =  hlp_serialise(serCl);
            serCl_rec = hlp_deserialise(ser);

            assertEqual(serCl, serCl_rec)

            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));
            %--------------------------------------------------------------
            % Serialize using C++
            skipTest('C++ serializers crashes over arrays of objects #394')
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj_array');
            end
            ser_c     = c_serialise(serCl);
            serCl_rec = c_deserialise(ser_c);

            assertEqual(serCl, serCl_rec)
            assertEqual(ser_c,ser);

            size_c = c_serial_size(serCl);
            assertEqual(size_c,numel(ser));
        end

        function test_ser_serializeble_obj_array_class1(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            for i=1:numel(serCl)
                serCl(i).Prop_class1_1 = i*10;
                serCl(i).Prop_class1_2 = cell(1,i);
            end
            %--------------------------------------------------------------
            % Serialize using Matlab
            ser =  hlp_serialise(serCl);
            serCl_rec = hlp_deserialise(ser);

            assertEqual(serCl, serCl_rec)

            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));
            %--------------------------------------------------------------
            % Serialize using C++

            skipTest('C++ serializers crashes over arrays of objects #394')
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj_array');
            end
            size_c = c_serial_size(serCl);
            assertEqual(size_c,size);

            ser_c     = c_serialise(serCl);
            assertEqual(ser,ser_c);
            %
            serCl_rec = c_deserialise(ser_c);

            assertEqual(serCl, serCl_rec)
            assertEqual(ser_c,ser);

            size_c = c_serial_size(serCl);
            assertEqual(size_c,numel(ser));
        end
        %
        function test_ser_serializeble_obj(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= serializableTester1();

            %--------------------------------------------------------------

            ser =  hlp_serialise(serCl);
            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));
            [cerCl_rec,nbytes] = hlp_deserialise(ser);

            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, cerCl_rec)
            assertTrue(isa(cerCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));


            skipTest('C++ deserializer does not work propertly; #394')
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj');
            end
            %--------------------------------------------------------------
            % Serialize using C++
            size_c = c_serial_size(serCl);

            ser_c     = c_serialise(serCl);
            assertEqual(ser_c,ser)

            [serCl_rec,nbytes] = c_deserialise(ser_c);

            %
            assertEqual(nbytes,numel(ser_c))
            assertEqual(serCl, serCl_rec)
            assertTrue(isa(cerCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));
            assertEqual(ser_c,ser);

            assertEqual(size_c,numel(ser));
        end
        %
        function test_ser_serializeble_obj_level0(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= [1,2,4];

            %--------------------------------------------------------------

            ser =  hlp_serialise(serCl);
            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));

            [cerCl_rec,nbytes] = hlp_deserialise(ser);

            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, cerCl_rec)
            assertTrue(isa(cerCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));


            skipTest('C++ deserializer does not work propertly; #394')
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj');
            end
            %--------------------------------------------------------------
            % Serialize using C++
            size_c = c_serial_size(serCl);

            ser_c     = c_serialise(serCl);
            assertEqual(ser_c,ser)

            [serCl_rec,nbytes] = c_deserialise(ser_c);

            %
            assertEqual(nbytes,numel(ser_c))
            assertEqual(serCl, serCl_rec)
            assertTrue(isa(cerCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));
            assertEqual(ser_c,ser);

            assertEqual(size_c,numel(ser));
        end
        function test_saveobj_old_version_loadobj_new_version(~)
            % prepare reference data
            tc = serializableTester2();
            tc2 = serializableTester1();
            % we have old version object
            tc2.ver_holder(1);
            assertEqual(tc2.classVersion(),1);

            tc.Prop_class2_1 = 10;
            tc.Prop_class2_2 = repmat(tc2,1,2);

            % store old verision object on level 2
            tc_struct = saveobj(tc);

            % now we have rebuild the object to have new version
            tc2.ver_holder(2);
            % recover data stored as old version using new version class
            tc_rec = serializableTester2.loadobj(tc_struct);
            % check successful recovery

            tc2_lev2 = tc_rec.Prop_class2_2;

            assertEqual(tc2_lev2(1).classVersion(),2);
            assertEqual(tc2_lev2(1).Prop_class1_3,'recovered_new_from_old_value');

            assertEqual(tc2_lev2(2).classVersion(),2);
            assertEqual(tc2_lev2(2).Prop_class1_3,'recovered_new_from_old_value');
            %
        end

        %
        function test_new_version_saveobj_loadobj_array_recursive(~)
            % prepare reference data
            tc = serializableTester2();
            tc = repmat(tc,2,2);
            tc2 = serializableTester1();
            for i=1:numel(tc)
                tc(i).Prop_class2_1 = i*10;
                tc(i).Prop_class2_2 = repmat(tc2,1,2*i);
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
                tc(i).Prop_class1_1 = i*10;
                tc(i).Prop_class1_2 = repmat(tc2,1,2*i);
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
                assertEqual(class(tc(i).Prop_class1_2),...
                    class(tc_rec(i).Prop_class1_2));
            end
        end


        function test_to_from_to_struct_classes_array_recursive(~)
            tc = serializableTester1();
            tc = repmat(tc,2,2);
            tc2 = serializableTester2();
            for i=1:numel(tc)
                tc(i).Prop_class1_1 = i*10;
                tc(i).Prop_class1_2 = repmat(tc2,1,2*i);
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
            tc.Prop_class1_1 = 20;
            tc.Prop_class1_2 = cell(1,10);
            test_file = fullfile(obj.wk_dir,'test_serializable_single_class.mat');
            clob = onCleanup(@()delete(test_file));
            save(test_file,'tc');
            ld_dat = load(test_file);

            assertEqual(tc,ld_dat.tc);
        end

        function test_saveobj_loadobj_single_class(~)
            tc = serializableTester1();
            tc.Prop_class1_1 = 20;
            tc.Prop_class1_2 = cell(1,10);
            tc_struct = saveobj(tc);

            tc_rec = serializableTester1.loadobj(tc_struct);
            assertEqual(tc,tc_rec);
        end

        function test_serialize_classes_array(~)
            tc = serializableTester1();
            tc = repmat(tc,2,2);
            for i=1:numel(tc)
                tc(i).Prop_class1_1 = i*10;
                tc(i).Prop_class1_2 = cell(1,2*i);
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
                tc(i).Prop_class1_1 = i*10;
                tc(i).Prop_class1_2 = cell(1,2*i);
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
            tc.Prop_class1_1 = 20;
            tc.Prop_class1_2 = cell(1,10);

            tc_bytes = tc.serialize();
            tc_size  = tc.serial_size();
            assertEqual(numel(tc_bytes),tc_size);

            [tc_rec,nbytes] = serializable.deserialize(tc_bytes);
            assertEqual(tc,tc_rec);
            assertEqual(tc_size,nbytes);
        end

        function test_to_from_to_struct_single_class(~)
            tc = serializableTester1();
            tc.Prop_class1_1 = 20;
            tc.Prop_class1_2 = cell(1,10);
            tc_struct = to_struct(tc);

            tc_rec = serializable.from_struct(tc_struct);
            assertEqual(tc,tc_rec);
        end
        %------------------------------------------------------------------
        function test_keyval_constructor_nokey_throws_at_the_end(~)
            assertExceptionThrown(@()serializableTester2('Prop_class2_1','a',...
                'Prop_class2_2'),'HERBERT:serializable:invalid_argument');
        end
        %
        function test_keyval_constructor_nokey_throws(~)
            assertExceptionThrown(@()serializableTester2('Prop_class2_1',...
                'Prop_class2_2',20,'blabla'),'HERBERT:serializable:invalid_argument');
        end
        function test_val_keyval_constructor_returns_keyval_remaining(~)
            [tc,rem] = serializableTester2(11,'Prop_class2_1',10,...
                'blabla','Prop_class2_2',20);
            assertEqual(tc.Prop_class2_1,11)
            assertEqual(tc.Prop_class2_2,20)
            assertEqual(rem,{'Prop_class2_1',10,'blabla'});            
        end
        
        
        function test_keyval_constructor_middle_extra_val_ignored(~)
            [tc,rem] = serializableTester2('Prop_class2_1',10,...
                'blabla','Prop_class2_2',20);
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertEqual(rem{1},'blabla');
        end
        
        function test_keyval_constructor_last_extra_val_ignored(~)
            [tc,rem] = serializableTester2('Prop_class2_1',10,...
                'Prop_class2_2',20,'blabla');
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertEqual(rem{1},'blabla');
        end
        
        function test_keyval_constructor_first_extra_val_ignored(~)
            [tc,rem] = serializableTester2('blabla','Prop_class2_1',10,...
                'Prop_class2_2',20);
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertEqual(rem{1},'blabla');
        end
        
        function test_keyval_constructor(~)
            [tc,rem] = serializableTester2('Prop_class2_1',10,...
                'Prop_class2_2',20);
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertTrue(isempty(rem));
        end

        function test_val_constructor(~)
            [tc,rem] = serializableTester2(10,20);
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertTrue(isempty(rem));
        end
    end
end
