classdef test_serialize < TestCase
    properties
        use_mex;
    end

    methods
        function this=test_serialize(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialize';
            end
            this = this@TestCase(name);

            this.use_mex = hor_config().use_mex;

        end

        function this = setUp(this)
            hbc = hor_config;
            hbc.use_mex = false;
        end


        function this = tearDown(this)
            hbc = hor_config;
            hbc.use_mex = this.use_mex;
        end

        %------------------------------------------------------------------

        function test_ser_sample(~)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = hlp_serialize(sam1);
            size = hlp_serial_size(sam1);
            assertEqual(numel(bytes),size);

            [sam1rec,nbytes] = hlp_deserialize(bytes);
            assertEqual(nbytes,size);
            assertEqual(sam1,sam1rec);

            sam2=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);

            bytes = hlp_serialize(sam2);
            size = hlp_serial_size(sam1);
            assertEqual(numel(bytes),size);

            [sam2rec,nbytes] = hlp_deserialize(bytes);
            assertEqual(nbytes,size);
            assertEqual(sam2,sam2rec);

        end

        %------------------------------------------------------------------
        function test_ser_instrument(~)

            % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            bytes = hlp_serialize(inst1);
            inst1rec = hlp_deserialize(bytes);
            assertEqual(inst1,inst1rec);
            size = hlp_serial_size(inst1);
            assertEqual(size,numel(bytes));

            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            bytes = hlp_serialize(inst2);
            inst2rec = hlp_deserialize(bytes);
            assertEqual(inst2,inst2rec );
            size = hlp_serial_size(inst2);
            assertEqual(size,numel(bytes));


            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            bytes = hlp_serialize(inst3);
            inst3rec = hlp_deserialize(bytes);
            assertEqual(inst3,inst3rec );
            size = hlp_serial_size(inst3);
            assertEqual(size,numel(bytes));
        end


        %------------------------------------------------------------------
        function test_ser_datamessage(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = DataMessage(my_struc);

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec);
            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));


            test_obj = DataMessage(123456789);

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec);
            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));


            test_obj = DataMessage('This is a test message');

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec);
            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_datamessage_array(~)
            my_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            test_obj = [DataMessage(my_struc), DataMessage(10), DataMessage('Hello')];

            ser = hlp_serialize(test_obj);
            [test_obj_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(numel(ser),nbytes);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_pixdata(~)
            skipTest('PixelData serialisation is not implemented yet')
            test_obj = PixelDataBase.create();

            ser = hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        % Test null
        function test_ser_array_null(~)
            test_obj = [];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);

            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        % Test Logicals
        %------------------------------------------------------------------
        function test_ser_logical_scalar(~)
            test_obj = true;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_logical_array(~)
            test_obj = [true, true, true];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        % Test Characters
        %------------------------------------------------------------------
        function test_ser_chararray_null(~)
            test_obj = '';
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_chararray_scalar(~)
            test_obj = 'BEEP';
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_chararray_array(~)
            test_obj = ['BEEP','BOOP'; 'BLORP', 'BOP'];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));

        end

        % Test Doubles
        %------------------------------------------------------------------
        function test_ser_double_scalar(~)
            test_obj = 10;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_double_list(~)
            test_obj = 1:10;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_double_array(~)
            test_obj = [1:10;1:10];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));
        end

        % Test Complexes
        %------------------------------------------------------------------
        function test_ser_complex_scalar(~)
            test_obj = 3+4i;
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_complex_array(~)
            test_obj = [3+4i, 5+7i; 2+1i, 1-1i];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_mixed_complex_array(~)
            test_obj = [3+4i, 2; 3+5i, 0];
            ser =  hlp_serialize(test_obj);
            test_obj_rec = hlp_deserialize(ser);
            assertEqual(test_obj, test_obj_rec)

            size = hlp_serial_size(test_obj);
            assertEqual(size,numel(ser));

        end

        % Test Structs
        %------------------------------------------------------------------
        function test_ser_struct_null(~)
            test_struct = struct([]);
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)

            size = hlp_serial_size(test_struct);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_struct_empty(~)
            test_struct = struct();
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)

            size = hlp_serial_size(test_struct);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_struct_scalar(~)
            test_struct = struct('Hello', 13, 'Goodbye', 7, 'Beef', {{1, 2, 3}});
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)

            size = hlp_serial_size(test_struct);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_struct_list(~)
            test_struct = struct('HonkyTonk', {1, 2, 3});
            ser =  hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)

            size = hlp_serial_size(test_struct);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_struct_array(~)
            test_struct = struct('HonkyTonk', {1, 2, 3; 4, 5, 6; 7, 8, 9});
            ser = hlp_serialize(test_struct);
            test_struct_rec = hlp_deserialize(ser);
            assertEqual(test_struct, test_struct_rec)

            size = hlp_serial_size(test_struct);
            assertEqual(size,numel(ser));

        end

        % Test Sparse
        %------------------------------------------------------------------
        function test_ser_real_sparse_null(~)
            test_sparse = sparse([],[],[]);
            ser =  hlp_serialize(test_sparse);
            [test_sparse_rec,nBytes] = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)
            assertEqual(numel(ser),nBytes);

            size = hlp_serial_size(test_sparse);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
                function test_ser_real_sparse_empty(~)
                    test_sparse = sparse([],[],[],10,10);
                    ser =  hlp_serialize(test_sparse);
                    test_sparse_rec = hlp_deserialize(ser);
                    assertEqual(test_sparse, test_sparse_rec)

                    size = hlp_serial_size(test_sparse);
                    assertEqual(size,numel(ser));

                end

        %------------------------------------------------------------------
        function test_ser_real_sparse_single(~)
            test_sparse = sparse(eye(1));
            ser =  hlp_serialize(test_sparse);
            test_sparse_rec = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)

            size = hlp_serial_size(test_sparse);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_real_sparse_array(~)
            test_sparse = sparse(eye(10));
            ser =  hlp_serialize(test_sparse);
            test_sparse_rec = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)

            size = hlp_serial_size(test_sparse);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_null(~)
            test_sparse = sparse([],[], complex([],[]));
            ser =  hlp_serialize(test_sparse);
            test_sparse_rec = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)

            size = hlp_serial_size(test_sparse);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_empty(~)
            test_sparse = sparse([],[],complex([],[]),10,10);
            ser =  hlp_serialize(test_sparse);
            [test_sparse_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes,numel(ser));
            assertEqual(test_sparse, test_sparse_rec)

            sze = hlp_serial_size(test_sparse);
            assertEqual(sze,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_single(~)
            test_sparse = sparse(1, 1, 1i);
            ser =  hlp_serialize(test_sparse);
            [test_sparse_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes, numel(ser));
            assertEqual(test_sparse, test_sparse_rec)

            size = hlp_serial_size(test_sparse);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_complex_sparse_array(~)
            test_sparse = sparse(1:10, 1, 1i);
            ser =  hlp_serialize(test_sparse);
            test_sparse_rec = hlp_deserialize(ser);
            assertEqual(test_sparse, test_sparse_rec)

            size = hlp_serial_size(test_sparse);
            assertEqual(size,numel(ser));

        end

        % Test Function handle
        function test_ser_function_handle(~)
            test_func = @(x, y) (x^2 + y^2);
            ser = hlp_serialize(test_func);

            size = hlp_serial_size(test_func);
            assertEqual(size,numel(ser));


            [test_func_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes,size);

            assertEqual(func2str(test_func), func2str(test_func_rec))

        end

        % Test Cell Array
        %------------------------------------------------------------------
        function test_ser_cell_null(~)
            test_cell = {};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric(~)
            test_cell = {1 2 3 4};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_numeric_array(~)
            test_cell = {1 2 3; 4 5 6; 7 8 9};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_complex(~)
            test_cell = {1+2i 2+3i 3+1i 4+10i};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_mixed_complex(~)
            test_cell = {1+2i 2 3+1i 4};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_cell(~)
            test_cell = {{1 2} {3 4} {4 5} {6 7}};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_bool(~)
            test_cell = {true false false true false};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_string(~)
            test_cell = {'Hello' 'is' 'it' 'me' 'youre' 'looking' 'for'};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_structs(~)
            test_cell = {struct('Hello', 5), struct('Goodbye', 'Chicken')};
            ser =  hlp_serialize(test_cell);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_cell, test_cell_rec)

            size = hlp_serial_size(test_cell);
            assertEqual(size,numel(ser));

        end

        %------------------------------------------------------------------
        function test_ser_struct_of_structs(~)
            test_str1.val1=struct('Hello', 5);
            test_str1.val2=struct('Goodbye', 'Chicken');
            test_str2.val1=struct('Hell', 5);
            test_str2.val2=struct('Dear', 'Goblin');
            test_str = [test_str1,test_str2];

            ser =  hlp_serialize(test_str);
            test_cell_rec = hlp_deserialize(ser);
            assertEqual(test_str, test_cell_rec)

            size = hlp_serial_size(test_str);
            assertEqual(size,numel(ser));
        end

        %------------------------------------------------------------------
        function test_ser_cell_homo_function_handles(~)
            test_cell = {@(x,y) (x+y^2), @(a,b) (b-a)};
            ser =  hlp_serialize(test_cell);
            siz = hlp_serial_size(test_cell);
            assertEqual(numel(ser),siz);
            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(nbytes,siz);

            test_cell = cellfun(@func2str, test_cell, 'UniformOutput',false);
            test_cell_rec = cellfun(@func2str, test_cell_rec, 'UniformOutput',false);
            assertEqual(test_cell, test_cell_rec)

        end

        %------------------------------------------------------------------
        function test_ser_cell_hetero(~)
            test_cell = {1,[1,2], 'a', 1+2i, true, struct('boop', 1),...
                {'Hello'}, @(x,y)(x+y^2)};
            ser =  hlp_serialize(test_cell);
            sze = hlp_serial_size(test_cell);
            assertEqual(sze,numel(ser));

            [test_cell_rec,nbytes] = hlp_deserialize(ser);
            assertEqual(sze,nbytes);

            test_cell{8} = func2str(test_cell{8});
            test_cell_rec{8} = func2str(test_cell_rec{8});
            assertEqual(test_cell, test_cell_rec)
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
                        [type_rec,nDims,fh_id,pos] = ...
                            hlp_serial_types.unpack_data_tag(packed_tag,1);
                        tag_size = ...
                            hlp_serial_types.calc_tag_size([],type_str,fh_types{fhn});

                        assertEqual(type_rec,type_str);
                        assertEqual(tag_size,numel(packed_tag))
                        assertEqual(nDims,1);
                        assertEqual(pos, numel(packed_tag)+1);
                        assertEqual(fh_id, hlp_serial_types.fh_map(fh_types{fhn}));

                    end

                else
                    if strncmp(type_str.name,'sparse',6)
                        addarg = {1};
                    else
                        addarg = {};
                    end

                    for nShape = 1:numel(shapes)
                        sh_size =  shapes{nShape};

                        packed_tag = hlp_serial_types.pack_data_tag(...
                            sh_size,type_str,addarg{:});
                        [type_rec, nDims_rec,size_rec,pos] = ...
                            hlp_serial_types.unpack_data_tag(packed_tag,1);
                        tag_size = ...
                            hlp_serial_types.calc_tag_size(sh_size,type_str,addarg{:});

                        assertEqual(type_rec,type_str);
                        if ~isempty(size_rec) && size_rec(1) ==1 && numel(size_rec) == 2 && isempty(addarg)
                            assertEqual(nDims_rec,1);
                        else
                            assertEqual(nDims_rec,numel(sh_size));
                        end
                        assertEqual(size_rec,sh_size);
                        assertEqual(pos, numel(packed_tag)+1);
                        assertEqual(tag_size,numel(packed_tag),...
                            sprintf('Error processing element %s, shape %s',...
                            type_str.name,evalc('disp(shapes{nShape})')))

                    end
                end
            end
        end
    end
end