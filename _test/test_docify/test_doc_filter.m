classdef test_doc_filter < TestCase
    % Test of the filtering of meta-documentation sections according to keyword tags
    properties
        file_in
        refdir
    end
    
    methods
        function self = test_doc_filter(name)
            self = self@TestCase(name);
        end
        
        function setUp(self)
            root_dir = fileparts(mfilename('fullpath'));
            self.file_in = fullfile(root_dir,'test_doc_filter_files','func_undocified.m');
            self.refdir = fullfile(root_dir,'test_doc_filter_files','reference');
        end
        
        %-------------------------------------------------------------------------------------
        function test_default(self)
            % Test default case of only un-tagged doc_beg being parsed
            filename = 'func_default.m';
            
            file_ref = fullfile(self.refdir,filename);
            file_tmp = fullfile(tmp_dir,filename);
            cleanup = onCleanup(@()delete_file(file_tmp));
            try
                docify(self.file_in,file_tmp,'-list',0);
            catch
                assertTrue(false,'Problems in docify')
            end
            assertFilesEqual(file_ref,file_tmp);
        end
        
        %-------------------------------------------------------------------------------------
        function test_all(self)
            % Parse all section, tagged or not
            filename = 'func_all.m';
            
            file_ref = fullfile(self.refdir,filename);
            file_tmp = fullfile(tmp_dir,filename);
            cleanup = onCleanup(@()delete_file(file_tmp));
            try
                docify(self.file_in,file_tmp,'-all','-list',0);
            catch
                assertTrue(false,'Problems in docify')
            end
            assertFilesEqual(file_ref,file_tmp);
        end
        
        %-------------------------------------------------------------------------------------
        function test_none(self)
            % Parse nothing
            filename = 'func_none.m';
            
            file_tmp = fullfile(tmp_dir,filename);
            cleanup = onCleanup(@()delete_file(file_tmp));
            try
                rep = docify(self.file_in,file_tmp,'-key',{},'-list',0);
            catch
                assertTrue(false,'Problems in docify')
            end
            if isempty(rep.changed)
                assertTrue(true)
            else
                assertTrue(false,'Unexpected output from docify when should be none')
            end
        end
        
        %-------------------------------------------------------------------------------------
        function test_filter(self)
            % Parse all section, tagged or not
            filename = 'func_filter.m';
            
            file_ref = fullfile(self.refdir,filename);
            file_tmp = fullfile(tmp_dir,filename);
            cleanup = onCleanup(@()delete_file(file_tmp));
            try
                docify(self.file_in,file_tmp,'-key','base','-list',0);
            catch
                assertTrue(false,'Problems in docify')
            end
            assertFilesEqual(file_ref,file_tmp);
        end
                
        %-------------------------------------------------------------------------------------
        function test_filter2(self)
            % Parse all section, tagged or not
            filename = 'func_filter2.m';
            
            file_ref = fullfile(self.refdir,filename);
            file_tmp = fullfile(tmp_dir,filename);
            cleanup = onCleanup(@()delete_file(file_tmp));
            try
                docify(self.file_in,file_tmp,'-key',{'base','main'},'-list',0);
            catch
                assertTrue(false,'Problems in docify')
            end
            assertFilesEqual(file_ref,file_tmp);
        end
                
    end
end

%=============================================================================================
function delete_file (filename)
% Delete file, if can
if exist(filename,'file')
    try
        delete(filename)
    catch
    end
end
end
