classdef test_head < TestCase
    %
    % Validate fast sqw reader used in combining sqw
    %
    %
    properties
        test_dir;
        files;
    end

    methods
        function obj = test_head(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            obj=obj@TestCase(name);

            obj.test_dir = fileparts(fileparts(mfilename('fullpath')));
            obj.files = {fullfile(obj.test_dir,'test_sqw_file','test_sqw_file_read_write_v3_1.sqw'),...
                fullfile(obj.test_dir,'test_sqw_file','test_sqw_file_read_write_v3.sqw'),...
                fullfile(obj.test_dir,'test_symmetrisation','w2d_qq_d2d.sqw')};
        end
        function setUp(~)
            warning('off','SQW_FILE_IO:legacy_data');
        end
        function tearDown(~)
            warning('on','SQW_FILE_IO:legacy_data');
        end
       

        function test_head_horace_multiout(obj)
            [out1,out2,out3] = head_horace(obj.files,'-full');
            assertEqual(numel(fields(out1)),22)
            assertEqual(numel(fields(out2)),22)
            assertEqual(numel(fields(out3)),18)
        end
        function test_head_dnd_vs_head_horace(obj)

            out = head_dnd(obj.files{3});
            assertTrue(isstruct(out))
            assertEqual(numel(fields(out)),15)

            out4 = head_horace(obj.files{3});
            assertTrue(isstruct(out4))
            assertEqual(numel(fields(out4)),15)
            assertEqual(out,out4);
        end

        function test_head_file_wrapper_output_parsing(obj)
            [out1,out2] = head_horace(obj.files,'-full');

            [out1a,out2a] = head(obj.files,'-full');
            assertEqual(out1,out1a)
            assertEqual(out2,out2a)

            out3a = head(obj.files{3},'-full');

            outc = head(obj.files,'-full');
            assertEqual(numel(outc),3)
            assertEqual(outc{1},out1)
            assertEqual(outc{2},out2)
            assertEqual(outc{3},out3a)
        end
        function test_head_horace_cell_output(obj)

            out = head_sqw(obj.files);
            %head_sqw(files);

            assertEqual(numel(out),3)
            assertTrue(isstruct(out{1}))
            assertEqual(numel(fields(out{1})),19)
            assertTrue(isstruct(out{2}))
            assertEqual(numel(fields(out{2})),19)
            assertTrue(isstruct(out{3}))
            assertEqual(numel(fields(out{3})),15)
        end

    end
end