classdef sqw_header
    % Helper class defining sqw header structure and some basic operations over
    % these structures until the sqw_header becomes a class
    %
    properties
    end
    %
    methods(Static)
        function hstruct=header_struct()
            % return the structure correspondent to an sqw file header.
            %
            % Under normal operations the values of
            % at least some fields of this header should usually be
            % different for different headers.
            hstruct=struct('filename','','efix',[],'psi',[],'omega',[],'dpsi',[],'gl',[],'gs',[]);
        end
        %
        function check_headers_equal(ref_header,headers_list)
            % compare all proper headers fields to be equal to the
            % reference header fields
            %
            % Throws SQW_HEADER:invalid_header if they  are not.
            %
            %
            % test number to define equality allowing for rounding errors (recall fields were saved only as float32)
            tol = 2.0e-7;
            n_headers = numel(headers_list);
            if isfield(ref_header,'cu')
                sqw_header = true;
            else
                sqw_header = false;
                npax=length(ref_header.pax);
            end
            %
            function check_equal(field_current,field_ref,field_name)
                if isstruct(field_ref)
                    ok = isequal(field_current,field_ref);
                else
                    ok = equal_to_relerr(field_current, field_ref, tol, 1);
                end
                if ~ok
                    error('SQW_HEADER:invalid_header',...
                        ' Not all input files have the save values of: %s',field_name);
                end
            end
            %
            for i=1:n_headers
                check_equal(headers_list{i}.u_to_rlu(:),ref_header.u_to_rlu(:),'u_to_rlu');
                check_equal(headers_list{i}.uoffset,ref_header.uoffset,'uoffset');
                
                if sqw_header
                    check_equal(headers_list{i}.emode,ref_header.emode,'emode');
                    check_equal(headers_list{i}.alatt, ref_header.alatt,'alatt');
                    check_equal(headers_list{i}.angdeg, ref_header.angdeg,'angdeg');
                    check_equal(headers_list{i}.cu, ref_header.cu,'cu');
                    check_equal(headers_list{i}.cv, ref_header.cv,'cv');
                    check_equal(headers_list{i}.ulen, ref_header.ulen,'ulen');
                    check_equal(headers_list{i}.sample, ref_header.sample,'sample');
                else
                    if npax<4   % one or more integration axes
                        check_equal(headers_list{i}.iax,ref_header.iax,'iax');
                        check_equal(headers_list{i}.iint,ref_header.iint,'iint');
                    end
                    if npax>0   % one or more projection axes
                        check_equal(headers_list{i}.pax,ref_header.pax,'pax');
                        for ipax=1:npax
                            check_equal(headers_list{i}.p{ipax},ref_header.p{ipax},'p');
                        end
                    end
                    
                end
            end
            
        end
        %
        function headers_array = create_header_array(headers)
            % Copy the contents of the headers cellarray into the
            % appropriate part of the sqw headers array
            headers_array = repmat(sqw_header.header_struct,size(headers));
            n_files = numel(headers);
            names = fieldnames(headers_array(1));
            for i=1:n_files
                headers_array(i).filename=fullfile(headers{i}.filepath,headers{i}.filename);
                for j=2:numel(names)
                    headers_array(i).(names{j})=headers{i}.(names{j});
                end
            end
            
        end
        %
        function [headers,nspe,hstruct_sort,ind] = header_combine(headers,allow_equal_headers,drop_subzones_headers)
            % Combine header blocks to form a single block
            %
            %   >> [header_out,nfiles,ok,mess] = header_combine(header)
            %
            % Input:
            % ------
            %   headers     Cell array of header blocks from a number of sqw files
            %               Each header block is structure (single spe file) or a cell
            %               array of single structures.
            %               The special case of a single header block from a single spe
            %               file being passed as a structure is allowed.
            %Optional:
            % allow_equal_headers  disables checking input files for absolutely
            %               equal headers. Two input files with equal headers is an error
            %               in normal operations so this option  used in
            %               tests only.
            %drop_subzones_headers if headers provided are the subzone
            %               headers, i.e. the headers obtained as the
            %               headers of the cuts from single sqw file, these
            %               headers have special field, indication that
            %               they are the subzone headers and should be
            %               dropped for combine purposes.
            %
            % Output:
            % -------
            %   header_out  Header block for a single sqw file that combines all the input
            %              sqw files. (Note that if a single spe file, this is a structure
            %              otherwise it is a cell array. This is the standard format for
            %              an sqw file.) [column vector]
            %   nspe        Array of length equal to the number of input header blocks containing
            %              the number of spe files in each input header block [column vector]
            %   hstruct_sort Structure with the fields that define uniqueness of a header entry
            %   ind         Index of hstruct_sort of equivalent entry in header_out
            %
            %
            % Notes:
            % ------
            % 1) For the headers to be combined:
            %    - The headers when left with the following subset of fields must be unique (that is,
            %      the structure made from these fields must be unique)
            %           fullfile(filepath,filename), efix, psi, omega, dpsi, gl, gs
            %    - The contents of the following fields must be identical in all headers:
            %           emode, alatt, angdeg, cu, cv, uoffset, u_to_rlu, ulen, sample
            %    - Equality or otherwise of these fields is irrelevant:
            %           en, ulabel, instrument
            %
            %  *** Should insist that the structure of instrument is the same in all headers
            %      although the values of fields in nested structures and arrays can be different
            %
            % 2) The purpose of this routine is not to check the validity of the values of the
            %   fields (e.g. that lattice parameters are greater than zero), but instead to
            %   check the consistency of the equality or otherwise of the fields as required by later
            %   algorithms in Horace
            
            if ~exist('allow_equal_headers','var')
                allow_equal_headers = false;
            end   
            
            nsqw=numel(headers);
            
            % Catch case of a single header block from a single spe file - no processing required.
            if nsqw==1
                hstruct_sort =headers;
                nspe=1;
                ind=1;
                return
            end
            nspe = 1:nsqw;
            
            % Check the headers are all unique across the relevant fields, and have equality in other required fields
            % -------------------------------------------------------------------------------------------------------
            % Make a structure array of the fields that define uniqueness 
            hstruct = headers;
            hstruct = rmfield(hstruct,{'ulabel','instrument','sample'});
            %hstruct = sqw_header.create_header_array(header_out);
            names=fieldnames(hstruct(1));
            % Sort structure array
            [hstruct_sort,ind]=sortStruct(hstruct,names');
            
            
            if ~allow_equal_headers
                for i=2:nsqw
                    if isequal(hstruct_sort(i-1),hstruct_sort(i))
                        error('HORACE:sqw_header:invalid_argument',...
                            'At least headers %d and %d have the all the same: filename, efix, psi, omega, dpsi, gl and gs',...
                            i-1,i);
                    end
                end
            end
            %HACK: fix and reenable this
            %sqw_header.check_headers_equal(hstruct(1),hstruct(2:end));
        end
    end
end

