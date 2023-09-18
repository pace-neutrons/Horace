classdef test_stringmatchi < TestCaseWithSave
    % Test of stringmatchi and stringmatchi_log
    
    methods
        %--------------------------------------------------------------------------
        function self = test_stringmatchi (name)
            self@TestCaseWithSave(name);
            
            self.save()
        end
        
        %--------------------------------------------------------------------------
        function test_1 (self)
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell);
            ok = stringmatchi_log ('hell', strcell);
            
            assertEqual (ix, 3);            
            assertEqual (ok, logical([0,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_2 (self)
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hel', strcell);
            ok = stringmatchi_log ('hel', strcell);
            
            assertEqual (ix, [1,2,3]);            
            assertEqual (ok, logical([1,1,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_3 (self)
            strcell = {'hello', 'help', 'hellish', 'burp'};
            ix = stringmatchi ('hell', strcell);
            ok = stringmatchi_log ('hell', strcell);
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_3a (self)
            strcell = {'hello', 'help', 'hellish', 'burp'};
            ix = stringmatchi ('hell', strcell, 0);
            ok = stringmatchi_log ('hell', strcell, 0);
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_4 (self)
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell, 'exact');
            ok = stringmatchi_log ('hell', strcell, 'exact');
            
            assertEqual (ix, 3);            
            assertEqual (ok, logical([0,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_5 (self)
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hel', strcell, 'exact');
            ok = stringmatchi_log ('hel', strcell, 'exact');
            
            assertEqual (ix, zeros(1,0));            
            assertEqual (ok, logical([0,0,0,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_6 (self)
            strcell = {'hell', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell, 'exact');
            ok = stringmatchi_log ('hell', strcell, 'exact');
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_6a (self)
            strcell = {'hell', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell, 1);
            ok = stringmatchi_log ('hell', strcell, 1);
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_7 (self)
            strcell = {'hell', 'help', 'hell', 'burp'};
            
            assertExceptionThrown (@()stringmatchi ('hell', strcell, 'extra'),...
                'HERBERT:stringmatchi:invalid_argument');            
            assertExceptionThrown (@()stringmatchi_log ('hell', strcell, 'extra'),...
                'HERBERT:stringmatchi_log:invalid_argument');            
        end
        
        %--------------------------------------------------------------------------
    end
end
