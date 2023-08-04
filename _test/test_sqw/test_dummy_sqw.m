classdef test_dummy_sqw < TestCase
    % Test dummy_sqw routine
    %
    %---------------------------------------------------------------------
    % Usage:
    %
    %>>runtests test_dummy_sqw
    % run all unit tests class contains
    % or
    %>>runtests test_dummy_sqw:test_det_from_q
    %run the particular test
    % or
    %>>tc = test_gen_sqw_accumulate_sqw_sep_session();
    %>>tc.test_det_from_q()
    %Run particular test saving construction time.
    properties
        working_dir
        % test parameters file, used in dummy_sqw calculations
        par_file
        % the random parameters for the transformation
        %   {      emode efix,   alatt,     angdeg,         u,               v,            psi,
        gen_sqw_par = {1,35,[4.4,5.5,6.6],[100,105,110],[1.02,0.99,0.02],[0.025,-0.01,1.04],80,...
            10,0.1,3,2.4}; %omega, dpsi, gl, gs};
        % for debugging purposes generate orthogonal projection matrix.
        %         gen_sqw_par = {1,35,[2,2,2],[90,90,90],[1,0,0],[0,0,1],80,...
        %            0,0,0,0}; %omega, dpsi, gl, gs};
    end

    methods
        function obj=test_dummy_sqw(test_class_name)
            % The constructor dummy_sqw class

            if ~exist('test_class_name','var')
                test_class_name = 'test_dummy_sqw';
            end

            obj = obj@TestCase(test_class_name);
            obj.working_dir = tmp_dir;

            common_data = fullfile(fileparts(fileparts(mfilename('fullpath'))),'common_data');
            %this.par_file=fullfile(this.results_path,'96dets.par');
            obj.par_file=fullfile(common_data,'gen_sqw_96dets.nxspe');
        end

        function test_det_from_q_invalid(obj)
            f = @()build_det_from_q_range('wrong_detpar',obj.gen_sqw_par{2:end});

            assertExceptionThrown(f,'HORACE:build_det_from_q_range:invalid_argument');

            f = @()build_det_from_q_range(ones(3,1),obj.gen_sqw_par{2:end});
            assertExceptionThrown(f,'HORACE:build_det_from_q_range:invalid_argument');

        end

        function test_det_from_q_range1D(obj)
            % check if build_det_from_q_range is working and producing
            % reasonable result.
            det=build_det_from_q_range([0,0.1,1],obj.gen_sqw_par{2:end});
            assertTrue(isstruct(det));
            assertEqual(numel(det.group),11*11*11)
        end

        function build_det_from_q_range3D(obj)
            det=build_det_from_q_range([0,0.1,1;0,0.2,2;0,0.3,3],...
                obj.gen_sqw_par{2:end});
            assertTrue(isstruct(det));
            assertEqual(numel(det.group),11*11*11)

        end

        function test_build_dummy_sqw(obj)
            % build dummy sqw using detector positions and without detector
            % positions.
            tsqw = dummy_sqw(-0.5:1:obj.gen_sqw_par{2}-5, obj.par_file, '',...
                obj.gen_sqw_par{2},obj.gen_sqw_par{1},...
                obj.gen_sqw_par{3:end});
            tsqw = tsqw{1};

            assertTrue(isa(tsqw,'sqw'));
            assertTrue(tsqw.main_header.creation_date_defined);

            pix = tsqw.pix.coordinates;
            de0 = pix(4,:)==0; % find the momentum transfers, performed
            %                  % with dE = 0 (elastic mode)
            assertEqual(sum(de0),96);

            q_range = pix(1:3,de0); % this is q-range in crystal catresizan
            bmat = bmatrix(obj.gen_sqw_par{3},obj.gen_sqw_par{4});
            q_range = (bmat\q_range)' ; % convert q into hkl
            % verify the fact that the detector positions, processed from
            % the pixel information provide the same result as normal
            % detector positions
            tsqw2 = dummy_sqw(-0.5:1:obj.gen_sqw_par{2}-5, q_range , '',...
                obj.gen_sqw_par{2},obj.gen_sqw_par{1},...
                obj.gen_sqw_par{3:end});

            tsqw2 = tsqw2{1};
            assertTrue(tsqw2.main_header.creation_date_defined);

            pix1 = tsqw2.pix.coordinates;
            assertElementsAlmostEqual(pix,pix1,'absolute',1.e-7);
        end


        function test_gen_cube_2x2x2x2(obj)
            tsqw = sqw.generate_cube_sqw(2);

            assertTrue(isa(tsqw,'sqw'));
            assertEqual(tsqw.pix.num_pixels, 2^4);

            % Test that all generated coordinates are unique
            tval = tsqw.pix.coordinates';
            assertEqual(unique(tval, 'rows', 'stable'), tval);

            % Test that all values are unique
            tval = tsqw.pix.get_fields({'detector_idx', 'signal', 'variance'})';
            assertEqual(unique(tval, 'rows', 'stable'), tval);

            % One pixel per bin
            assertTrue(all(tsqw.data.npix == 1, 'all'))

        end

        function test_gen_cube_3x3x3x3(obj)
            tsqw = sqw.generate_cube_sqw(3);

            assertTrue(isa(tsqw,'sqw'));
            assertEqual(tsqw.pix.num_pixels, 3^4);

            % Test that all generated coordinates are unique
            tval = tsqw.pix.coordinates';
            assertEqual(unique(tval, 'rows', 'stable'), tval);

            % Test that all values are unique
            tval = tsqw.pix.get_fields({'detector_idx', 'signal', 'variance'})';
            assertEqual(unique(tval, 'rows', 'stable'), tval);

            % One pixel per bin
            assertTrue(all(tsqw.data.npix == 1, 'all'))
        end

    end
end
