classdef test_stringmatchi < TestCase
    % Test of stringmatchi and stringmatchi_log
    
    methods
        %--------------------------------------------------------------------------
        function test_nonUnique_unambiguous (~)
            % Two elements of the cell array start with the test string, but
            % ambiguity is resolved by one being an exact match
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell);
            ok = stringmatchi_log ('hell', strcell);
            
            assertEqual (ix, 3);            
            assertEqual (ok, logical([0,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_nonUnique_ambiguous (~)
            % Three elements of the cell array start with the test string, but
            % no resolution of the ambiguity by an exact match
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hel', strcell);
            ok = stringmatchi_log ('hel', strcell);
            
            assertEqual (ix, [1,2,3]);            
            assertEqual (ok, logical([1,1,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_nonUnique_ambiguous_partialMatchExcluded (~)
            % Three elements of the cell array start with the test string, but
            % no resolution of the ambiguity by an exact match.
            % Tests that the full test string is used in the tests, as one of
            % the cell array elements shares three of the four leading
            % characters
            strcell = {'hello', 'help', 'hellish', 'burp'};
            ix = stringmatchi ('hell', strcell);
            ok = stringmatchi_log ('hell', strcell);
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_exactMatchFalse (~)
            % Test of explicit set of 'exact' option to false
            strcell = {'hello', 'help', 'hellish', 'burp'};
            ix = stringmatchi ('hell', strcell, 0);
            ok = stringmatchi_log ('hell', strcell, 0);
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_exactMatchTrue (~)
            % Test of explicit set of 'exact' option to true
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell, 1);
            ok = stringmatchi_log ('hell', strcell, 1);
            
            assertEqual (ix, 3);            
            assertEqual (ok, logical([0,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_exactMatchTrueKeyword (~)
            % Test of explicit set of 'exact' option to true by keyword
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell, 'exact');
            ok = stringmatchi_log ('hell', strcell, 'exact');
            
            assertEqual (ix, 3);            
            assertEqual (ok, logical([0,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_exactMatchNone (~)
            % Test of exact match when there aren't any exact mataches
            strcell = {'hello', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hel', strcell, 'exact');
            ok = stringmatchi_log ('hel', strcell, 'exact');
            
            assertEqual (ix, zeros(1,0));            
            assertEqual (ok, logical([0,0,0,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_exactMatchMultiple (~)
            % Test discovery of repeated exact matches
            strcell = {'hell', 'help', 'hell', 'burp'};
            ix = stringmatchi ('hell', strcell, 'exact');
            ok = stringmatchi_log ('hell', strcell, 'exact');
            
            assertEqual (ix, [1,3]);            
            assertEqual (ok, logical([1,0,1,0]));            
        end
        
        %--------------------------------------------------------------------------
        function test_unrecognisedKeyword_ERROR (~)
            % Test error thrown if unreqcignised keyword
            strcell = {'hell', 'help', 'hell', 'burp'};
            
            assertExceptionThrown (@()stringmatchi ('hell', strcell, 'extra'),...
                'HERBERT:stringmatchi:invalid_argument');            
            assertExceptionThrown (@()stringmatchi_log ('hell', strcell, 'extra'),...
                'HERBERT:stringmatchi_log:invalid_argument');            
        end
        
        %--------------------------------------------------------------------------
    end
end
