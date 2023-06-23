function [is,mess] = eq_(obj,other_obj,narg_out,names,varargin)
% Check equality of two ortho projections or two arrays of
% ortho_projections comparting the projection transformation
% instrad of  all projection properties
%
% Different projection property values may define the same
% transformation, so the projections, which define the same
% transformation should be considered the equal.
%
% Inputs:
% obj       -- object or array of objects to compare
% other_obj -- the object or array of objects to compare with
%               current object
% narg_out  -- numer of output arguments the class method has been called
%              if narg_out>1, indicateds that the information message about
%              the detailed reason of non-equality should be formed
% names     -- two element sellarray containg the names of the variables
%              the calling function was invoked with. May contain more
%              detailed information about the calling variables, if the
%              operation was invoked withinh equal_to_tol comparison.
%              empty 2-element cellarray if narg_out = 1
% Optional:
% varargin  -- cellarray of parameters, eq operation has been called with
%              Directly transferred to equal_to_toll function.
%              Contains any set of parameters equal_to_tol function would
%              accept, as eq uses equal_to_tol function internaly.
%
% Returns:
% True if the objects define the sampe pixel transformation and
%      false if not.
% Optional:
% message, describing in more details where non-equality
% occures (used in unit tests to indicate the details of an
% inequality)


[is,mess,name_a,name_b,namer,argi] = obj.process_inputs_for_eq(other_obj,narg_out,names,varargin{:});
if ~is
    return
end
is = false(numel(obj),1);
for i=1:numel(obj)
    if nargout == 2
        name_1 = namer(name_a,i);
        name_2 = namer(name_b,i);
        [is(i),mess{i}] = eq_single(obj(i),other_obj(i), ...
            name_1,name_2,argi{:});
    else
        is(i) = eq_single(obj(i),other_obj(i), ...
            name_a,name_b,argi{:});
    end
end
if narg_out > 1
    if any(~is)
        mess = strjoin(mess,'; ');
    else
        mess = '';
    end
end

function [iseq,mess] = eq_single(obj1,obj2,name_a_val,name_b_val,varargin)
% compare single pair of ortho_proj checking the transformation itself
%
if obj1.alatt_defined && obj1.angdeg_defined
    [u_to_img_1,shift_1,ulen1] = obj1.get_pix_img_transformation(4);
    obj1_undefined = false;
else
    obj1_undefined = true;
end
if obj2.alatt_defined && obj2.angdeg_defined
    [u_to_img_2,shift_2,ulen2] = obj2.get_pix_img_transformation(4);
    obj2_undefined = false;
else
    obj2_undefined = true;
end

if obj1_undefined && obj2_undefined
    [iseq,mess] = equal_to_tol(obj1.to_bare_struct(),obj2.to_bare_struct(), ...
        'name_a',['Undefined object: ', name_a_val],'name_b',['Undefined object: ',name_b_val], ...
        varargin{:});
    return;
elseif obj1_undefined && ~obj2_undefined
    iseq = false;
    mess = sprintf('Object %s is undefined and Object %s is defined\n', ...
        name_a_val,name_b_val);
    return
elseif ~obj1_undefined && obj2_undefined
    iseq = false;
    mess = sprintf('Object %s is defined and Object %s is undefined\n', ...
        name_a_val,name_b_val);
    return
end
% both defined to compare them properly

[mat_eq,mess1] = equal_to_tol(u_to_img_1,u_to_img_2, ...
    'name_a',[name_a_val,'.u_to_img'],'name_b',[name_b_val,'.u_to_img'],varargin{:});
if ~mat_eq
    mess1 = sprintf('Q_to_img: %s\n',mess1);
end
[shift_eq,mess2] = equal_to_tol(shift_1,shift_2, ...
    'name_a',[name_a_val,'.shift'],'name_b',[name_b_val,'.shift'],varargin{:});
if ~shift_eq
    mess2 = sprintf('shift(s): %s\n',mess2);
end

[len_eq,mess3] = equal_to_tol(ulen1,ulen2, ...
    'name_a',name_a_val,'name_b',name_b_val,varargin{:});
if ~len_eq
    mess3 = sprintf('ulen(s): %s\n',mess3);
end


iseq = mat_eq && shift_eq && len_eq;
mess = [mess1, mess2,mess3];
