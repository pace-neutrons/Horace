classdef test_fake_sqw < TestCase
    % Test fake_sqw routine
    %
    %---------------------------------------------------------------------
    % Usage:
    %
    %>>runtests test_fake_sqw
    % run all unit tests class contains
    % or
    %>>runtests test_fake_sqw:test_det_from_q
    %run the particular test
    % or
    %>>tc = test_gen_sqw_accumulate_sqw_sep_session();
    %>>tc.test_det_from_q()
    %Run particular test saving construction time.
    properties
        working_dir
        % test parameters file, used in fake_sqw calculations
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
        function obj=test_fake_sqw(test_class_name)
            % The constructor fake_sqw class
            
            if ~exist('test_class_name','var')
                test_class_name = 'test_fake_sqw';
            end
            
            obj = obj@TestCase(test_class_name);
            obj.working_dir = tmp_dir;
            
            data_path = fileparts(mfilename('fullpath'));
            %this.par_file=fullfile(this.results_path,'96dets.par');
            obj.par_file=fullfile(data_path,'gen_sqw_96dets.nxspe');
        end
        function test_det_from_q_invalid(obj)
            f = @()build_det_from_q_range('wrong_detpar',obj.gen_sqw_par{:});
            
            assertExceptionThrown(f,'FAKE_SQW:invalid_argument');
            
            f = @()build_det_from_q_range(ones(3,1),obj.gen_sqw_par{:});
            assertExceptionThrown(f,'FAKE_SQW:invalid_argument');
            
        end
        function test_det_from_q(obj)
            % check if build_det_from_q_range is working and producing
            % reasonable result.
            det=build_det_from_q_range([0,0.1,1],obj.gen_sqw_par{2:end});
            assertTrue(isstruct(det));
            assertEqual(numel(det.group),11*11*11)
            
            det=build_det_from_q_range([0,0.1,1;0,0.2,2;0,0.3,3],...
                obj.gen_sqw_par{2:end});
            assertTrue(isstruct(det));
            assertEqual(numel(det.group),11*11*11)
            
        end
        %
        function test_build_fake_sqw(obj)
            % build fake sqw using detector positions and without detector
            % positions.
            tsqw = fake_sqw(-0.5:1:obj.gen_sqw_par{2}-5, obj.par_file, '',...
                obj.gen_sqw_par{2},obj.gen_sqw_par{1},...
                obj.gen_sqw_par{3:end});
            tsqw = tsqw{1};
            
            assertTrue(isa(tsqw,'sqw'));
            
            pix = tsqw.data.pix(1:4,:);
            de0 = pix(4,:)==0;
            assertEqual(sum(de0),96);
            
            q_range = pix(1:3,de0); % this is q-range in crystal catresizan
            u_to_rlu = tsqw.data.u_to_rlu(1:3,1:3);
            q_range = (u_to_rlu*q_range)' ; % convert q into hkl
            % verify the fact that the detector positions, processed from
            % the pixel information provide the same result as normal
            % detector positions
            tsqw2 = fake_sqw(-0.5:1:obj.gen_sqw_par{2}-5, q_range , '',...
                obj.gen_sqw_par{2},obj.gen_sqw_par{1},...
                obj.gen_sqw_par{3:end});
            
            tsqw2 = tsqw2{1};
            pix1 = tsqw2.data.pix(1:4,:);
            assertElementsAlmostEqual(pix,pix1,'absolute',1.e-7);
        end
    end
end
