classdef test_sqw_binfile_common <  TestCase %WithSave
    %Testing common part of the code used to access binary sqw files
    % and various auxliary methods, availble on this class
    %
    
    properties
        test_folder
    end
    
    methods
        function obj = test_sqw_binfile_common(varargin)
            if nargin > 0
                name = varargin{1};
            else
                name= mfilename('class');
            end
            %obj = obj@TestCaseWithSave(name,sample_file);
            obj = obj@TestCase(name);
            obj.test_folder=fileparts(mfilename('fullpath'));
        end
        %-----------------------------------------------------------------
        function obj = test_get_main_header_form(obj)
            tob = sqw_binfile_common_tester();
            mh = tob.get_main_header_form();
            
            fn = fieldnames(mh);
            memb = ismember(fn,{'filename','filepath','title','nfiles'});
            assertTrue(all(memb));
            
            mh = tob.get_main_header_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,{'nfiles'});
            assertTrue(all(memb));
        end
        function obj = test_get_header_form(obj)
            tob = sqw_binfile_common_tester();
            
            mh = tob.get_header_form();
            
            sample_const = {'efix','emode','alatt','angdeg',...
                'cu','cv','psi','omega','dpsi','gl','gs','en',...
                'uoffset','u_to_rlu','ulen','ulabel'};
            sample_var =  {'filename','filepath'};
            tot = [sample_var(:);sample_const(:)];
            
            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));
            
            mh = tob.get_header_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,sample_const);
            assertTrue(all(memb));
        end
        function obj = test_get_detpar_form(obj)
            tob = sqw_binfile_common_tester();
            
            mh = tob.get_detpar_form();
            
            sample_const = {'ndet','group','x2','phi','azim','width','height'};
            sample_var =  {'filename','filepath'};
            tot = [sample_var(:);sample_const(:)];
            
            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));
            
            mh = tob.get_detpar_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,sample_const);
            assertTrue(all(memb));
            
        end
        %
        function obj = test_get_data_form(obj)
            tob = sqw_binfile_common_tester();
            
            mh = tob.get_data_form();
            
            var_fields = {'filename','filepath','title'};
            const_fields={'alatt','angdeg','uoffset','u_to_rlu',...
                'ulen','ulabel','npax','iax','iint','pax','p_size','p',...
                'dax','s','e','npix','urange','dummy','pix'};
            tot = [var_fields(:);const_fields(:)];
            
            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));
            
            mh = tob.get_data_form('-const');
            fn = fieldnames(mh);
            memb = ismember(fn,const_fields);
            assertTrue(all(memb));
            
            
            mh = tob.get_data_form('-const','-head');
            fn = fieldnames(mh);
            ch ={'alatt','angdeg','uoffset','u_to_rlu',...
                'ulen','ulabel','npax','iax','iint','pax','p_size','p',...
                'dax'};
            memb = ismember(fn,ch);
            assertTrue(all(memb));
            
            
            mh = tob.get_data_form('-head');
            fn = fieldnames(mh);
            
            tot_head =[var_fields(:);ch(:)];
            memb = ismember(fn,tot_head);
            assertTrue(all(memb));
            
            tob = tob.set_data_type('a');
            mh = tob.get_data_form();
            fn = fieldnames(mh);
            memb = ismember(fn,tot);
            assertTrue(all(memb));
        end
        
        %
    end
    
end

