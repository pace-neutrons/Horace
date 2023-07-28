classdef test_goniometer< TestCase
    %
    %

    properties
        test_data_path;
    end
    methods
        %
        function this=test_goniometer(varargin)
            if nargin == 0
                name = 'test_goniometer';
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
            pths = horace_paths;
            this.test_data_path = pths.test_common;
        end

        %
        function test_serial_fields(~)
            ol = goniometer(10,[1,1,0],[0;0;1],1,2,3,4);
            ss = ol.serialize();

            rec = serializable.deserialize(ss);


            assertEqual(ol,rec);
        end
        %
        function test_degrees_rad(~)
            ol = goniometer();
            ol.psi   = 10;
            ol.omega = 20;
            ol.dpsi  = 30;
            ol.gl    = 40;
            ol.gs    = 50;
            assertEqual('deg',ol.angular_units)

            ol = ol.set_rad();
            assertEqual('rad',ol.angular_units)

            toRad=pi/180.;
            assertElementsAlmostEqual(10*toRad,ol.psi)
            assertElementsAlmostEqual(20*toRad,ol.omega)
            assertElementsAlmostEqual(30*toRad,ol.dpsi)
            assertElementsAlmostEqual(40*toRad,ol.gl)
            assertElementsAlmostEqual(50*toRad,ol.gs)

            ol=ol.set_deg();
            assertElementsAlmostEqual(10,ol.psi)
            assertElementsAlmostEqual(20,ol.omega)
            assertElementsAlmostEqual(30,ol.dpsi)
            assertElementsAlmostEqual(40,ol.gl)
            assertElementsAlmostEqual(50,ol.gs)

            ol.angular_units = 'rad';
            assertEqual('rad',ol.angular_units)


            assertElementsAlmostEqual(10*toRad,ol.psi)
            assertElementsAlmostEqual(20*toRad,ol.omega)
            assertElementsAlmostEqual(30*toRad,ol.dpsi)
            assertElementsAlmostEqual(40*toRad,ol.gl)
            assertElementsAlmostEqual(50*toRad,ol.gs)

            ol.angular_units = 'degree';
            assertEqual('deg',ol.angular_units)

            assertElementsAlmostEqual(10,ol.psi)
            assertElementsAlmostEqual(20,ol.omega)
            assertElementsAlmostEqual(30,ol.dpsi)
            assertElementsAlmostEqual(40,ol.gl)
            assertElementsAlmostEqual(50,ol.gs)

        end
        %
        function test_3Dvectors(~)

            ol = goniometer();
            assertVectorsAlmostEqual([1,0,0],ol.u);
            assertVectorsAlmostEqual([0,1,0],ol.v);

            function to_throw(ol,val)
                ol.v  = val;
            end
            assertExceptionThrown(@()to_throw(ol,[1,0,0]), ...
                'HERBERT:goniometer:invalid_argument');

            ol.u = 1;
            assertEqual([1,1,1],ol.u)
            assertEqual([0,1,0],ol.v)

            ol.psi = 10;
            assertEqual(ol.psi,10);

        end
        function test_invalid3Dvectors_throw(~)
            ol = goniometer();
            function to_throw(ol,field,val)
                ol.(field) = val;
            end
            %rd.u='a';
            assertExceptionThrown(@()to_throw(ol,'u','a'), ...
                'HERBERT:goniometer:invalid_argument');
            %rd.v=[]; -- does not accept empty vectors
            assertExceptionThrown(@()to_throw(ol,'v',[]), ...
                'HERBERT:goniometer:invalid_argument');

            %rd.v = [10^-10,0,0]; -- does not accept empty vectors
            assertExceptionThrown(@()to_throw(ol,'v',[1.e-11,0,0]), ...
                'HERBERT:goniometer:invalid_argument');
        end
        %
        function this = test_1vectors_errors(this)
            ol=goniometer();
            function to_throw(ol,field,val)
                ol.(field) = val;
            end


            %ol.gl='a';
            assertExceptionThrown(@()to_throw(ol,'gl','a'), ...
                'HERBERT:goniometer:invalid_argument');

            %ol.gl=[1,2];
            assertExceptionThrown(@()to_throw(ol,'gl',[1,2]), ...
                'HERBERT:goniometer:invalid_argument');

            ME= assertExceptionThrown(@()to_throw(ol,'gl',400), ...
                'HERBERT:goniometer:invalid_argument');
            assertEqual(ME.message,...
                'An angular value should be in the range of +-360deg but it equal to: 400');

        end
        function test_full_constructor(~)
            ol = goniometer(10,[1,1,0],[0;0;1],1,2,3,4);
            assertEqual(ol.psi,10)
            assertEqual(ol.u,[1,1,0])
            assertEqual(ol.v,[0,0,1])
            undef = ol.undef_fields;
            assertTrue(isempty(undef));
        end
        function test_full_constructor_with_keyval(~)

            mult = pi/180;
            ol = goniometer('psi',20*mult,...
                'gl',3*mult,'angdeg',[40,45,50]*mult,'angular_units','rad');

            assertTrue(ol.is_defined('psi'));

            assertEqual(ol.angular_units,'rad')
            assertEqual(ol.psi,20*mult)
        end
        function test_mixed_constructor_with_keyval(~)

            ol = goniometer('psi',20,'gl',3,'angular_units','deg');

            assertTrue(ol.is_defined('psi'));
            assertEqual(ol.angular_units,'deg')
            ol.angular_units = 'r';
            assertEqual(ol.psi,20*pi/180)
        end
        function test_mixed_constructor_with_structure(~)

            in_str = struct('psi',20,'gl',3,'angular_units','deg');

            ol = goniometer(in_str);

            assertTrue(ol.is_defined('psi'));

            assertEqual(ol.angular_units,'deg')
            ol = ol.set_rad();
            assertEqual(ol.psi,20*pi/180)
        end

        function test_save_load_serializable_obj(~)
            ol = goniometer(10*pi/180,...
                [1,1,0],[1,-1,0],...
                0.1,0.2,0.3,0.4,'rad');
            ss = ol.saveobj();

            olr = serializable.loadobj(ss);
            assertEqual(ol,olr);
        end

    end
end
