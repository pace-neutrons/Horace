classdef test_cpp_serialise_size< TestCase
    properties
    end
    methods
        function this=test_cpp_serialise_size(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_cpp_serialise_size';
            end
            this = this@TestCase(name);

        end

        %% Test Objects
        %------------------------------------------------------------------
        function test_sise_struct(this)
            test_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                                'dee',struct('a',10),'ei',int32([9;8;7]));

            cpp = c_serial_size(test_struc);
            sz = hlp_serial_sise(test_struc);
            assertEqual(cpp,sz);

            test_struc = struct('clc',{1,2,4,5},'a',[1,4,5,6],...
                                'ba',zeros(3,2),'ce',struct(),...
                                'dee',@(x)sin(x),'ei',[1,2,4]');

            cpp = c_serial_size(test_struc);
            sz = hlp_serial_sise(test_struc);
            assertEqual(cpp,sz);

        end

        %------------------------------------------------------------------
        function test_ser_sample(this)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            size1 = hlp_serial_sise(sam1);
            cpp = c_serial_size(sam1);
            assertEqual(size1,cpp);

            % - TGP 22/07/2019: commented out these two samples as the names are no longer valid
            %             sam2=IX_sample(true,[1,1,1],[0,2,1],'cylinder_long_name',rand(1,5));
            %             size2 = hlp_serial_sise(sam2);
            %             cpp = c_serial_size(sam2);
            %             assertEqual(size2,cpp);
            %
            %             sam3=IX_sample(true,[1,1,0],[0,0,1],'hypercube_really_long_name',rand(1,6));
            %             size3 = hlp_serial_sise(sam3);
            %             cpp = c_serial_size(sam3);
            %             assertEqual(size3,cpp);

            sam4=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            size4 = hlp_serial_sise(sam4);
            cpp = c_serial_size(sam4);
            assertEqual(size4,cpp);


        end

        %------------------------------------------------------------------
        function test_ser_instrument(this)

            % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            size1 = hlp_serial_sise(inst1);
            cpp = c_serial_size(inst1);
            assertEqual(size1,cpp);

            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            size2 = hlp_serial_sise(inst2);
            cpp = c_serial_size(inst2);
            assertEqual(size2,cpp);

            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            size3 = hlp_serial_sise(inst3);
            cpp = c_serial_size(inst3);
            assertEqual(size3,cpp);

        end

        %------------------------------------------------------------------
        function test_ser_datamessage(this)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_struc = DataMessage(my_struc);

            cpp = c_serial_size(test_struc);
            sz = hlp_serial_sise(test_struc);
            assertEqual(cpp,sz);

            test_struc = DataMessage(123456789);

            cpp = c_serial_size(test_struc);
            sz = hlp_serial_sise(test_struc);
            assertEqual(cpp,sz);

            test_struc = DataMessage('This is a test message');

            cpp = c_serial_size(test_struc);
            sz = hlp_serial_sise(test_struc);
            assertEqual(cpp,sz);
        end

        function test_ser_datamessage_array(this)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                              'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            cpp = c_serial_size(test_obj);
            sz = hlp_serial_sise(test_obj);
            assertEqual(cpp,sz);
        end

        %% Test null
        function test_ser_sise_array_null(this)
            test_obj = [];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end


        %% Test Logicals
        %------------------------------------------------------------------
        function test_ser_sise_logical_scalar(this)
            test_obj = true;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_logical_array(this)
            test_obj = [true, true, true];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Characters
        %------------------------------------------------------------------
        function test_ser_sise_chararray_null(this)
            test_obj = '';
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_chararray_scalar(this)
            test_obj = 'BEEP';
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_chararray_array(this)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Doubles
        %------------------------------------------------------------------
        function test_ser_sise_double_scalar(this)
            test_obj = 10;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_double_list(this)
            test_obj = [1:10];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_double_array(this)
            test_obj = [1:10;1:10];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Complexes
        %------------------------------------------------------------------
        function test_ser_sise_complex_scalar(this)
            test_obj = 3+4i;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_complex_array(this)
            test_obj = [3+4i, 5+7i; 2+i, 1-i];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(this)
            test_obj = [3+4i, 2; 3+5i, 0];
            cpp =  c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(this)
            test_struct = struct([]);
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(this)
            test_struct = struct();
            cpp =  c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_scalar(this)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_list(this)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_array(this)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %% Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(this)
            test_sparse = sparse([],[],[]);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_empty(this)
            test_sparse = sparse([],[],[],10,10);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_single(this)
            test_sparse = sparse(eye(1));
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_array(this)
            test_sparse = sparse(eye(10));
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(this)
            test_sparse = sparse([],[], complex([],[]));
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(this)
            test_sparse = sparse([],[],complex([],[]),10,10);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(this)
            test_sparse = sparse([1],[1], [i]);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(this)
            test_sparse = sparse([1:10],[1], i);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %% Test Function handle
        function test_ser_sise_function_handle(this)
            test_func = @(x, y) (x^2 + y^2);
            cpp = c_serial_size(test_func);
            ser_siz = hlp_serial_sise(test_func);
            assertEqual(cpp, ser_siz)
        end

        %% Test Cell Array
        %------------------------------------------------------------------
        function test_ser_sise_cell_null(this)
            test_cell = {};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_numeric(this)
            test_cell = {1 2 3 4};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(this)
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_complex(this)
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_mixed_complex(this)
            test_cell = {1+2i 2 3+1i 4};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_cell(this)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_bool(this)
            test_cell = {true false false true false};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_string(this)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(this)
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_function_handles(this)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_hetero(this)
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end


    end
end
