classdef sqw_header
    % Helper class defining sqw header structure and some basic operations over
    % these structures until the sqw_header becomes a class
    %
    properties
    end
    %
    methods(Static)
        function hstruct=header_struct()
            % return the structure correspongint to an sqw file header.
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
        function [header_out,nspe,hstruct_sort,ind] = header_combine(headers,allow_equal_headers,drop_subzones_headers)
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
            %               equal headers. Two input files with equal haders is an error
            %               in normal operations so this option  used in
            %               tests only.
            %drop_subzones_headers if headers provided are the subzone
            %               headers, i.e. the headers obtained as the
            %               headers of the cuts from sinlge sqw file, these
            %               headers have special field, indicationg that
            %               they are the subzone headers and should be
            %               dropped for combine purpoces.
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
            if ~exist('drop_subzones_headers','var')
                drop_subzones_headers = false;
            end
            
            nsqw=numel(headers);
            
            % Catch case of a single header block from a single spe file - no processing required.
            if isstruct(headers) && nsqw==1
                header_out=headers;
                nspe=1;
                hstruct_sort = sqw_header.create_header_array({header_out});
                ind=1;
                return
            end
            
            % Get number of elements in each header block
            nspe=zeros(nsqw,1);
            for i=1:nsqw
                if ~iscell(headers{i})
                    nspe(i)=1;
                else
                    nspe(i)=numel(headers{i});
                end
            end
            %
            function is=is_subzone_header(hd)
                % identify if this header belong to zone divided into subzones or not
                %
                % a first subzone header assumed not to belong to subzone headers
                [numbers,~] = regexp(hd.filepath,'\d*','match','split');
                num = str2double(numbers(3));
                if num>1
                    is = true;
                else
                    is = false;
                end
            end
            
            
            
            % Construct output header block
            nfiles_tot=sum(nspe);
            header_out=cell(nfiles_tot,1);
            ibeg=1;
            for i=1:nsqw
                subz_header = false;
                
                if nspe(i)==1
                    header_out(ibeg)=headers(i);   % header for a single file is just a structure
                    ibeg=ibeg+1;
                    if drop_subzones_headers
                        subz_header = is_subzone_header(headers(i));
                    end
                else
                    header_out(ibeg:ibeg+nspe(i)-1)=headers{i};    % header for more than one file is a cell array
                    if drop_subzones_headers
                        subz_header = is_subzone_header(header_out{ibeg});
                    end
                    ibeg=ibeg+nspe(i);
                end
                if subz_header
                    nspe(i) = -nspe(i);
                end
            end
            
            if drop_subzones_headers
                subzone_headers = cellfun(@(hd)(is_subzone_header(hd)),header_out);
                header_out = header_out(~subzone_headers);
                nfiles_tot = numel(header_out);
            end
            
            % Check the headers are all unique across the relevant fields, and have equality in other required fields
            % -------------------------------------------------------------------------------------------------------
            % Make a stucture array of the fields that define uniqueness
            hstruct = sqw_header.create_header_array(header_out);
            names=fieldnames(hstruct(1));
            % Sort structure array
            [hstruct_sort,ind]=sortStruct(hstruct,names');
            
            
            if ~allow_equal_headers
                for i=2:nfiles_tot
                    if isequal(hstruct_sort(i-1),hstruct_sort(i))
                        mess='At least two headers have the all the same filename, efix, psi, omega, dpsi, gl and gs';
                        error('SQW_HEADER:invalid_header',mess);
                    end
                end
            end
            
            sqw_header.check_headers_equal(header_out{1},header_out(2:end));
        end
    end
end

