classdef test_MException_serialization < TestCase
    %
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_MException_serialization(name)
            if ~exist('name','var')
                name = 'test_MException_serialization';
            end
            this = this@TestCase(name);
        end
        function test_serialize_deserialize(obj)
            % get exception
            try
                mex_Thrower(2)
            catch ME
                mecc1 = MException('TESTEXC:test_cause1','test text 1');
                mecc2 = MException('TESTEXC:test_cause2','test text 2');
                ME=ME.addCause(mecc1);
                ME=ME.addCause(mecc2);
                myExc = MException_her(ME);
            end
            %
            bytes = myExc.saveobj();
            assertTrue(isa(bytes,'uint8'));
            assertTrue(numel(bytes)>200);
            
            MER = myExc.loadobj(bytes);
            assertTrue(isa(MER,'MException'));
            assertTrue(isa(MER,'MException_her'));
            assertEqual(myExc,MER);
        end
    end
    
end
