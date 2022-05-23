classdef test_cut_data_from_file_job < TestCase
    % Testing cut_data_from_file_job methods
    %
    properties
        data_folder;
        par_file
        test_sqw;
    end

    methods

        function obj = test_cut_data_from_file_job(varargin)
            if nargin == 0
                name = 'test_cut_data_from_file_job';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);
            obj.data_folder = fullfile(fileparts(fileparts(mfilename('fullpath'))),...
                'common_data');
            obj.par_file = fullfile(obj.data_folder,'96dets.par');
            fso = fake_sqw (0:10:100, obj.par_file, '', 110, 1, ...
                [3,3.1,3], [90,90,90],...
                [1,0,0], [0,1,0], 10, 0, 0, 0, 0, [5,5,5,5]);
            obj.test_sqw = fso{1};
        end
        %
        function test_bin_pixels_wrong_inputs(obj)
            dat = obj.test_sqw.data;
            proj = dat.get_projection();
            axes = dat;
            pix = obj.test_sqw.pix;
            npix0 = zeros(size(dat.npix));
            s0    = zeros(size(dat.npix));

            assertExceptionThrown(@()cut_data_from_file_job.bin_pixels(...
                proj, axes,pix,npix0,s0), ...
                'HORACE:cut_data_from_file_job:invalid_argument');
            assertExceptionThrown(@()cut_data_from_file_job.bin_pixels(...
                proj, axes,pix,npix0,s0,'-force_double'), ...
                'HORACE:cut_data_from_file_job:invalid_argument');

        end
        %
        function test_bin_pixels_6inputs(obj)
            dat = obj.test_sqw.data;
            proj = dat.get_projection();
            axes = dat;
            pix = obj.test_sqw.pix;
            npix0 = zeros(size(dat.npix));
            s0    = zeros(size(dat.npix));
            e0    = zeros(size(dat.npix));
            [npix,s,e,pix_ok,unique_runid,pix_indx] = ...
                cut_data_from_file_job.bin_pixels(proj, axes,pix,npix0,s0,e0);
            [s,e] = normalize_signal(s,e,npix);

            assertEqual(dat.npix,npix);
            assertEqual(dat.s,s);
            assertEqual(dat.e,e);
            assertEqual(pix,pix_ok)
            assertEqual(unique_runid,1)
            npc = accumarray(pix_indx, ones(1,size(pix_indx,1)), [numel(npix),1]);
            assertEqual(npix(:),npc);
        end

        %
        function test_bin_pixels_4inputs(obj)
            dat = obj.test_sqw.data;
            proj = dat.get_projection();
            axes = dat;
            pix = obj.test_sqw.pix;
            npix0 = zeros(size(dat.npix));
            [npix,s,e,pix_ok,unique_runid,pix_indx] = ...
                cut_data_from_file_job.bin_pixels(proj, axes,pix,npix0);
            [npix1,s1,e1,pix_ok1,unique_runid1,pix_indx1] = ...
                cut_data_from_file_job.bin_pixels(proj, axes,pix,npix0,'-force_double');
            assertEqual(npix,npix1);
            assertEqual(s,s1);
            assertEqual(e,e1);
            assertEqual(pix_ok,pix_ok1);
            assertEqual(unique_runid,unique_runid1);
            assertEqual(pix_indx,pix_indx1);

            [s,e] = normalize_signal(s,e,npix);



            assertEqual(dat.npix,npix);
            assertEqual(dat.s,s);
            assertEqual(dat.e,e);
            assertEqual(pix,pix_ok)
            assertEqual(unique_runid,1)
            npc = accumarray(pix_indx, ones(1,size(pix_indx,1)), [numel(npix),1]);
            assertEqual(npix(:),npc);
        end

        function test_bin_pixels_3inputs(obj)
            dat = obj.test_sqw.data;
            proj = dat.get_projection();
            axes = dat;
            pix = obj.test_sqw.pix;
            [npix,s,e,pix_ok,unique_runid,pix_indx] = ...
                cut_data_from_file_job.bin_pixels(proj, axes,pix);
            [npix1,s1,e1,pix_ok1,unique_runid1,pix_indx1] = ...
                cut_data_from_file_job.bin_pixels(proj, axes,pix,'-force_double');
            assertEqual(npix,npix1);
            assertEqual(s,s1);
            assertEqual(e,e1);
            assertEqual(pix_ok,pix_ok1);
            assertEqual(unique_runid,unique_runid1);
            assertEqual(pix_indx,pix_indx1);

            [s,e] = normalize_signal(s,e,npix);

            assertEqual(dat.npix,npix);
            assertEqual(dat.s,s);
            assertEqual(dat.e,e);
            assertEqual(pix,pix_ok)
            assertEqual(unique_runid,1)
            npc = accumarray(pix_indx, ones(1,size(pix_indx,1)), [numel(npix),1]);
            assertEqual(npix(:),npc);
        end
        %
    end

end
