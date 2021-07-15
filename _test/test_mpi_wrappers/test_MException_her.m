classdef test_MException_her < TestCase
    % Test serializanble-deserializable exception
    
    properties
    end
    methods
        %
        function this=test_MException_her(name)
            if ~exist('name', 'var')
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
       %
        function test_zero_stack_r(~)
            % Exception with zero stack does not contain much information.
            %
            ME = MException('TESTEXC:zero_stack','test zero stack exceptions');
            myExc = MException_her(ME);
            
            rep = getReport(myExc);
            assertTrue(strncmp(rep,'test zero stack exceptions',26));
        end
        %
        function test_convert_to_Exception(~)
            try
                mex_Thrower(2)
            catch ME
                mecc1 = MException('TESTEXC:test_cause1','test text 1');
                try
                    mex_Thrower(3,3,'TESTEXC:test_cause2')
                catch mecc2
                end
                ME=ME.addCause(mecc1);
                ME=ME.addCause(mecc2);
                myExc = MException_her(ME);
            end
            
            MeR = MException_her.build_MException(myExc);
            w = warning('off','MATLAB:structOnObject');
            clob = onCleanup(@()warning(w));
            
            s1 = struct(ME);
            s2 = struct(MeR);
            s1 = rmfield(s1,'type');
            s2 = rmfield(s2,'type');
            assertEqual(s1,s2);
            
        end
        %
        function test_get_report_advanced(~)
            % create and get advanced report
            try
                mex_Thrower(1)
            catch ME
            end
            try
                mex_Thrower(3,3,'TESTEXC:test_cause2')
            catch ME_reas
            end
            ME = ME.addCause(ME_reas);
            
            MEser = MException_her(ME);
            
            mex_str = MEser.saveobj();
            MErec = MEser.loadobj(mex_str);
            
            
            assertEqual(MEser.stack_r,MErec.stack_r);
            assertEqual(ME.stack,MErec.stack_r);
            assertEqual(ME.identifier,MErec.identifier);
            assertEqual(ME.message,MErec.message);
            caus1 = ME.cause{1};
            caus2 = MErec.cause{1};
            assertEqual(caus1.stack,caus2.stack_r);
            assertEqual(caus1.identifier,caus2.identifier);
            assertEqual(caus1.message,caus2.message);
            
            
            rep1 = getReport(ME);
            rep2 = getReport(MEser);
            rep3 = getReport(MErec);
            %
            rep1 = strsplit(rep1);
            rep2 = strsplit(rep2);
            rep3 = strsplit(rep3);
            %assertEqual(rep1(18:end)',rep2(23:end)');
            %assertEqual(rep1(17:end-16)',rep3(22:end-5)')
            ind1 = find(ismember(rep1,{'Test','exception','at'}),1);
            
            assertEqual(rep1(ind1:ind1+7)',rep3(1:8)')
            assertEqual(rep2(1:8)',rep3(1:8)')
        end
        %
        function test_get_report(~)
            % get exception
            try
                mex_Thrower(1)
            catch ME
                myExc = MException_her(ME);
            end
            %
            [err_text,css] = getReport(myExc);
            assertTrue(isa(css,'MException'));
            assertTrue(numel(err_text)>100)
            rep_std = getReport(css);
            assertEqual(err_text,rep_std);
        end
        %
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
        %
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
