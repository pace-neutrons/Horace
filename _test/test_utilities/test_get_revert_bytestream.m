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
        function test_obj_conversion(this)
            
            x=1000;
            bs = get_bytestream_from_obj(x);
            assertTrue(isa(bs(1),'uint8'));
            assertEqual(numel(bs),72);
            
            xc = get_obj_from_bytestream(bs);
            
            assertEqual(x,xc);
            %-----------------
            y = 'abra_cadbra';
            bs = get_bytestream_from_obj(y);
            assertTrue(isa(bs(1),'uint8'));
            assertEqual(numel(bs),80);
            
            yc = get_obj_from_bytestream(bs);
            
            assertEqual(y,yc);
            %-----------------
            z=struct('yyy',y,'xx',x);
            
            bs = get_bytestream_from_obj(z);
            assertTrue(isa(bs(1),'uint8'));
            assertEqual(numel(bs),216);
            
            zc = get_obj_from_bytestream(bs);
            
            assertEqual(z,zc);
            %-----------------
            
            t= IX_fermi_chopper();
            t.radius = 10;
            t.name = 'sloppy';
            
            bs = get_bytestream_from_obj(t);
            assertTrue(isa(bs(1),'uint8'));
            assertEqual(numel(bs),1016);
            
%            tc = get_obj_from_bytestream(bs);
            
%            assertEqual(t,tc);
            
        end
        
        function test_mex_nomex(this)
            if matlab_version_num>8.02 % Matlab 2014a can not currently run mex files build for lower matlab versions
                return
            end
            mod = IX_moderator();
            mod.distance=10;
            mod.thickness = 1;
            mod.temperature = 7;
            
            bs = get_bytestream_from_obj(mod ,'mex');
            % try native conversion (where availible)
            bsn = get_bytestream_from_obj(mod);
            assertTrue(isa(bs(1),'uint8'));
            assertEqual(numel(bs),896);
            
            assertEqual(bs,bsn);
            
%            modc = get_obj_from_bytestream(bs,'mex');
%            assertEqual(mod,modc);
        end
        
        
    end
end

