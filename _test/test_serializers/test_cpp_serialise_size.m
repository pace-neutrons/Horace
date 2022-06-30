classdef test_cpp_serialise_size < TestCase
    properties
        warned
        use_mex
    end
    methods
        function this=test_cpp_serialise_size(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_cpp_serialise_size';
            end
            this = this@TestCase(name);
            this.warned = get(herbert_config, 'log_level') > 0;
            [~,nerr] = check_herbert_mex();
            this.use_mex = nerr == 0;
        end

        %% Test Objects
        %------------------------------------------------------------------
        function test_sise_struct(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));

            sz = hlp_serial_sise(test_struc);
            cpp = c_serial_size(test_struc);
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
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            size1 = hlp_serial_sise(sam1);
            cpp = c_serial_size(sam1);
            assertEqual(size1,cpp);

            sam2=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            size2 = hlp_serial_sise(sam2);
            cpp = c_serial_size(sam2);
            assertEqual(size2,cpp);


        end

        %------------------------------------------------------------------
        function test_ser_instrument(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end

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
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
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
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            cpp = c_serial_size(test_obj);
            sz = hlp_serial_sise(test_obj);
            assertEqual(cpp,sz);
        end

        %% Test null
        function test_ser_sise_array_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end


        %% Test Logicals
        %------------------------------------------------------------------
        function test_ser_sise_logical_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = true;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_logical_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [true, true, true];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Characters
        %------------------------------------------------------------------
        function test_ser_sise_chararray_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = '';
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_chararray_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 'BEEP';
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_chararray_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Doubles
        %------------------------------------------------------------------
        function test_ser_sise_double_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 10;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_double_list(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 1:10;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_double_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [1:10;1:10];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Complexes
        %------------------------------------------------------------------
        function test_ser_sise_complex_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 3+4i;
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_complex_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            cpp = c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [3+4i, 2; 3+5i, 0];
            cpp =  c_serial_size(test_obj);
            ser_siz = hlp_serial_sise(test_obj);
            assertEqual(cpp, ser_siz)
        end

        %% Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct([]);
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct();
            cpp =  c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_list(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct('HonkyTonk', {1, 2, 3});
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_struct_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            cpp = c_serial_size(test_struct);
            ser_siz = hlp_serial_sise(test_struct);
            assertEqual(cpp, ser_siz)
        end

        %% Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[],[]);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_empty(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[],[],10,10);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_single(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(eye(1));
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(eye(10));
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[], complex([],[]));
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[],complex([],[]),10,10);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(1, 1, 1i);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(1:10, 1, 1i);
            cpp = c_serial_size(test_sparse);
            ser_siz = hlp_serial_sise(test_sparse);
            assertEqual(cpp, ser_siz)
        end

        %% Test Function handle
        function test_ser_sise_function_handle(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_func = @(x, y) (x^2 + y^2);
            cpp = c_serial_size(test_func);
            ser_siz = hlp_serial_sise(test_func);
            assertEqual(cpp, ser_siz)
        end

        %% Test Cell Array
        %------------------------------------------------------------------
        function test_ser_sise_cell_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_numeric(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1 2 3 4};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_complex(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_mixed_complex(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1+2i 2 3+1i 4};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_cell(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_bool(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {true false false true false};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_string(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_homo_function_handles(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end

        %------------------------------------------------------------------
        function test_ser_sise_cell_hetero(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            cpp = c_serial_size(test_cell);
            ser_siz = hlp_serial_sise(test_cell);
            assertEqual(cpp, ser_siz)
        end


    end
end
