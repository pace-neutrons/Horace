function [ok,mess,output]=multifit_error(nop,mess_in)
% Utility to pack output for multifit to keep code compact
ok=false;
mess=mess_in;
output=cell(1,nop);
