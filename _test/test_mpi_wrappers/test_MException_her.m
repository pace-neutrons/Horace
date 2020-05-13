classdef test_MException_her < TestCase
    % Test serializanble-deserializable exception
    
    properties
    end
    methods
        %
        function this=test_MException_her(name)
            if ~exist('name','var')
                name = 'test_MException_her';
            end
            this = this@TestCase(name);
        end
        function test_serialize_deserialize(~)
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
            mex_str = myExc.saveobj();
            assertTrue(isstruct(mex_str));
            
            
            MER = myExc.loadobj(mex_str);
            assertTrue(isa(MER,'MException'));
            assertTrue(isa(MER,'MException_her'));
            assertEqual(myExc,MER);
        end
        function test_get_report(~)
            % get exception
            try
                mex_Thrower(1)
            catch ME
                myExc = MException_her(ME);
            end
            %
            [err_text,css] = getReport(myExc);
            assertTrue(numel(css)>=3);
            assertTrue(strncmp(err_text,css{1},100));
            assertTrue(strncmp(css{3},...
                'Error using <a href="matlab:matlab.internal.language.introspective.errorDocCallback(''test_MException',...
                100));
            
        end
        function test_FailWithMexc(~)
            try
                mex_Thrower(3)
            catch ME
            end
            me = FailedMessage('testing problem',ME);
            struc = me.saveobj();
            mer = aMessage.loadobj(struc);
            % for comparison, replace initial mexeption with MException_her
            % as MException is not serializable)
            me.payload.error = MException_her(me.payload.error);
            assertEqual(me,mer);
        end
        
        function test_aMessageWithStructure(~)
            add_info = struct('bla_bla',1);
            add_info.something = {'1','2';'aa','bb'};
            me = LogMessage(1,10,4.,add_info);
            struc = me.saveobj();
            mer = aMessage.loadobj(struc);
            assertEqual(me,mer);
        end
    end
    
end
