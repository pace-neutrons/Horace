classdef test_instr_proj_construction<TestCase
    % Test operations necessary to build class, responsible 
    % for projection between instrument frame and crystal Cartesian
    % coordinate system
    %
    properties
        tests_folder
    end

    methods
        function this=test_instr_proj_construction(varargin)
            if nargin == 0
                name = 'test_instr_proj_construction';
            else
                name = varargin{1};
            end
            this=this@TestCase(name);
        end
        function test_invalid_constructor_throws(~)
            assertExceptionThrown(@()instr_proj([],10,1),...
                'HORACE:instr_proj:invalid_argument');
            assertExceptionThrown(@()instr_proj(oriented_lattice(),0,1),...)
                'HORACE:instr_proj:invalid_argument');
            assertExceptionThrown(@()instr_proj(oriented_lattice(),10,4),...)
                'HORACE:instr_proj:invalid_argument');
        end

        function test_constructor(~)
            lat = oriented_lattice([1,2,3],[90,90,90]);
            proj = instr_proj(lat,10);

            assertEqual(proj.alatt,[1,2,3])
            assertEqual(proj.angdeg,[90,90,90])
            assertEqual(proj.efix,10)
            assertEqual(proj.emode,1)
            assertEqual(proj.lattice,lat)
        end
    end
end
