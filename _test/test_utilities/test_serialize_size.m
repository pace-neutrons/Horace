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
        %
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
        %
        function test_ser_sample(this)
            sam1=IX_sample(true,[1,1,0],[0,0,1],'cuboid',[0.04,0.03,0.02]);
            
            size1 = hlp_serial_size(sam1);
            bytes = hlp_serialize(sam1);
            assertEqual(size1,numel(bytes));
            
            sam1rec = hlp_deserialize(bytes);
            assertEqual(sam1,sam1rec);
            
            sam2=IX_sample(true,[1,1,1],[0,2,1],'cylinder_long_name',rand(1,5));
            size2 = hlp_serial_size(sam2);
            bytes = hlp_serialize(sam2);
            assertEqual(size2,numel(bytes));
            
            sam2rec = hlp_deserialize(bytes);
            assertEqual(sam2,sam2rec);
            
            
            %assertEqual(put_variable_to_binfile(-1,sam2),546);
            sam3=IX_sample(true,[1,1,0],[0,0,1],'hypercube_really_long_name',rand(1,6));
            size3 = hlp_serial_size(sam3);
            bytes = hlp_serialize(sam3);
            assertEqual(size3,numel(bytes));
            
            sam3rec = hlp_deserialize(bytes);
            assertEqual(sam3,sam3rec);
        end
        function test_ser_instrument(this)
            
            % Create three different instruments
            inst1=create_test_instrument(95,250,'s');
            size1 = hlp_serial_size(inst1);
            bytes = hlp_serialize(inst1);
            assertEqual(size1,numel(bytes));
            
            inst1rec = hlp_deserialize(bytes);
            assertEqual(inst1,inst1rec );
            
            
            inst2=create_test_instrument(56,300,'s');
            inst2.flipper=true;
            size2 = hlp_serial_size(inst2);
            bytes = hlp_serialize(inst2);
            assertEqual(size2,numel(bytes));
            
            inst2rec = hlp_deserialize(bytes);
            assertEqual(inst2,inst2rec );
            
            inst3=create_test_instrument(195,600,'a');
            inst3.filter=[3,4,5];
            size3 = hlp_serial_size(inst3);
            bytes = hlp_serialize(inst3);
            assertEqual(size3,numel(bytes));
            
            inst3rec = hlp_deserialize(bytes);
            assertEqual(inst3,inst3rec );
            
            
        end
        
    end
end
