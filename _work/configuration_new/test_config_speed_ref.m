function sum=test_config_speed_ref(n)

tic
sum=0;
for i=1:n
    g1=get(herbert_config,'use_mex');
    g2=get(herbert_config,'force_mex_if_use_mex');
    sum=sum+g1+g2;
end
toc
