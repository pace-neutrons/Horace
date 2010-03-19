function out=hor_parse(string)
% takes an imnput string and returns a set of run numbers (in sring form)
% such that the horace GUI can operate on multiple files
% , delimits on muktiple non sequential runs : delimites multiple
% sequential runs
%
% this is a copy of parse_homer, which is used in the homer_ver0 gui
%
rem=string;
out={};
if isempty(strfind(string,':'));
while size(rem >0)
    [a,rem]=strtok(rem,' ,');
    if length(a)<5
        aa='';
        for i=1:5-(length(a))
            aa=strcat(aa,'0');
        end
        a=strcat(aa,a);
    end
    out=strvcat(out,(strcat(a)));
    
end
else
    out='';
    aa=str2num(string);
    for i=aa
        out=strcat(out,num2str(i),',');
    end
    rem=out;
    out='';
    while size(rem >1);
        [a,rem]=strtok(rem,' ,');
        if length(a)<5
            aa='';
            for i=1:5-(length(a));
                aa=strcat(aa,'0');
            end
            a=strcat(aa,a);
        if a=='00000';
            a='';
        end
        end
        out=strvcat(out,strcat(a));
    end
end