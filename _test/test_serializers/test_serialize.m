classdef test_serialize < TestCase
    properties
    end
    methods
        function this=test_serialize(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialize';
            end
            this = this@TestCase(name);

        end


        %------------------------------------------------------------------
        function test_ser_sample(~)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = hlp_serialize(sam1);
            sam1rec = hlp_deserialize(bytes);
            assertEqual(sam1,sam1rec);

            sam2=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = hlp_serialize(sam2);
            sam2rec = hlp_deserialize(bytes);
            assertEqual(sam2,sam2rec);

        end

        %------------------------------------------------------------------
        function test_ser_instrument(~)
            skipTest('Old serialiser does not support serialising object arrays #394')
        % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            bytes = hlp_serialize(inst1);
            inst1rec = hlp_deserialize(bytes);
            assertEqual(inst1,inst1rec);


            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            bytes = hlp_serialize(inst2);
            inst2rec = hlp_deserialize(bytes);
            assertEqual(inst2,inst2rec );

            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            bytes = hlp_serialize(inst3);
            inst3rec = hlp_deserialize(bytes);
            assertEqual(inst3,inst3rec );

            %------------------------------------------------------------------
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
            skipTest('Old serialiser does not support serialising object arrays')
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end


        %% Test null
        function test_ser_array_null(~)
            test_obj = [];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Logicals
        %------------------------------------------------------------------
        function test_ser_logical_scalar(~)
            test_obj = true;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_logical_array(~)
            test_obj = [true, true, true];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Characters
        %------------------------------------------------------------------
        function test_ser_chararray_null(~)
            test_obj = '';
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_scalar(~)
            test_obj = 'BEEP';
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_array(~)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Doubles
        %------------------------------------------------------------------
        function test_ser_double_scalar(~)
            test_obj = 10;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_list(~)
            test_obj = 1:10;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_array(~)
            test_obj = [1:10;1:10];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Complexes
        %------------------------------------------------------------------
        function test_ser_complex_scalar(~)
            test_obj = 3+4i;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_array(~)
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        function test_ser_mixed_complex_array(~)
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_scalar(~)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        % CANNOT HANDLE STRUCT ARRAYS
        function DISABLED_test_ser_struct_list(~)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        % CANNOT HANDLE STRUCT ARRAYS
        function DISABLED_test_ser_struct_array(~)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %% Test Sparse
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

        %% Test Function handle
        function test_ser_function_handle(~)
            test_func = @(x, y) (x^2 + y^2);
            ser = hlp_serialize(test_func);
            test_func_rec = hlp_deserialize(ser);
            assertEqual(func2str(test_func), func2str(test_func_rec))
        end

        %% Test Cell Array
        %------------------------------------------------------------------
        function test_ser_cell_null(~)
            test_cell = {};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric(~)
            test_cell = {1 2 3 4};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
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
            skipTest('Old serialiser has bug with mixed complex types')
            test_cell = {1+2i 2 3+1i 4};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_cell(~)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_bool(~)
            test_cell = {true false false true false};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_string(~)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_function_handles(~)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            test_cell = cellfun(@func2str, test_cell, 'UniformOutput', false);
            test_cell_rec = cellfun(@func2str, test_cell_rec, 'UniformOutput', false);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_hetero(~)
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            test_cell{7} = func2str(test_cell{7});
            test_cell_rec{7} = func2str(test_cell_rec{7});
            assertEqual(test_cell, test_cell_rec)
        end

    end
end