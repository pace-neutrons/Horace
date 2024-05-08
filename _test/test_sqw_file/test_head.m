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

            hc = horace_paths;
            obj.test_dir = hc.test;
            obj.files = {fullfile(obj.test_dir,'test_sqw_file','test_sqw_file_read_write_v3_1.sqw'),...
                fullfile(obj.test_dir,'test_sqw_file','test_sqw_file_read_write_v3.sqw'),...
                fullfile(hc.test_common,'w2d_qq_d2d.sqw')};
        end
        function setUp(~)
            warning('off','SQW_FILE_IO:legacy_data');
        end
        function tearDown(~)
            warning('on','SQW_FILE_IO:legacy_data');
        end
        function test_display_sample(obj)
            % redirect output to text string
            text = evalc('head(obj.files{1})');
            strings = splitlines(text);
            ref_text = {' ';'';...
                '  4-dimensional object:';...
                ' -------------------------';...
                ' Original datafile:  path to: test_sqw_file_read_write_v3_1.sqw';...
                '             Title: <none>';...
                '';' Lattice parameters (Angstroms and degrees):';...
                '     a=4              b=5               c=6          ';...
                ' alpha=91          beta=92          gamma=93         ';...
                '';' Extent of data:';...
                ' Number of spe files: 1';...
                '    Number of pixels: 7680';...
                '';' Size of 4-dimensional dataset: [5x5x5x5]';...
                '     Plot axes:';...
                '          Q_\zeta = -0.81977:0.40721:1.2163 in [Q_\zeta, 0, 0]';...
                '          Q_\xi = -0.32672:0.32652:1.3059 in [0, Q_\xi, 0]';...
                '          Q_\eta = -2.5103:0.36311:-0.69474 in [0, 0, Q_\eta]';...
                '          E = -9.75:7.9:29.75';...
                ' Object is stored in Horace-3.1 format file';...
                '';''};
            assertEqual(numel(strings),numel(ref_text));
            include = true(1,numel(ref_text));
            include(5) = false; % exclude filename with path different on different machines
            is_eq = cellfun(@(x,y)isequal(x,y),strings(include),ref_text(include));
            assertTrue(all(is_eq));
        end

        function test_head_horace_multiout(obj)
            [out1,out2,out3] = head_horace(obj.files,'-full');
            assertEqual(numel(fields(out1)),24)
            assertEqual(numel(fields(out2)),24)
            assertEqual(numel(fields(out3)),21)
        end
        function test_head_dnd_vs_head_horace(obj)

            out = head_dnd(obj.files{3});
            assertTrue(isstruct(out))
            assertEqual(numel(fields(out)),18)

            out4 = head_horace(obj.files{3});
            assertTrue(isstruct(out4))
            assertEqual(numel(fields(out4)),18)

            % old files creation date is dynamic so may be different
            out.creation_date = out4.creation_date;
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
            out1.creation_date = outc{1}.creation_date;
            assertEqual(outc{1},out1)
            out2.creation_date = outc{2}.creation_date;
            assertEqual(outc{2},out2)
            % old files creation date is dynamic so may be different
            out3a.creation_date = outc{3}.creation_date;
            assertEqual(outc{3},out3a)
        end
        function test_head_horace_cell_output(obj)

            out = head_sqw(obj.files);
            %head_sqw(files);

            assertEqual(numel(out),3)
            assertTrue(isstruct(out{1}))
            assertEqual(numel(fields(out{1})),21)
            assertTrue(isstruct(out{2}))
            assertEqual(numel(fields(out{2})),21)
            assertTrue(isstruct(out{3}))
            assertEqual(numel(fields(out{3})),18)
        end

    end
end