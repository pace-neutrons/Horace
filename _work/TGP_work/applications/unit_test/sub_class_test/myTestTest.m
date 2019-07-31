classdef myTestTest < TestCaseWithSaveCrap
    % See <a href="matlab:help('equal_to_tol');">equal_to_tol</a>
    % And if you are desperate
    % See <a href="matlab:help('sqw/equal_to_tol');">sqw/equal_to_tol</a>
    properties
        fh
    end

    methods
        function self = myTestTest(name)
            self = self@TestCaseWithSaveCrap(name);
            disp('Constructor call')
        end

        function setUp(self)
            disp('Setup')
            self.fh = figure;
        end

        function tearDown(self)
            disp('Teardown')
            delete(self.fh);
        end

        function testColormapColumns(self)
            assertEqual(size(get(self.fh, 'Colormap'), 2), 3);
        end

        function testPointer(self)
            assertEqual(get(self.fh, 'Pointer'), 'arrow');
        end
        
        function testDoggy(self)
            aaa=39;
            bbb=99;
            assertVectorsAlmostEqual(aaa,bbb,'Fuckit!!!');
        end
        
    end
end
