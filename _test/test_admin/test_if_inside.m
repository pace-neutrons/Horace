classdef test_if_inside< TestCase
    % Verify if is_inside function works properly
    % $Revision:: 833 ($Date:: 2019-10-24 20:46:09 +0100 (Thu, 24 Oct 2019) $)
    %
    
    properties
    end
    methods
        %
        function this=test_if_inside(name)
            if nargin<1
                name = 'test_if_inside';
            end
            this = this@TestCase(name);
            
        end
        function test_is_inside(obj)
            folder1 = ['c:',filesep,'users',filesep,'horace', filesep];
            folder2 = ['c:',filesep,'users',filesep,'herbert'];
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertFalse(is);
            assertEqual(com_root,['c:',filesep,'users']);
            folder1 = ['c:',filesep,'users',filesep,'horace', filesep];
            folder2 = ['c:',filesep,'users',filesep,'horace', filesep];
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertTrue(is);
            assertEqual(com_root,['c:',filesep,'users',filesep,'horace']);
            
            folder1 = '/home/users/horace/dir';
            folder2 = '/home/users/herbert/';
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertFalse(is);
            assertEqual(com_root,fullfile(filesep,'home','users'));
            
            folder1 = '/home/users/herbert/dir';
            folder2 = '/home/users/herbert';
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertTrue(is);
            assertEqual(com_root,fullfile(filesep,'home','users','herbert'));
            
            folder1 = '/home/users/herbert/dir';
            folder2 = '/home/local/herbert';
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertFalse(is);
            assertEqual(com_root,[filesep,'home']);
            

            folder1 = '/home/users/herbert/dir';
            folder2 = '/usr/local/herbert';
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertFalse(is);
            assertEqual(com_root,filesep);

            folder1 = 'c:/users/herbert/dir/';
            folder2 = 'd:/usr/local/herbert/';
            [is,com_root] = is_dir_inside(folder1,folder2);
            assertFalse(is);
            assertEqual(com_root,'');
            
        end
        
    end
end

