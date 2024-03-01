classdef test_pixfile_combine_info < TestCase
    % Series of tests to check work of mex files against Matlab files

    properties
        out_dir=tmp_dir();
    end

    methods
        function obj=test_pixfile_combine_info(varargin)
            if nargin<1
                name = 'test_pixfile_combine_info';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

        end

        function test_serialize_deserialize(~)
            files = {'file_a','file_b','file_c'};
            nbins = 10000;
            pos_npixstart = zeros(3,1);
            pos_pixstart = ones(3,1)*nbins;
            npix_each_file = ones(3,1)*1000; % 3 files, 1000 pix each
            pc = pixfile_combine_info(files,nbins,npix_each_file,pos_npixstart, ...
                pos_pixstart);
            pc_str = pc.saveobj();

            pcr = serializable.loadobj(pc_str);

            assertEqual(pc,pcr);
        end

        function test_wrong_constructor_inconsistent_positions(~)
            files = {'file_a','file_b','file_c'};
            nbins = 10000;
            pos_npixstart = zeros(2,1);
            pos_pixstart = ones(3,1)*nbins;
            npix_each_file = ones(3,1)*1000; % 3 files, 1000 pix each

            assertExceptionThrown(@()pixfile_combine_info(files,nbins,npix_each_file,pos_npixstart, ...
                pos_pixstart),...
                'HORACE:pixfile_combine_info:invalid_argument');
            pos_npixstart = zeros(3,1);
            pos_pixstart = ones(2,1)*nbins;
            assertExceptionThrown(@()pixfile_combine_info(files,nbins,npix_each_file,pos_npixstart, ...
                pos_pixstart),...
                'HORACE:pixfile_combine_info:invalid_argument');
            pos_pixstart = ones(3,1)*nbins;
            npix_each_file = ones(2,1)*1000; % 3 files, 1000 pix each

            assertExceptionThrown(@()pixfile_combine_info(files,nbins,npix_each_file,pos_npixstart, ...
                pos_pixstart),...
                'HORACE:pixfile_combine_info:invalid_argument');

        end

        function test_only_simple_constructor(~)
            files = {'file_a','file_b','file_c'};
            nbins = 10000;
            pos_npixstart = zeros(3,1);
            pos_pixstart = ones(3,1)*nbins;
            npix_each_file = ones(3,1)*1000; % 3 files, 1000 pix each
            pc = pixfile_combine_info(files,nbins,npix_each_file,pos_npixstart, ...
                pos_pixstart);
            assertEqual(pc.nfiles,3);
            assertEqual(pc.num_pixels,uint64(3*1000));
            assertEqual(pc.nbins,10000);

            assertEqual(pc.infiles,{'file_a','file_b','file_c'}');
            assertEqual(pc.npix_each_file,npix_each_file')
            assertEqual(pc.pos_npixstart,pos_npixstart')
            assertEqual(pc.pos_pixstart,pos_pixstart')

            assertEqual(pc.run_label,'nochange');
            assertFalse(pc.change_fileno)
            assertFalse(pc.relabel_with_fnum)
            assertEqual(pc.pix_range,PixelDataBase.EMPTY_RANGE_);

        end

        function test_only_fnames_constructor(~)
            pc = pixfile_combine_info({'file_a','file_b','file_c'});
            assertEqual(pc.nfiles,3);
            assertEqual(pc.num_pixels,0);
            assertEqual(pc.nbins,0);

            assertEqual(pc.infiles,{'file_a','file_b','file_c'}');
            assertEqual(pc.npix_each_file,zeros(1,3))
            assertEqual(pc.pos_pixstart,zeros(1,3))
            assertEqual(pc.pos_npixstart,zeros(1,3))

            assertEqual(pc.run_label,'nochange');
            assertFalse(pc.change_fileno)
            assertFalse(pc.relabel_with_fnum)
            assertEqual(pc.pix_range,PixelDataBase.EMPTY_RANGE_);

        end

        function test_empty_constructor(~)
            pc = pixfile_combine_info();
            assertEqual(pc.nfiles,0);
            assertEqual(pc.num_pixels,0);
            assertEqual(pc.nbins,0);

            assertTrue(isempty(pc.infiles));
            assertTrue(isempty(pc.npix_each_file))
            assertTrue(isempty(pc.pos_pixstart))
            assertTrue(isempty(pc.pos_npixstart))

            assertEqual(pc.run_label,'nochange');
            assertFalse(pc.change_fileno);
            assertFalse(pc.relabel_with_fnum);

            assertEqual(pc.pix_range,PixelDataBase.EMPTY_RANGE_);

        end
    end
end
