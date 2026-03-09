function [inputs,coord_defined_at] = parse_sym_normvec_inputs_(flds,varargin)
%PARSE_SYM_NORMVEC_INOUTS helper function used for parsing inputs defining
%reflection or rotation operation from normal vector to a plane.
%
% Inputs:
% flds   -- field names used for defining operation.
% Returns:
% inputs -- list of key-values pairs used to define appropriate
%           symop
% coord_defined_at
%        -- if system of coordinates (rlu or cc) of normvector
%           is defined as constructor input, index, which
%           contains its value. Empty otherwise.

inputs = cell(1,2*numel(flds));
b_matrix_defined = 0;
coord_defined_at = 0;
coord_defined = false;
ifc = 1;
while ifc <= numel(varargin)
    arg_val = varargin{ifc};
    if istext(arg_val ) && strncmp(arg_val,'no',2) % normvec;
        inputs{ifc} = 'normvec';
        inputs{ifc+1} = varargin{ifc+1};
        ifc = ifc+2;
        continue;
    end
    if istext(arg_val ) && strncmp(arg_val,'of',2) % offset;
        inputs{ifc} = 'offset';
        inputs{ifc+1} = varargin{ifc+1};
        ifc = ifc+2;
        continue;
    end
    if istext(arg_val ) && strncmp(arg_val,'b_',2) % b-matrix;
        inputs{ifc} = 'b_matrix';
        inputs{ifc+1} = varargin{ifc+1};
        b_matrix_defined = ifc+1;
        ifc = ifc+2;
        continue;
    end
    if ismember(arg_val,{'rlu','cc'})
        inputs{ifc} = 'input_nrmv_in_rlu';
        inputs{ifc+1} = strcmp(arg_val,'rlu');
        coord_defined_at = ifc+1;
        ifc = ifc+2;
        coord_defined = true;
        continue;
    end
    inputs{ifc} = arg_val;
    ifc = ifc+1;
end
if b_matrix_defined>0 && ~coord_defined
    b_mat = inputs{b_matrix_defined};
    if ~is_diagonal_matr(b_mat,1.e-9)
        error('HORACE:symop:invalid_argument',[ ...
            'When normvector is defined in non-orthogonal system,\n' ...
            'one have to provide the description of this sytem (rlu or cc)\n' ...
            'The description have not been provided']);
    end
end
% check missing inputs
if ifc < 2*numel(flds)
    inputs = inputs(1:ifc-1);
end