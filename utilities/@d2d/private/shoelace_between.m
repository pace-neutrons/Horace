function bet=shoelace_between(a,b,p)
%checks if point p is betweeen a and b

ba=b-a;
pa=p-a;

ba_dot_pa=dot_special([ba; 0],[pa; 0]);
ba_dot_ba=sum(ba.^2);

% if ba_dot_pa<0
%     bet=false;
% elseif ba_dot_pa < ba_dot_ba
%     bet=true;
% else
%     bet=false;
% end

bet=(ba_dot_pa<ba_dot_ba & ba_dot_pa>=0);
