classdef test_serialise < TestCase
    properties
        use_mex;
    end
    methods
        function this=test_serialise(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialise';
            end
            this = this@TestCase(name);
            [~,nerr] = check_herbert_mex();
            if nerr>0
                this.use_mex = false;
            else
                this.use_mex = true;
            end
            
            
        end
        %
        %------------------------------------------------------------------
        function test_ser_sample(~)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            
            bytes = hlp_serialise(sam1);
            size = hlp_serial_sise(sam1);
            assertEqual(numel(bytes),size);
            %
            [sam1rec,nbytes] = hlp_deserialise(bytes);
            assertEqual(nbytes,size);
            assertEqual(sam1,sam1rec);
            
            sam2=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            
            bytes = hlp_serialise(sam2);
            size = hlp_serial_sise(sam1);
            assertEqual(numel(bytes),size);
            
            [sam2rec,nbytes] = hlp_deserialise(bytes);
            assertEqual(nbytes,size);            
            assertEqual(sam2,sam2rec);
            
        end
        
        %------------------------------------------------------------------
        function test_ser_instrument(~)
            
            % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            bytes = hlp_serialise(inst1);
            inst1rec = hlp_deserialise(bytes);
            assertEqual(inst1,inst1rec);
            size = hlp_serial_sise(inst1);
            assertEqual(size,numel(bytes));
            
            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            bytes = hlp_serialise(inst2);
            inst2rec = hlp_deserialise(bytes);
            assertEqual(inst2,inst2rec );
            size = hlp_serial_sise(inst2);
            assertEqual(size,numel(bytes));
            
            
            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            bytes = hlp_serialise(inst3);
            inst3rec = hlp_deserialise(bytes);
            assertEqual(inst3,inst3rec );
            size = hlp_serial_sise(inst3);
            assertEqual(size,numel(bytes));
        end
        
        
        %------------------------------------------------------------------
        function test_ser_datamessage(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = DataMessage(my_struc);
            
            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
            
            test_obj = DataMessage(123456789);
            
            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
            
            test_obj = DataMessage('This is a test message');
            
            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        %------------------------------------------------------------------
        function test_ser_datamessage_array(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];
            
            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        %------------------------------------------------------------------
        function test_ser_pixdata(~)
            skipTest('PixelData serialisation is not implemented yet')
            test_obj = PixelData();
            
            ser = hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        % Test null
        function test_ser_array_null(~)
            test_obj = [];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        % Test Logicals
        %------------------------------------------------------------------
        function test_ser_logical_scalar(~)
            test_obj = true;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_logical_array(~)
            test_obj = [true, true, true];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        % Test Characters
        %------------------------------------------------------------------
        function test_ser_chararray_null(~)
            test_obj = '';
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        %------------------------------------------------------------------
        function test_ser_chararray_scalar(~)
            test_obj = 'BEEP';
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        %------------------------------------------------------------------
        function test_ser_chararray_array(~)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
        end
        
        % Test Doubles
        %------------------------------------------------------------------
        function test_ser_double_scalar(~)
            test_obj = 10;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_double_list(~)
            test_obj = 1:10;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        %------------------------------------------------------------------
        function test_ser_double_array(~)
            test_obj = [1:10;1:10];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
        end
        
        % Test Complexes
        %------------------------------------------------------------------
        function test_ser_complex_scalar(~)
            test_obj = 3+4i;
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_complex_array(~)
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(~)
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  hlp_serialise(test_obj);
            test_obj_rec = hlp_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
            
            size = hlp_serial_sise(test_obj);
            assertEqual(size,numel(ser));
            
        end
        
        % Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(~)
            test_struct = struct([]);
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
            
            size = hlp_serial_sise(test_struct);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_struct_empty(~)
            test_struct = struct();
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
            
            size = hlp_serial_sise(test_struct);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_struct_scalar(~)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
            
            size = hlp_serial_sise(test_struct);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_struct_list(~)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
            
            size = hlp_serial_sise(test_struct);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_struct_array(~)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = hlp_serialise(test_struct);
            test_struct_rec = hlp_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
            
            size = hlp_serial_sise(test_struct);
            assertEqual(size,numel(ser));
            
        end
        
        % Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(~)
            test_sparse = sparse([],[],[]);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_real_sparse_empty(~)
            test_sparse = sparse([],[],[],10,10);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_real_sparse_single(~)
            test_sparse = sparse(eye(1));
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_real_sparse_array(~)
            test_sparse = sparse(eye(10));
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(~)
            test_sparse = sparse([],[], complex([],[]));
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(~)
            test_sparse = sparse([],[],complex([],[]),10,10);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(~)
            test_sparse = sparse(1, 1, 1i);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(~)
            test_sparse = sparse(1:10, 1, 1i);
            ser =  hlp_serialise(test_sparse);
            test_sparse_rec = hlp_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
            
            size = hlp_serial_sise(test_sparse);
            assertEqual(size,numel(ser));
            
        end
        
        % Test Function handle
        function test_ser_function_handle(~)
            test_func = @(x, y) (x^2 + y^2);
            ser = hlp_serialise(test_func);
            test_func_rec = hlp_deserialise(ser);
            assertEqual(func2str(test_func), func2str(test_func_rec))
            
            size = hlp_serial_sise(test_func);
            assertEqual(size,numel(ser));
            
        end
        
        % Test Cell Array
        %------------------------------------------------------------------
        function test_ser_cell_null(~)
            test_cell = {};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric(~)
            test_cell = {1 2 3 4};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(~)
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_complex(~)
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_mixed_complex(~)
            test_cell = {1+2i 2 3+1i 4};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_cell(~)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_bool(~)
            test_cell = {true false false true false};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_string(~)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(~)
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
            
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        %------------------------------------------------------------------
        function test_ser_struct_of_structs(~)
            test_str1.val1=struct('Hello', 5);
            test_str1.val2=struct('Goodbye', 'Chicken');
            test_str2.val1=struct('Hell', 5);
            test_str2.val2=struct('Dear', 'Goblin');
            test_str = [test_str1,test_str2];
            
            ser =  hlp_serialise(test_str);
            test_cell_rec = hlp_deserialise(ser);
            assertEqual(test_str, test_cell_rec)
            
            size = hlp_serial_sise(test_str);
            assertEqual(size,numel(ser));
        end
        
        
        %------------------------------------------------------------------
        function test_ser_cell_homo_function_handles(~)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            test_cell = cellfun(@func2str, test_cell, 'UniformOutput',false);
            test_cell_rec = cellfun(@func2str, test_cell_rec, 'UniformOutput',false);
            assertEqual(test_cell, test_cell_rec)
            
            skipTest('C++ this test fails #394')
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
            
        end
        
        %------------------------------------------------------------------
        function test_ser_cell_hetero(~)
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            ser =  hlp_serialise(test_cell);
            test_cell_rec = hlp_deserialise(ser);
            test_cell{7} = func2str(test_cell{7});
            test_cell_rec{7} = func2str(test_cell_rec{7});
            assertEqual(test_cell, test_cell_rec)
            
            skipTest('C++ this test fails #394')
            size = hlp_serial_sise(test_cell);
            assertEqual(size,numel(ser));
        end
        %
        function test_ser_serializeble_obj_array_level2(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            setCl2 = serializableTester2();
            setCl2.Prop_level2_1 = 10;
            setCl2.Prop_level2_2 = 20;
            for i=1:numel(serCl)
                serCl(i).Prop_level1_1 = i*10;
                serCl(i).Prop_level1_2 = repmat(setCl2,1,2*i);
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
        function test_ser_serializeble_obj_array_level1_obj_level2(obj)
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
                setCl2.Prop_level2_1 = 5*i;
                setCl2.Prop_level2_2 = 20*i;
                serCl(i).Prop_level1_1 = i*10;
                serCl(i).Prop_level1_2 =setCl2;
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
        
        function test_ser_serializeble_obj_array_level1(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            for i=1:numel(serCl)
                serCl(i).Prop_level1_1 = i*10;
                serCl(i).Prop_level1_2 = cell(1,i);
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
            serCl.Prop_level2_1=100;
            serCl.Prop_level2_2= serializableTester1();
            
            %--------------------------------------------------------------
              
            ser =  hlp_serialise(serCl);
            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));            
            [cerCl_rec,nbytes] = hlp_deserialise(ser);
            
            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, cerCl_rec)
            assertTrue(isa(cerCl_rec.Prop_level2_2,class(serCl.Prop_level2_2)));
            
            
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
            assertTrue(isa(cerCl_rec.Prop_level2_2,class(serCl.Prop_level2_2)));
            assertEqual(ser_c,ser);
            
            assertEqual(size_c,numel(ser));
        end
        function test_ser_serializeble_obj_level0(obj)
            conf = herbert_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_level2_1=100;
            serCl.Prop_level2_2= [1,2,4];
            
            %--------------------------------------------------------------
              
            ser =  hlp_serialise(serCl);
            size = hlp_serial_sise(serCl);
            assertEqual(size,numel(ser));
            
            [cerCl_rec,nbytes] = hlp_deserialise(ser);
            
            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, cerCl_rec)
            assertTrue(isa(cerCl_rec.Prop_level2_2,class(serCl.Prop_level2_2)));
            
            
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
            assertTrue(isa(cerCl_rec.Prop_level2_2,class(serCl.Prop_level2_2)));
            assertEqual(ser_c,ser);
            
            assertEqual(size_c,numel(ser));
        end
        
        
        function test_pack_unpack_header(~)
            shapes = {[],[1,1],[1,10],[10,1],[10,10],[1,10,10],[10,2,10],...
                [1,10,10,10],[2,1,10,10]};
            fh_types = {'simple', 'classsimple','anonymous','scopedfunction','nested'};
            
            type_details = hlp_serial_types.type_details;
            for ntype = 1:numel(type_details)
                type_str = type_details(ntype);
                if strcmp(type_str.name,'function_handle')
                    
                    for fhn=1:numel(fh_types )
                        packed_tag = hlp_serial_types.pack_data_tag(...
                            0,type_str,fh_types{fhn});
                        [type_rec,fh_id ,~,pos] = ...
                            hlp_serial_types.unpack_data_tag(packed_tag,1);
                        tag_size = ...
                            hlp_serial_types.calc_tag_size([],type_str,fh_types{fhn});
                        assertEqual(type_rec,type_str);
                        assertEqual(pos, numel(packed_tag)+1);
                        assertEqual(fh_id, hlp_serial_types.fh_map(fh_types{fhn}));
                        assertEqual(tag_size,numel(packed_tag))
                    end
                    
                else
                    for nShape = 1:numel(shapes)
                        sh_size =  shapes{nShape};
                        %
                        packed_tag = hlp_serial_types.pack_data_tag(...
                            sh_size,type_str);
                        [type_rec, nDims_rec,size_rec,pos] = ...
                            hlp_serial_types.unpack_data_tag(packed_tag,1);
                        tag_size = ...
                            hlp_serial_types.calc_tag_size(sh_size,type_str);
                        %
                        assertEqual(type_rec,type_str);
                        if ~isempty(size_rec) && size_rec(1) ==1 && numel(size_rec) == 2
                            assertEqual(nDims_rec,1);
                        else
                            assertEqual(nDims_rec,numel(sh_size));
                        end
                        assertEqual(size_rec,sh_size);
                        assertEqual(pos, numel(packed_tag)+1);
                        assertEqual(tag_size,numel(packed_tag))
                        
                    end
                end
            end
        end
    end
end