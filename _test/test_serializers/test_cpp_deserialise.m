classdef test_cpp_deserialise < TestCase
    properties
        warned
        use_mex
        old_mex
    end

    methods
        function this=test_cpp_deserialise(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_cpp_deserialise';
            end
            this = this@TestCase(name);
            this.warned = get(herbert_config, 'log_level') > 0;
            this.old_mex = get(herbert_config, 'use_mex');
            [~,nerr] = check_herbert_mex();
            this.use_mex = nerr == 0;
        end

        function setUp(this)
            set(herbert_config, 'use_mex', true);
        end

        function tearDown(this)
            set(herbert_config, 'use_mex', this.old_mex);
        end

        %------------------------------------------------------------------
        function test_ser_sample(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = c_serialise(sam1);
            sam1rec = c_deserialise(bytes);
            assertEqual(sam1,sam1rec);

            sam2=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = c_serialise(sam2);
            sam2rec = c_deserialise(bytes);
            assertEqual(sam2,sam2rec);

        end

        %------------------------------------------------------------------
        function test_ser_instrument(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end

            % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            bytes = c_serialise(inst1);
            inst1rec = c_deserialise(bytes);
            assertEqual(inst1,inst1rec);


            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            bytes = c_serialise(inst2);
            inst2rec = c_deserialise(bytes);
            assertEqual(inst2,inst2rec );

            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            bytes = c_serialise(inst3);
            inst3rec = c_deserialise(bytes);
            assertEqual(inst3,inst3rec );

        end


        %------------------------------------------------------------------
        function test_ser_datamessage(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end

            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = DataMessage(my_struc);

            ser = c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);

            test_obj = DataMessage(123456789);

            ser = c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);

            test_obj = DataMessage('This is a test message');

            ser = c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec);
        end

        %------------------------------------------------------------------
        function DISABLED_test_ser_datamessage_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            ser = c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function DISABLED_test_ser_pixdata(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = PixelData();

            ser = c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test null
        function test_ser_array_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [];
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);

            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Logicals
        %------------------------------------------------------------------
        function test_ser_logical_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = true;
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_logical_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [true, true, true];
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Characters
        %------------------------------------------------------------------
        function test_ser_chararray_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = '';
            ser = c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 'BEEP';
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_chararray_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Doubles
        %------------------------------------------------------------------
        function test_ser_double_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 10;
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_list(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 1:10;
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_double_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [1:10;1:10];
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Complexes
        %------------------------------------------------------------------
        function test_ser_complex_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = 3+4i;
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  c_serialise(test_obj);
            test_obj_rec = c_deserialise(ser);
            assertEqual(test_obj, test_obj_rec)
        end

        %% Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct([]);
            ser =  c_serialise(test_struct);
            test_struct_rec = c_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct();
            ser =  c_serialise(test_struct);
            test_struct_rec = c_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_scalar(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  c_serialise(test_struct);
            test_struct_rec = c_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_list(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  c_serialise(test_struct);
            test_struct_rec = c_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %------------------------------------------------------------------
        function test_ser_struct_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = c_serialise(test_struct);
            test_struct_rec = c_deserialise(ser);
            assertEqual(test_struct, test_struct_rec)
        end

        %% Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[],[]);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_empty(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[],[],10,10);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_single(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(eye(1));
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = speye(10);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[], complex([],[]));
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse([],[],complex([],[]),10,10);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(1, 1, 1i);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_list(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(1:10, 1, 1i);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_sparse = sparse(1:10, 1:10, 1i);
            ser =  c_serialise(test_sparse);
            test_sparse_rec = c_deserialise(ser);
            assertEqual(test_sparse, test_sparse_rec)
        end

        %% Test Function handle
        %------------------------------------------------------------------
        function test_ser_function_handle(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_func = @(x, y) (x^2 + y^2);
            ser = c_serialise(test_func);
            test_func_rec = c_deserialise(ser);
            assertEqual(func2str(test_func), func2str(test_func_rec))
        end

        %------------------------------------------------------------------
        function test_ser_function_handle_standard_func(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_func = @sin;
            ser = c_serialise(test_func);
            test_func_rec = c_deserialise(ser);
            assertEqual(func2str(test_func), func2str(test_func_rec))
        end

        %% Test Cell Array
        %------------------------------------------------------------------
        function test_ser_cell_null(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1 2 3 4};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_complex(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_mixed_complex(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1+2i 2 3+1i 4};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_cell(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_bool(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {true false false true false};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_string(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_function_handles(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            test_cell = cellfun(@func2str, test_cell, 'UniformOutput',false);
            test_cell_rec = cellfun(@func2str, test_cell_rec, 'UniformOutput',false);
            assertEqual(test_cell, test_cell_rec)
        end

        %------------------------------------------------------------------
        function test_ser_cell_hetero(this)
            if ~this.use_mex
                skipTest('MEX not enabled');
            end
            test_cell = {1, 'a', 1+2i, true, struct('boop', 1), {'Hello'}, @(x,y) (x+y^2)};
            ser =  c_serialise(test_cell);
            test_cell_rec = c_deserialise(ser);
            test_cell{7} = func2str(test_cell{7});
            test_cell_rec{7} = func2str(test_cell_rec{7});
            assertEqual(test_cell, test_cell_rec)
        end
        function test_deserialize_invalid(obj)
            skipTest('invalid arguments test disabled #817')
            if ~obj.use_mex
                skipTest('MEX not enabled');
            end
            input = 'wrong input';
            [a,n]=hlp_deserialise(input);
            assertExcetionThrown(@()c_deserialise(input),'');

        end

    end
end