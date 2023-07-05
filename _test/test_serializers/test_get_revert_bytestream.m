classdef test_get_revert_bytestream< TestCase
    properties

    end
    methods
        function this=test_get_revert_bytestream(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end

        function test_num_conversion(~)

            x=1000;
            bs = serialize(x);
            assertTrue(isa(bs(1),'uint8'));
            assertEqual(numel(bs),14);

            xc = deserialize(bs);

            assertEqual(x,xc);
        end

        function test_string_conversion(~)
            y = 'abra_cadbra';
            bs = serialize(y);
            assertTrue(isa(bs,'uint8'));
            assertEqual(numel(bs),17);

            yc = deserialize(bs);

            assertEqual(y,yc);
        end

        function test_struct_conversion(~)
            x=1000;
            y = 'abra_cadbra';
            z=struct('yyy',y,'xx',x);

            bs = serialize(z);
            assertTrue(isa(bs,'uint8'));
            assertEqual(numel(bs),64);

            zc = deserialize(bs);

            assertEqual(z,zc);
        end

        function test_sobj_conversion(~)
            t= IX_fermi_chopper(10,50,10,1,0.1);
            t.radius = 10;
            t.name = 'sloppy';

            bs = serialize(t);
            assertTrue(isa(bs,'uint8'));
            assertEqual(numel(bs),375);

            tc = deserialize(bs);
            tc = feval(tc.serial_name, tc);

            assertEqual(t,tc);
        end

        function test_mex_nomex(~)
            mod = IX_moderator();
            mod.distance=10;
            mod.thickness = 1;
            mod.temperature = 7;
            hc = hor_config;
            hc.saveable = false;
            use_mex = hc.use_mex;
            clOb = onCleanup(@()set(hc,'use_mex',use_mex));
            hc.use_mex = true;
            bs = serialize(mod);
            hc.use_mex = false;
            bsn = serialize(mod);
            assertTrue(isa(bs,'uint8'));
            assertEqual(numel(bs),342);

            assertEqual(bs,bsn);

            hc.use_mex = true;
            modc = deserialize(bs);
            modc = feval(modc.serial_name, modc);

            assertEqual(mod,modc);
            hc.use_mex = false;
            modc = deserialize(bs);
            modc = feval(modc.serial_name, modc);
            assertEqual(mod,modc);

        end


    end
end
