classdef test_pixobj_combine_info < TestCase
    % Series of tests to check validity of pixobj_combine_info class

    properties
        npix_tst = [10,15,20]
        pix_obj;
        pix_obj_range;
    end

    methods
        function obj=test_pixobj_combine_info(varargin)
            if nargin<1
                name = 'test_pixobj_combine_info';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.pix_obj = cell(3,1);
            for i=1:3
                obj.pix_obj{i} = PixelDataMemory(rand(9,obj.npix_tst(i)));
            end
            obj.pix_obj_range = obj.pix_obj{1}.data_range;
            for i=2:3
                obj.pix_obj_range = minmax_ranges(obj.pix_obj_range,obj.pix_obj{i}.data_range);
            end

        end

        function test_serialize_deserialize(obj)
            nbins = 10000;
            pc = pixobj_combine_info(obj.pix_obj,nbins);
            pc_str = pc.saveobj();

            pcr = serializable.loadobj(pc_str);

            assertEqual(pc,pcr);
        end

        function test_only_simple_constructor(obj)
            nbins = 10000;
            pc = pixobj_combine_info(obj.pix_obj,nbins);
            assertEqual(pc.nfiles,3);
            assertEqual(pc.num_pixels,sum(obj.npix_tst));
            assertEqual(pc.nbins,10000);

            assertEqual(pc.infiles,obj.pix_obj);
            assertEqual(pc.npix_each_file,obj.npix_tst)

            assertEqual(pc.run_label,'nochange');
            assertFalse(pc.change_fileno)
            assertFalse(pc.relabel_with_fnum)
            assertEqual(pc.data_range,obj.pix_obj_range);

        end

        function test_only_fnames_constructor(obj)
            pc = pixobj_combine_info(obj.pix_obj);
            assertEqual(pc.nfiles,3);
            assertEqual(pc.num_pixels,sum(obj.npix_tst));
            assertEqual(pc.nbins,0);

            assertEqual(pc.infiles,obj.pix_obj);
            assertEqual(pc.npix_each_file,obj.npix_tst)

            assertEqual(pc.run_label,'nochange');
            assertFalse(pc.change_fileno)
            assertFalse(pc.relabel_with_fnum)
            assertEqual(pc.data_range,obj.pix_obj_range);
        end

        function test_empty_constructor(~)
            pc = pixobj_combine_info();
            assertEqual(pc.nfiles,0);
            assertEqual(pc.num_pixels,0);
            assertEqual(pc.nbins,0);

            assertTrue(isempty(pc.infiles));
            assertTrue(isempty(pc.npix_each_file))

            assertEqual(pc.run_label,'nochange');
            assertFalse(pc.change_fileno);
            assertFalse(pc.relabel_with_fnum);

            assertEqual(pc.pix_range,PixelDataBase.EMPTY_RANGE_);

        end
    end
end
