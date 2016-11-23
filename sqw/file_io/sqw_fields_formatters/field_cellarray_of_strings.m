classdef field_cellarray_of_strings < sqw_field_format_interface
    % The class describes conversion applied to save/restore
    % cellarray of strings using sqw binary format
    %
    %
    % $Revision$ ($Date$)
    %
    
    properties(Access=private)
    end
    
    
    methods
        function obj=field_cellarray_of_strings(varargin)
            %
        end
        %
        function bytes = bytes_from_field(obj,val)
            % convert cellarray of strings into sequence of
            % sequence of bytes
            charr =char(val);
            a_size=int32(size(charr));
            nelem = numel(charr);
            bytes = [typecast(a_size,'uint8'),reshape(uint8(charr),1,nelem)];
        end
        function sz = size_of_field(obj,val)
            % calculate the byte-size of cellarray of string, converted
            % into binary sqw format
            charr =char(val);
            a_size=size(charr);
            nelem = numel(charr);
            sz = numel(a_size)*4+nelem;
        end
        %
        function [val,length] = field_from_bytes(obj,bytes,pos)
            % convert sequence of bytes into celarray of strings
            %
            %
            sz  = typecast(bytes(pos:pos+8-1),'uint32');
            length = prod(double(sz));
            start = pos+8;
            if length ==0
                val = '';
            else
                val = reshape(char(bytes(start:start+length-1)),sz(:)');
            end
            val = cellstr(val)';
            length = length+8;
        end
        %
        function [sz,obj] = size_from_bytes(obj,bytes,pos)
            % retrieve size of the cellarray of strings from input
            % bytes array
            size_length = typecast(bytes(pos:pos+8-1),'uint32');
            sz  = prod(double(size_length))+ 8;
        end
        %
        function  [sz,obj,err] = size_from_file(obj,fid,pos)
            % retrieve size of the cellarray of strings from open
            % binary file
            err = false;
            %
            fseek(fid,pos,'bof');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            
            sizes = fread(fid,2,'int32');
            [~,res] = ferror(fid);
            if res ~=0
                err = true;
                return;
            end
            
            n_elements = prod(sizes);
            sz = n_elements+8;
        end
        
    end
    
end

