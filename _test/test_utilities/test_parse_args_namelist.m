classdef test_parse_args_namelist < TestCaseWithSave
    methods
        %--------------------------------------------------------------------------
        function self = test_parse_args_namelist (name)
            self@TestCaseWithSave(name);
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            namelist = {'name','target','targ','frequency'};
            [S, present] = parse_args_namelist (namelist, '-targ',37);
            
            Sref.targ = 37;
            present_ref = cell2struct({false,false,true,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            namelist = {'name','target','targ','frequency'};
            [S, present] = parse_args_namelist (namelist, 'hello',42);
            
            Sref.name = 'hello';
            Sref.target = 42;
            present_ref = cell2struct({true,true,false,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 42,'-name','hello');
            
            Sref.name = 'hello';
            Sref.target = 42;
            present_ref = cell2struct({true,true,false,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 'hello',42);
            
            Sref.name = 'hello';
            Sref.target = 42;
            present_ref = cell2struct({true,true,false,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 42);
            
            Sref.target = 42;
            present_ref = cell2struct({false,true,false,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 42, 'parp', {23,'toot'});
            
            Sref.target = 42;
            Sref.targ = 'parp';
            Sref.frequency = {23,'toot'};
            present_ref = cell2struct({false,true,true,true}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_7 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 42, 'parp', {23,'toot'});
            
            Sref.target = 42;
            Sref.targ = 'parp';
            Sref.frequency = {23,'toot'};
            present_ref = cell2struct({false,true,true,true}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_8 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            [S, present] = parse_args_namelist (namelist_with_opt,...
                42, '-freq', {23,'toot'}, '-name', 'name','-targ','parp');
            
            Sref.name = 'name';
            Sref.target = 42;
            Sref.targ = 'parp';
            Sref.frequency = {23,'toot'};
            present_ref = cell2struct({true,true,true,true}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_9 (self)
            namelist = {'name','target','targ','frequency'};
            namelist_with_opt = {namelist,{'char'}};
            try
                [S, present] = parse_args_namelist (namelist_with_opt,...
                    'a_name', '-freq', {23,'toot'}, '-name', 'name','-targ','parp');
                msgID = '';
            catch ME
                msgID = ME.identifier;
            end
            assertEqual(msgID,'parse_args_namelist:inputError')
        end
        
        %--------------------------------------------------------------------------
        function test_10 (self)
            namelist = {'name','sx','targ','frequency'};
            namelist_with_opt = {namelist,{'char','logical'}};
            [S, present] = parse_args_namelist (namelist_with_opt, '-targ',37);
            
            Sref.targ = 37;
            present_ref = cell2struct({false,false,true,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_11 (self)
            namelist = {'name','sx','targ','frequency'};
            namelist_with_opt = {namelist,{'char','logical'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 1, '-targ',37);
            
            Sref.sx = 1;
            Sref.targ = 37;
            present_ref = cell2struct({false,true,true,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
        function test_12 (self)
            namelist = {'name','sx','targ','frequency'};
            namelist_with_opt = {namelist,{'char','logical'}};
            [S, present] = parse_args_namelist (namelist_with_opt, 'thing', '-targ',37);
            
            Sref.name = 'thing';
            Sref.targ = 37;
            present_ref = cell2struct({true,false,true,false}',namelist');
            
            assertEqual(S,Sref)
            assertEqual(present,present_ref)
        end
        
        %--------------------------------------------------------------------------
    end
end
