classdef test_crystal_alignment_info < TestCase
    % Tests for crystal_alignment_info_class
    %
    properties
    end

    methods
        function obj=test_crystal_alignment_info(varargin)
            if nargin == 0
                name = 'test_crystal_alignment_info';
            else
                name = varargin{1};
            end
            obj = obj@TestCase(name);

        end
        %------------------------------------------------------------------
        function test_set_rotvec_sets_rotmat(~)

            cal = crystal_alignment_info();
            assertElementsAlmostEqual(cal.rotvec,zeros(1,3))
            assertElementsAlmostEqual(cal.rotmat,eye(3))

            cal.rotvec = [pi/4,0,0];

            rm = [...
                1          0              0;
                0      1/sqrt(2)  1/sqrt(2);...
                0     -1/sqrt(2)  1/sqrt(2)];
            assertElementsAlmostEqual(cal.rotvec,[pi/4,0,0]);
            assertElementsAlmostEqual(cal.rotmat,rm);
        end
        function test_set_rotmat_sets_rotvec(~)
            rotvec = [0,0,0];

            cal = crystal_alignment_info('rotvec',rotvec);
            assertElementsAlmostEqual(cal.rotvec,zeros(1,3))
            assertElementsAlmostEqual(cal.rotmat,eye(3))


            rm = [...
                1/sqrt(2)  1/sqrt(2)    0;...
                -1/sqrt(2) 1/sqrt(2)    0;...
                0          0            1];
            cal.rotmat = rm;
            assertElementsAlmostEqual(cal.rotmat,rm)
            assertElementsAlmostEqual(cal.rotvec,[0,0,pi/4])
        end
        %------------------------------------------------------------------
        function test_construction(~)
            alatt  = [1,2,3];
            angdeg = [70,80,110];
            rotvec = [0,0,pi/4];
            dist   = [0.1,0.1,0.01];

            cal = crystal_alignment_info(alatt,angdeg,rotvec,dist);

            assertElementsAlmostEqual(cal.alatt,alatt);
            assertElementsAlmostEqual(cal.angdeg,angdeg);
            assertElementsAlmostEqual(cal.distance,dist);
            assertElementsAlmostEqual(cal.rotvec,rotvec)
            rm = [...
                1/sqrt(2)  1/sqrt(2)    0;...
                -1/sqrt(2) 1/sqrt(2)    0;...
                0          0            1];
            assertElementsAlmostEqual(cal.rotmat,rm)
            assertEqual(cal.rotangle,rad2deg(pi/4))
            assertFalse(cal.hkl_mode)
        end
        function test_empty_constructor(~)
            cal = crystal_alignment_info();

            assertElementsAlmostEqual(cal.alatt,[2*pi,2*pi,2*pi]);
            assertElementsAlmostEqual(cal.angdeg,[90,90,90]);
            assertTrue(isempty(cal.distance))
            assertElementsAlmostEqual(cal.rotvec,zeros(1,3))
            assertElementsAlmostEqual(cal.rotmat,eye(3))
            assertEqual(cal.rotangle,0)
            assertFalse(cal.hkl_mode)
        end
    end
end
