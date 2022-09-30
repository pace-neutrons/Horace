function out_str = disp2str(in_obj)
% Return string value of an object as obtained from disp function but without
% leading and traling control characters and whitespaces

out_str = strtrim(evalc('disp(in_obj)'));
