classdef test_extract_keyval< TestCase
    properties
    end
    methods
        function this=test_extract_keyval(varargin)
            if nargin == 0
                name= mfilename('class');
            else
                name = varargin{1};
            end
            this = this@TestCase(name);
        end
        
        function test_options(this)
            data = {'-key1',10,'-key2','xxx','aaa',100,this,'key3','bbb'};
            opt = {'-key1','key3','key4'};
            [keyval_list,other]=extract_keyvalues(data,opt);
            
            assertEqual({'-key1',10,'key3','bbb'},keyval_list);
            assertEqual({'-key2','xxx','aaa',100,this},other);            
            
            data = {'aaa','bbb'};
            [keyval_list,other]=extract_keyvalues(data,opt);            
            assertTrue(isempty(keyval_list));
            assertEqual(other,data);
        end
        function test_wrong_options(this)
            data = {'-key1',10,'-key2','xxx','aaa',100,this,'key3','bbb'};
            opt = {'-key2','xxx','aaa'};
            f=@()extract_keyvalues(data,opt);
            assertExceptionThrown(f,'EXTRACT_KEYVALUES:invalid_argument');

            opt = {'xxx','aaa'};
            f=@()extract_keyvalues(data,opt);
            assertExceptionThrown(f,'EXTRACT_KEYVALUES:invalid_argument');
            
        end

        
    end
end

