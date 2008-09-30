a=rand(3,6,8);

a=ones(2,5,7);
for i=1:2
    for j=1:5
        for k=1:7
            a(i,j,k) = i+j+k
        end
    end
end


x=[1,2,3];
y=[11,12,13,14,15,16];
y=[11,16.1,16.2,16.4,16.7,16.9];
z=[21,22,23,24,25,26,27,28];


% array for testing Matlab sum:
m=7;
n=5;
p=3;
a=ones(m,n,p);
for i=1:m
    for j=1:n
        for k=1:p
            a(i,j,k) = i+j+k
        end
    end
end


