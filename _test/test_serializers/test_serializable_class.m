classdef test_serializable_class < TestCase
    properties
        wk_dir = tmp_dir()
        use_mex
    end

    methods

        function obj = test_serializable_class(name)
            if ~exist('name', 'var')
                name = 'test_serializable_class ';
            end
            obj = obj@TestCase(name);
            [~,nerr] = check_herbert_mex();
            obj.use_mex = (nerr == 0);
        end
        function test_partial_match_works(~)
            tob = serializableTesterWithInterdepProp(0.5,1,2, ...
                'partial_match_1',20,'partial_match_3',11);

            assertEqual(tob.Prop_class2_1,0.5)
            assertEqual(tob.Prop_class2_2,1)
            assertEqual(tob.Prop_class2_3,2)
            assertEqual(tob.partial_match_1_blue,20)
            assertTrue(isempty(tob.partial_match_2_green))
            assertEqual(tob.partial_match_3_yellow,11)
        end

        function test_partial_match_multi_throw(~)
            assertExceptionThrown(@()serializableTesterWithInterdepProp(10,1,0, ...
                'partial_match',20,'partial_match',11),...
                'HERBERT:serializable:invalid_argument');
        end
        function test_right_inderdep_prop_pass(~)
            tob = serializableTesterWithInterdepProp(10,1,0, ...
                'Prop_class2_2',20);
            assertEqual(tob.Prop_class2_1,10)
            assertEqual(tob.Prop_class2_2,20)
            assertEqual(tob.Prop_class2_3,0)
        end
        %------------------------------------------------------------------
        %
        function test_eq_operator_level1_ne(~)
            tc1 = serializableTester2(1,1:20,3);
            tc2 = serializableTester2(1,2,3);

            assertFalse(tc1 == tc2);

            iseq = tc1.eq(tc2);
            assertFalse(iseq);
        end
        %
        function test_eq_operator_level2(~)
            tc1 = serializableTester2(1,2,serializableTester1());
            tc2 = serializableTester2(1,2,serializableTester1());

            assertTrue(tc1 == tc2);

            iseq = tc1.eq(tc2);
            assertTrue(iseq);
        end
        %
        function test_eq_operator_level1_with_mess(~)
            tc1 = serializableTester2(1,1:20,3);
            tc2 = serializableTester2(1,1:20,3);

            [iseq,mess] = tc1.eq(tc2);
            assertTrue(iseq);
            assertTrue(isempty(mess));
        end
        %
        function test_eq_operator_level1(~)
            tc1 = serializableTester2(1,2,3);
            tc2 = serializableTester2(1,2,3);

            assertTrue(tc1 == tc2);

            iseq = tc1.eq(tc2);
            assertTrue(iseq);
        end
        %------------------------------------------------------------------
        function test_wrong_inderdep_prop_fail_differently(~)
            tob = serializableTesterWithInterdepProp(0,1,0);
            function test_set_throws()
                tob.Prop_class2_1 = 10;
            end
            assertExceptionThrown(@()test_set_throws(), ...
                'HERBERT:serializableTester:invalid_argument');
        end

        function test_wrong_inderdep_prop_fail(~)
            tob = serializableTesterWithInterdepProp();
            function test_set_throws()
                tob.Prop_class2_1 = 10;
            end
            assertExceptionThrown(@()test_set_throws(), ...
                'HERBERT:serializableTester:invalid_argument');
        end

        function test_ser_serializeble_obj_array_class2(~)
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

            data_size = hlp_serial_sise(serCl);
            assertEqual(data_size,numel(ser));

        end

        function test_ser_serializeble_obj_array_class2_cpp(obj)

            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj_array');
            end

            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = true;

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
            % Serialize using C++
            data_size_c = c_serial_size(serCl);
            ser_c     = c_serialise(serCl);
            serCl_rec = c_deserialise(ser_c);

            assertEqual(serCl, serCl_rec)
            assertEqual(data_size_c,numel(ser_c));
        end

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
            data_size = hlp_serial_sise(serCl);
            ser =  hlp_serialise(serCl);
            serCl_rec = hlp_deserialise(ser);

            assertEqual(serCl, serCl_rec)
            assertEqual(data_size,numel(ser));

        end

        function test_ser_serializeble_obj_array_class1_obj_class2_cpp(obj)
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj_array');
            end

            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = true;

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
            % Serialize using C++

            data_size_c = c_serial_size(serCl);
            ser_c     = c_serialise(serCl);
            serCl_rec = c_deserialise(ser_c);

            assertEqual(serCl, serCl_rec)
            assertEqual(data_size_c,numel(ser_c));
        end

        function test_ser_serializeble_obj_array_class1(~)
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
            data_size = hlp_serial_sise(serCl);
            ser =  hlp_serialise(serCl);
            serCl_rec = hlp_deserialise(ser);

            assertEqual(serCl, serCl_rec)
            assertEqual(data_size,numel(ser));

        end

        function test_ser_serializeble_obj_array_class1_cpp(obj)
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj_array');
            end

            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = true;

            %--------------------------------------------------------------
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            for i=1:numel(serCl)
                serCl(i).Prop_class1_1 = i*10;
                serCl(i).Prop_class1_2 = cell(1,i);
            end

            %--------------------------------------------------------------
            % Serialize using C++
            data_size_c = c_serial_size(serCl);
            ser_c     = c_serialise(serCl);
            serCl_rec = c_deserialise(ser_c);

            assertEqual(serCl, serCl_rec)
            assertEqual(data_size_c,numel(ser_c));
        end

        function test_ser_serializeble_obj(~)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= serializableTester1();

            %--------------------------------------------------------------
            % Serialize using MATLAB

            ser =  hlp_serialise(serCl);
            data_size = hlp_serial_sise(serCl);
            assertEqual(data_size,numel(ser));
            [serCl_rec,nbytes] = hlp_deserialise(ser);

            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, serCl_rec)
            assertTrue(isa(serCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));

        end

        function test_ser_serializeble_obj_cpp(obj)
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj');
            end
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = true;

            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= serializableTester1();

            %--------------------------------------------------------------
            % Serialize using C++
            data_size_c = c_serial_size(serCl);

            ser_c     = c_serialise(serCl);

            [serCl_rec,nbytes] = c_deserialise(ser_c);

            assertEqual(nbytes,numel(ser_c))
            assertEqual(serCl, serCl_rec)
            assertTrue(isa(serCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));

            assertEqual(data_size_c,numel(ser_c));
        end

        function test_ser_serializeble_obj_level0(~)

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
            data_size = hlp_serial_sise(serCl);
            assertEqual(data_size,numel(ser));

            [serCl_rec,nbytes] = hlp_deserialise(ser);

            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, serCl_rec)
            assertTrue(isa(serCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));
        end

        function test_ser_serializeble_obj_level0_cpp(obj)
            if ~obj.use_mex
                skipTest('Mex mode is not currently available for: test_ser_serializeble_obj');
            end

            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = true;
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= [1,2,4];

            %--------------------------------------------------------------
            % Serialize using C++
            data_size_c = c_serial_size(serCl);

            ser_c  = c_serialise(serCl);

            [serCl_rec,nbytes] = c_deserialise(ser_c);

            assertEqual(nbytes,numel(ser_c))
            assertEqual(serCl, serCl_rec)
            assertTrue(isa(serCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));

            assertEqual(data_size_c,numel(ser_c));
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

        end

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
        function test_pos_constructor_char_pos_sets_key(~)
            [tc,rem] = serializableTester2(11,20,'Prop_class2_3','aaa',...
                'Prop_class2_2',30,'blabla');
            assertEqual(tc.Prop_class2_1,11)
            assertEqual(tc.Prop_class2_2,30)
            assertEqual(tc.Prop_class2_3,'aaa')
            assertEqual(rem{1},'blabla');
            assertEqual(numel(rem),1);
        end

        function test_keyval_constructor_nokey_throws_at_the_end(~)
            assertExceptionThrown(@()serializableTester2('Prop_class2_1','a',...
                'Prop_class2_2'),'HERBERT:serializable:invalid_argument');
        end

        function test_keyval_constructor_nokey_return_remains(~)
            [st,remains] = serializableTester2('Prop_class2_1',10,...
                'Prop_class2_2',20,'blabla');
            assertEqual(st.Prop_class2_1,10);
            assertEqual(st.Prop_class2_2,20);
            assertEqual(remains,{'blabla'});
        end

        function test_deprecated_keys_provided(~)
            ws = warning('off','HORACE:serializable:deprecated');
            clOb = onCleanup(@()warning(ws));
            tc = serializableTesterWithInterdepProp( ...
                'Prop_class2_1',2,'-Prop_class2_2',10,'-Prop_class2_3',[1,2,3]);

            [~,lw] = lastwarn();
            assertEqual(lw,'HORACE:serializable:deprecated');
            assertEqual(tc.Prop_class2_1,2);
            assertEqual(tc.Prop_class2_2,10);
            assertEqual(tc.Prop_class2_3,[1,2,3]);

        end

        function test_val_keyval_constructor_returns_keyval_remaining(~)
            [tc,rem] = serializableTester2(11,'Prop_class2_1',10,...
                'blabla','Prop_class2_2',20);
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertTrue(isempty(tc.Prop_class2_3))
            assertEqual(rem,{'blabla'});
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

        function test_keyval_constructor_first_pos_reset_later(~)
            [tc,rem] = serializableTester2('blabla','Prop_class2_1',10,...
                'Prop_class2_2',20);
            assertEqual(tc.Prop_class2_1,10)
            assertEqual(tc.Prop_class2_2,20)
            assertTrue(isempty(rem));
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
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        function test_key_val_constructor_mix_dash(~)
            tc = serializable_tester4setKeyValConstructor(true,'a','prop3','a','prop2','b');
            assertEqual(tc.prop1_char,'a')
            assertEqual(tc.prop2_char,'b')
            assertEqual(tc.prop3_char,'a')
        end

        function test_key_val_constructor_m_keys_dash(~)
            ws = warning('off','HORACE:serializable:deprecated');
            clOb = onCleanup(@()warning(ws));

            tc = serializable_tester4setKeyValConstructor(true,'-prop3_char','a','-prop2_char','b','-prop1','c');
            [~,wi] = lastwarn;
            assertEqual(wi,'HORACE:serializable:deprecated')
            assertEqual(tc.prop1_char,'c')
            assertEqual(tc.prop2_char,'b')
            assertEqual(tc.prop3_char,'a')
        end

        function test_key_val_constructor_keys_dash(~)
            tc = serializable_tester4setKeyValConstructor(true,'prop3_char','a','prop2_char','b','prop1','c');
            assertEqual(tc.prop1_char,'c')
            assertEqual(tc.prop2_char,'b')
            assertEqual(tc.prop3_char,'a')
        end

        function test_key_val_constructor_mix_no_dash(~)
            tc = serializable_tester4setKeyValConstructor(false,'a','prop3','a','prop2','b');
            assertEqual(tc.prop1_char,'a')
            assertEqual(tc.prop2_char,'b')
            assertEqual(tc.prop3_char,'a')
        end
        function test_two_keys_in_a_row_throw(~)
            ME=assertExceptionThrown( ...
                @()serializable_tester4setKeyValConstructor(false,'b','prop3_char','c','prop2_char'), ...
                'HERBERT:serializable:invalid_argument');
            assertTrue(strncmp(ME.message,'should be even number of key-value pairs',29))
        end

        function test_key_val_constructor_m_keys_no_dash_throw(~)
            % throws as this form does not support dash at the beginning so
            % second property with dash outsied of positional parameters is not recognized
            ws = warning('off','HORACE:serializable:deprecated');
            clOb = onCleanup(@()warning(ws));
            ME=assertExceptionThrown( ...
                @()serializable_tester4setKeyValConstructor(false,'-prop3','a','-prop2','b','-prop1','c'), ...
                'HERBERT:serializable_class_tests:invalid_argument');
            assertEqual(ME.message, ...
                'unrecognized property provided as input: {''-prop2''}    {''b''}    {''-prop1''}    {''c''}')
        end


        function test_key_val_constructor_keys_no_dash(~)
            tc = serializable_tester4setKeyValConstructor(false,'prop3_char','a','prop2_char','b','prop1','c');
            assertEqual(tc.prop1_char,'c')
            assertEqual(tc.prop2_char,'b')
            assertEqual(tc.prop3_char,'a')
        end
        function test_key_val_constructor_keys_no_dash_throws(~)
            ME=assertExceptionThrown( ...
                @()serializable_tester4setKeyValConstructor(false,'prop3','a','prop2','b','prop1','c'),...
                'HERBERT:serializable:invalid_argument');
            assertTrue(strncmp(ME.message,'More positional arguments',25))
        end

        function test_key_val_constructor_values_no_dash(~)
            tc = serializable_tester4setKeyValConstructor(false,'a','b','c');
            assertEqual(tc.prop1_char,'a')
            assertEqual(tc.prop2_char,'b')
            assertEqual(tc.prop3_char,'c')
        end
    end
end
