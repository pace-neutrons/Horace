function [is,mess] = eq_(obj,other_obj,narg_out,names,varargin)
% Check equality of two ortho projections or two arrays of
% ortho_projections
%

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
[~,shift_1]=obj1.get_pix_img_transformation(3);
[~,shift_2]= obj2.get_pix_img_transformation(3);
[~, rot_to_img_1, ulen1] = obj1.uv_to_rot([1,1,1]);
[~, rot_to_img_2, ulen2] = obj2.uv_to_rot([1,1,1]);
[mat_eq,mess1] = equal_to_tol(rot_to_img_1,rot_to_img_2, ...
    'name_a',[name_a_val,'u_to_img'],'name_b',[name_b_val,'u_to_img'],varargin{:});
if ~mat_eq
    mess1 = sprintf('rot_to_img: %s\n',mess1);
end
[shift_eq,mess2] = equal_to_tol(shift_1,shift_2, ...
    'name_a',[name_a_val,'u_to_img'],'name_b',[name_b_val,'u_to_img'],varargin{:});
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
