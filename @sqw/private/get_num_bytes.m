function bytes=get_num_bytes(x)
% Useful utility that avoids ugly code in calling routine
tmp=whos('x');
bytes=tmp.bytes;
