classdef test_serialize < TestCaseWithSave
    methods
        function obj=test_serialize(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialize';
            end
            obj = obj@TestCaseWithSave(name);

            obj.save();
        end


        %------------------------------------------------------------------
        function test_ser_sample(~)
            sam1=IX_sample('',true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes1 = hlp_serialize(sam1);
            % saved bytestream probably not now matching IX_sample now it
            % is a subclass of serialize.
            %assertEqualWithSave(obj,bytes1);
            % keeping the deserialize comparison

            sam1rec = hlp_deserialize(bytes1);
            assertEqual(sam1,sam1rec);

            sam2=IX_sample('',true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes2 = hlp_serialize(sam2);
            % as for bytes1 above
            %assertEqualWithSave(obj,bytes2);
            [sam2rec,nbytes] = hlp_deserialize(bytes2);
            assertEqual(numel(bytes2),nbytes);

            assertEqual(sam2,sam2rec);
        end

        %------------------------------------------------------------------
        function test_ser_instrument(~)

            % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            bytes1 = hlp_serialize(inst1);

            [inst1rec,nbytes] = hlp_deserialize(bytes1);
            assertEqual(numel(bytes1),nbytes);
            assertEqual(inst1,inst1rec);
            %assertEqualWithSave(obj,inst1rec);



            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            bytes2 = hlp_serialize(inst2);

            [inst2rec,nbytes] = hlp_deserialize(bytes2);
            assertEqual(numel(bytes2),nbytes);
            assertEqual(inst2,inst2rec );
            %assertEqualWithSave(obj,inst2rec);

            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            bytes3 = hlp_serialize(inst3);


            inst3rec = hlp_deserialize(bytes3);
            assertEqual(inst3,inst3rec );
            %assertEqualWithSave(obj,inst3rec);
            %------------------------------------------------------------------
        end

        function test_ser_serializeble_obj_array_level2(~)
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
            ser =  hlp_serialize(serCl);
            [serCl_rec,nbytes] = hlp_deserialize(ser);

            assertEqual(serCl, serCl_rec)
            assertEqual(nbytes,numel(ser));
        end

        function test_ser_serializeble_obj_array_level1_obj_level2(~)
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
            ser =  hlp_serialize(serCl);
            [serCl_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(serCl, serCl_rec)
            assertEqual(nbytes,numel(ser));
        end

        function test_ser_serializeble_obj_array_level1(~)
            % Prepare data
            serCl = serializableTester1();
            serCl = repmat(serCl,2,2);
            for i=1:numel(serCl)
                serCl(i).Prop_class1_1 = i*10;
                serCl(i).Prop_class1_2 = cell(1,i);
            end
            %--------------------------------------------------------------
            % Serialize using Matlab
            ser =  hlp_serialize(serCl);
            [serCl_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(serCl, serCl_rec)
            assertEqual(nbytes,numel(ser));
        end

        function test_ser_serializeble_obj(~)
            conf = hor_config;
            ds = conf.get_data_to_store();
            clob = onCleanup(@()set(conf,ds));
            conf.use_mex = false;
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= serializableTester1();

            %--------------------------------------------------------------

            ser =  hlp_serialize(serCl);
            [cerCl_rec,nbytes] = hlp_deserialize(ser);

            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, cerCl_rec)
            assertTrue(isa(cerCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));
        end

        function test_ser_serializeble_obj_level0(~)
            %--------------------------------------------------------------
            serCl = serializableTester2();
            serCl.Prop_class2_1=100;
            serCl.Prop_class2_2= [1,2,4];

            %--------------------------------------------------------------
            ser =  hlp_serialize(serCl);
            [cerCl_rec,nbytes] = hlp_deserialize(ser);

            assertEqual(nbytes,numel(ser));
            assertEqual(serCl, cerCl_rec)
            assertTrue(isa(cerCl_rec.Prop_class2_2,class(serCl.Prop_class2_2)));
        end

        function test_ser_datamessage(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = DataMessage(my_struc);

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec);

            test_obj = DataMessage(123456789);

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec);

            test_obj = DataMessage('This is a test message');

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec);
        end

        function test_ser_datamessage_array(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end


        % Test null
        function test_ser_array_null(~)
            test_obj = [];
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nBytes] = hlp_deserialize(ser);
            assertEqual(nBytes,numel(ser));

            assertEqual(test_obj, test_obj_rec)
        end

        % Test Logicals
        %------------------------------------------------------------------
        function test_ser_logical_scalar(~)
            test_obj = true;
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_logical_array(~)
            test_obj = [true, true, true];
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)
            assertEqual(test_obj, test_obj_rec)
        end

        % Test Characters
        %------------------------------------------------------------------
        function test_ser_chararray_null(~)
            test_obj = '';
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_scalar(~)
            test_obj = 'BEEP';
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_array(~)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)
            assertEqual(test_obj, test_obj_rec)
        end

        % Test Doubles
        %------------------------------------------------------------------
        function test_ser_double_scalar(~)
            test_obj = 10;
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)

            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_list(~)
            test_obj = 1:10;
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)

            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_array(~)
            test_obj = [1:10;1:10];
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)

            assertEqual(test_obj, test_obj_rec)
        end

        % Test Complexes
        %------------------------------------------------------------------
        function test_ser_complex_scalar(~)
            test_obj = 3+4i;
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)

            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_array(~)
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)

            assertEqual(test_obj, test_obj_rec)
        end

        function test_ser_mixed_complex_array(~)
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes)

            assertEqual(test_obj, test_obj_rec)
        end
        % Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(~)
            test_struct = struct([]);
            ser =  hlp_serialize(test_struct);
            [test_struct_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)
            assertEqual(nbytes,numel(ser));

            %size = hlp_serial_size(test_struct);
            %assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(~)
            test_struct = struct();
            ser =  hlp_serialize(test_struct);
            [test_struct_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)

            assertEqual(nbytes,numel(ser));
            %size = hlp_serial_size(test_struct);
            %assertEqual(size,numel(ser));

        end



        %------------------------------------------------------------------
        function test_ser_struct_scalar(obj)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  hlp_serialize(test_struct);
            assertEqualWithSave(obj,ser);

            [test_struct_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes,numel(ser));
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_list(~)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_array(~)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        % Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(~)
            test_sparse = sparse([],[],[]);
            ser =  hlp_serialize(test_sparse);
            [test_sparse_rec,nBytes] = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)
            assertEqual(numel(ser),nBytes);
        end

        function test_ser_real_sparse_empty(~)
            test_sparse = sparse([],[],[],10,10);
            ser =  hlp_serialize(test_sparse);
            [test_sparse_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)
            assertEqual(nbytes,numel(ser));

            %             size = hlp_serial_size(test_sparse);
            %             assertEqual(size,numel(ser));
        end
        %------------------------------------------------------------------
        function test_ser_real_sparse_single(obj)
            test_sparse = sparse(eye(1));
            ser =  hlp_serialize(test_sparse);
            assertEqualWithSave(obj,ser);

            [test_sparse_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes,numel(ser));
            assertEqual(test_sparse, test_sparse_rec)

        end
        %------------------------------------------------------------------
        function test_ser_real_sparse(~)
            test_sparse = sparse(eye(1));
            ser =  hlp_serialize(test_sparse);
            test_sparse_rec = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse(~)
            test_sparse = sparse(1:10, 1, 1i);
            ser =  hlp_serialize(test_sparse);
            test_sparse_rec = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        % Test Function handle
        function test_ser_function_handle(obj)
            test_func = @(x, y) (x^2 + y^2);
            ser = hlp_serialize(test_func);
            assertEqualWithSave(obj,ser);


            [test_func_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(func2str(test_func), func2str(test_func_rec))
            assertEqual(nbytes,numel(ser));
        end

        % Test Cell Array
        %------------------------------------------------------------------
        function test_ser_cell_null(obj)
            test_cell = {};
            ser =  hlp_serialize(test_cell);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
            assertEqual(nbytes,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric(obj)
            test_cell = {1 2 3 4};
            ser =  hlp_serialize(test_cell);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
            assertEqual(nbytes,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_complex(~)
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_mixed_complex(~)
            test_cell = {1+2i 2 3+1i 4};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_cell(obj)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  hlp_serialize(test_cell);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
            assertEqual(nbytes,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_bool(~)
            test_cell = {true false false true false};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_string(obj)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  hlp_serialize(test_cell);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
            assertEqual(nbytes,numel(ser));
        end

        function test_ser_struct_of_structs(obj)
            test_str1.val1=struct('Hello', 5);
            test_str1.val2=struct('Goodbye', 'Chicken');
            test_str2.val1=struct('Hell', 5);
            test_str2.val2=struct('Dear', 'Goblin');
            test_str = [test_str1,test_str2];

            ser =  hlp_serialize(test_str);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes, numel(ser))
            assertEqual(test_str, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_function_handles(obj)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  hlp_serialize(test_cell);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes, numel(ser))
            test_cell = cellfun(@func2str, test_cell, 'UniformOutput', false);
            test_cell_rec = cellfun(@func2str, test_cell_rec, 'UniformOutput', false);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_hetero(obj)
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};

            ser =  hlp_serialize(test_cell);
            assertEqualWithSave(obj,ser);

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes, numel(ser))

            test_cell{7} = func2str(test_cell{7});
            test_cell_rec{7} = func2str(test_cell_rec{7});
            assertEqual(test_cell, test_cell_rec)
        end

    end
end
