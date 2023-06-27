classdef test_serialise_size < TestCase
    properties
    end
    methods
        function this=test_serialise_size(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialise_size';
            end
            this = this@TestCase(name);

        end

        %% Test Objects
        %------------------------------------------------------------------
        function test_sise_struct(~)
            test_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                                'dee',struct('a',10),'ei',int32([9;8;7]));

            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);

            test_struc = struct('clc',{1,2,4,5},'a',[1,4,5,6],...
                                'ba',zeros(3,2),'ce',struct(),...
                                'dee',@(x)sin(x),'ei',[1,2,4]');

            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);

        end

        %------------------------------------------------------------------
        function test_ser_sample(~)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            size1 = hlp_serial_size(sam1);
            bytes = hlp_serialize(sam1);
            assertEqual(size1,numel(bytes));

            sam2=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            size2 = hlp_serial_size(sam2);
            bytes = hlp_serialize(sam2);
            assertEqual(size2,numel(bytes));


        end

        %------------------------------------------------------------------
        function test_ser_instrument(~)

        % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            size1 = hlp_serial_size(inst1);
            bytes = hlp_serialize(inst1);
            assertEqual(size1,numel(bytes));

            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            size2 = hlp_serial_size(inst2);
            bytes = hlp_serialize(inst2);
            assertEqual(size2,numel(bytes));

            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            size3 = hlp_serial_size(inst3);
            bytes = hlp_serialize(inst3);
            assertEqual(size3,numel(bytes));

            %------------------------------------------------------------------
        end

        function test_ser_datamessage(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_struc = DataMessage(my_struc);

            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);

            test_struc = DataMessage(123456789);

            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);

            test_struc = DataMessage('This is a test message');

            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);
        end

        function test_ser_datamessage_array(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            bytes = hlp_serialize(test_obj);
            sz = hlp_serial_size(test_obj);
            assertEqual(numel(bytes),sz);
        end

        %% Test null
        function test_ser_sise_array_null(~)
            test_obj = [];
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end


        %% Test Logicals
        %------------------------------------------------------------------
        function test_ser_sise_logical_scalar(~)
            test_obj = true;
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_logical_array(~)
            test_obj = [true, true, true];
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Characters
        %------------------------------------------------------------------
        function test_ser_sise_chararray_null(~)
            test_obj = '';
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_chararray_scalar(~)
            test_obj = 'BEEP';
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_chararray_array(~)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Doubles
        %------------------------------------------------------------------
        function test_ser_sise_double_scalar(~)
            test_obj = 10;
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_double_list(~)
            test_obj = 1:10;
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_double_array(~)
            test_obj = [1:10;1:10];
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Complexes
        %------------------------------------------------------------------
        function test_ser_sise_complex_scalar(~)
            test_obj = 3+4i;
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_complex_array(~)
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(~)
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  hlp_serialize(test_obj);
            ser_siz = hlp_serial_size(test_obj);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(~)
            test_struct = struct([]);
            ser =  hlp_serialize(test_struct);
            ser_siz = hlp_serial_size(test_struct);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(~)
            test_struct = struct();
            ser =  hlp_serialize(test_struct);
            ser_siz = hlp_serial_size(test_struct);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_scalar(~)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  hlp_serialize(test_struct);
            ser_siz = hlp_serial_size(test_struct);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_list(~)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  hlp_serialize(test_struct);
            ser_siz = hlp_serial_size(test_struct);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_array(~)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = hlp_serialize(test_struct);
            ser_siz = hlp_serial_size(test_struct);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(~)
            test_sparse = sparse([],[],[]);
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_empty(~)
            test_sparse = sparse([],[],[],10,10);
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_single(~)
            test_sparse = sparse(eye(1));
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_array(~)
            test_sparse = sparse(eye(10));
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(~)
            test_sparse = sparse([],[], complex([],[]));
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(~)
            test_sparse = sparse([],[],complex([],[]),10,10);
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(~)
            test_sparse = sparse(1, 1, 1i);
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(~)
            test_sparse = sparse(1:10, 1, 1i);
            ser =  hlp_serialize(test_sparse);
            ser_siz = hlp_serial_size(test_sparse);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Function handle
        function test_ser_sise_function_handle(~)
            test_func = @(x, y) (x^2 + y^2);
            ser = hlp_serialize(test_func);
            ser_siz = hlp_serial_size(test_func);
            assertEqual(numel(ser), ser_siz)
        end

        %% Test Cell Array
        %------------------------------------------------------------------
        function test_ser_sise_cell_null(~)
            test_cell = {};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_numeric(~)
            test_cell = {1 2 3 4};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(~)
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_complex(~)
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_mixed_complex(~)
            test_cell = {1+2i 2 3+1i 4};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_cell(~)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_bool(~)
            test_cell = {true false false true false};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_string(~)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(~)
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_function_handles(~)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  hlp_serialize(test_cell);
            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_hetero(~)
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            ser =  hlp_serialize(test_cell);

            ser_siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser), ser_siz)
        end


    end
end
