classdef test_serialize_size< TestCase
    properties
    end
    methods
        function this=test_serialize_size(varargin)
            if nargin>0
                name = varargin{1};
            else
                name  = 'test_serialize_size';
            end
            this = this@TestCase(name);
            
        end
        
        function test_size(this)
            test_struc = struct('clc',true(1,3),'a',1,'ba',single(2),'ce',[1,2,3],...
                'dee',struct('a',10),'ei',int32([9;8;7]));
            
            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);
            
           test_struc = struct('clc',{1,2,4,5},'a',[1,4,5,6],...
               'ba',zeros(3,2),'ce',struct(),...
                'dee',@(x)sin(x),'ei',[1,2,4]');            
            
            bytes = hlp_serialize(test_struc);
            sz = hlp_serial_size(test_struc);
            assertEqual(numel(bytes),sz);
            
        end
        
    end
end
