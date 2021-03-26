function [R,trans] = calculate_transformation_matrix(win,v1,v2,v3)
%
% Determine the reflection matrix in terms of the basis of win
% Also determine the amount by which co-ords must be translated to account
% for the location of the plane (i.e. if it does not go through the
% origin). Note that this translation must ensure that points remain in the
% data plane!
%
% RAE 12/1/10

vec1=v1'; vec2=v2'; vec3=v3';

if size(vec1)==[3,1]
    vec1=vec1';
end
if size(vec2)==[3,1]
    vec2=vec2';
end
if size(vec3)==[3,1]
    vec3=vec3';
end

vec1p=inv(win.u_to_rlu([1:3],[1:3]))*vec1';
vec2p=inv(win.u_to_rlu([1:3],[1:3]))*vec2';

normvec=cross(vec1p,vec2p);
R=zeros(3,3);%initialise reflection matrix
for i=1:3
    for j=1:3
        if i==j
            delt=1;
        else
            delt=0;
        end
        R(i,j)=delt - (2 * normvec(i) .* normvec(j))./(sum(normvec.^2));
    end
end

vec3p=inv(win.u_to_rlu([1:3],[1:3]))*vec3';
trans=vec3p;

test_trans=dot(cross(win.u_to_rlu([1:3],win.pax(1)),...
    win.u_to_rlu([1:3],win.pax(2))),trans);

if test_trans>1e-5
    mess=['Horace error: offset vector [',num2str(vec3),...
        '] for reflection plane does not lie in the data plane'];
    error(mess);
end



