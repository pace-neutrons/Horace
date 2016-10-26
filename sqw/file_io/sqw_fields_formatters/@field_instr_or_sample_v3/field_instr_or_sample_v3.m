classdef field_instr_or_sample_v3 < sqw_field_format_interface
    % serialize/de-serialize the instrument or sample fields stored in the header block.
    %
    %>> fi = field_instruments_v3('instrument')
    %or
    %>> fi = field_instruments_v3('sample')
    %
    % Fields to process are:
    % --------------------------
    %   header.instrument  -- Instrument description (scalar structure or object)
    % or
    %   header.sample      --  Sample description (scalar structure or object)
    %  correspondingly
    %
    % Original author: T.G.Perring
    %
    % $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
    
    properties(Access=private)
        data_form_ = field_generic_class_hv3();
        block_descriptor_ = struct('version',1,'nfiles',0,'all_same',true);
        instruments_=[];
        field_name_ = 'instrument'
    end
    properties(Dependent)
        % indicates if class used to process instrument or sample
        field_name
        % what format version is currently supported (processed)
        format_version
    end
    
    methods
        function fi = field_instr_or_sample_v3(fieldname)
            % constructor
            % Usage:
            % fi = field_instr_or_sample_v3('instrument') -- to process
            %      instrument information
            % or
            % fi = field_instr_or_sample_v3('sample') -- to process
            %      sample information
            fi.field_name_ = fieldname;
        end
        function fn = get.field_name(obj)
            fn = obj.field_name_;
        end
        function ver = get.format_version(obj)
            % returns current format version of instrument or sample block
            % written on HDD
            ver = obj.block_descriptor_.version;
        end
        
        function [val,sz] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into the field value
            [block_descriptor,sz] = obj.data_form_.field_from_bytes(bytes,pos);
            pos = pos+sz;
            if block_descriptor.all_same
                n_files = 1;
            else
                n_files = block_descriptor.nfiles;
            end
            if n_files == 1
                [inst,szi] = obj.data_form_.field_from_bytes(bytes,pos);
                sz  = sz + szi;
                if isfield(inst,'instrument')
                    val = struct('block_descr',block_descriptor,...
                        obj.field_name_,inst.instrument);
                else
                    val = struct('block_descr',block_descriptor,...
                        obj.field_name_,inst);
                    
                end
            else
                inst_carray = cell(1,n_files);
                for i=1:n_files
                    [inst_str,szi] = obj.data_form_.field_from_bytes(bytes,pos);
                    inst_carray{i} = inst_str.instrument;
                    sz  = sz + szi;
                    pos = pos+ szi;
                end
                val = struct('block_descr',block_descriptor,...
                    obj.field_name_,inst_carray);
                
            end
        end
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            % identify size of the filed from sequence of bytes (should know
            % the location and the position of the size information in bytes array)
            % calculate size of the instrument block descriptor:
            [block_descriptor,sz] = obj.data_form_.field_from_bytes(bytes,pos);
            pos = pos + sz;
            if block_descriptor.all_same
                n_files = 1;
            else
                n_files = block_descriptor.nfiles;
            end
            for i=1:n_files
                szi = obj.data_form_.size_from_bytes(bytes,pos);
                sz = sz+szi;
                pos = pos+ szi;
            end
            obj.block_descriptor_ = block_descriptor;
        end
        
        function [sz,obj,err] = size_from_file(obj,fid,pos)
            % identify size of the filed from open binary file (should know the
            % the location and the position of the size information in bytes array)
            [sz,err] = obj.data_form_.size_from_file(fid,pos);
            if err; return; end;
            
            fseek(fid,pos,'bof');
            [mess,res] = ferror(fid);
            if res ~=0; error('FIELD_INSTR_SAMPLE_V3:io_error',...
                    'Error moving to class header position %s',mess); end
            
            bytes = fread(fid,[1,sz],'*uint8');
            [instr_block_descriptor,sz] = obj.data_form_.field_from_bytes(bytes,1);
            
            pos = pos + sz;
            if instr_block_descriptor.all_same
                n_files = 1;
            else
                n_files =  block_descriptor.nfiles;
            end
            for i=1:n_files
                [szi,err] = obj.data_form_.size_from_file(fid,pos);
                sz = sz+szi;
                pos = pos+ szi;
            end
        end
        %
        function sz = size_of_field(obj,transf_obj)
            % calculate size of the instrument block, present in sqw file
            [block_descriptor,nf_2process] = ...
                build_block_descriptor_(obj,transf_obj);
            
            sz = obj.data_form_.size_of_field(block_descriptor);
            for i=1:nf_2process
                if isstruct(transf_obj)
                    sz = sz+ obj.data_form_.size_of_field(transf_obj(i));
                else
                    sz = sz+ obj.data_form_.size_of_field(transf_obj{i}.(obj.field_name));
                end
            end
        end
        
        function bytes = bytes_from_field(obj,transf_obj)
            % convert field value into sequence of bytes in the form,
            % convertible back by other methods
            [block_descriptor,nf_2process] = ...
                build_block_descriptor_(obj,transf_obj);
            %
            bytes = cell(1,nf_2process+1);
            %
            bytes{1} = obj.data_form_.bytes_from_field(block_descriptor);
%             if size(bytes{1},1)~= 1
%                 bytes{1} = bytes{1}';
%             end
            for i=1:nf_2process
                if isstruct(transf_obj)
                    bytes{i+1} = obj.data_form_.bytes_from_field(transf_obj(i));
                else
                    bytes{i+1} = obj.data_form_.bytes_from_field(transf_obj{i});
                end
            end
            %
            %    f size(bytes{i+1},1)~= 1
            %                         bytes{i+1} = bytes{i+1}';
            %                     end
            
            bytes = [bytes{:}];
            
        end
    end
end