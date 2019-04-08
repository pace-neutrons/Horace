classdef test_parse_revision< TestCase
    
    properties
        root_path;
    end
    methods
        %
        function obj=test_parse_revision(varargin)
            if nargin>0
                name = varargin{1};
            else
                name = mfilename('class');
            end
            obj = obj@TestCase(name);
            obj.root_path = fileparts(which('herbert_init.m'));
        end
        
        function test_process_version(obj)
            test_file = fullfile(obj.root_path,'admin','herbert_version.m');
            targ_file = fullfile(pwd,'herbert_test_version.m');
            copyfile(test_file,targ_file,'f');
            
            clob = onCleanup(@()delete(targ_file));
            
            rev_srt1 = parse_rev_file(targ_file);
            rev_str2 = parse_rev_file(targ_file);      
            rev_n = sscanf(rev_srt1,':: %d');
            rev_n1 = sscanf(rev_str2,':: %d');            
            assertEqual(rev_n+1,rev_n1);
        end
    end
end