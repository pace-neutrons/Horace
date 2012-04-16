function  lattice=get_reciprocal_lattice(this,num_cells,k_range)
% returns reciprocal lattice vectors in XXX system of coordinates
% Input:
% ------
%  num_cells -- vector of 1 to 3 values, describing nuumber of lattice
%                      cells selected in every dimensions
% k_range     -- limints to put lattice vectors in

 b = bmatrix(this);

 
 bv{1}=[1;0;0];
 bv{2}=[0;1;0]; 
 bv{3}=[0;0;1]; 

 % process num_cells
 if exist('num_cells','var')
    np = numel(num_cells);
    ind3=num_cells;    
 else
     np = 3;
     ind3=[1,1,1];
 end
   if np<3
       for i=np+1:3
            ind3(i)=num_cells;
       end
   end
   
 % build the whole lattice
 n_lattice_points = (2*ind3(1)+1)*(2*ind3(2)+1)*(2*ind3(3)+1);
 lattice = zeros(n_lattice_points,3);
 correct=logical(zeros(n_lattice_points,3));
             
% process limits  where the lattice exist
 if exist('k_range','var')             
    n_constrains =numel(k_range);
 else
    n_constrains =0;
 end
 %
 ic=1;
 for k=-ind3(3):ind3(3)
        for j=-ind3(2):ind3(2)
            for i=-ind3(1):ind3(1)
                q =b*(bv{1}*i+bv{2}*j+bv{3}*k);
                if this.is_fcc
                    if mod(i+j+k,2)==0   %fcc; only even numbers give points;
                        correct(ic)=true;
                    else
                        correct(ic)=false;
                    end                    
                end
                             
                 for is=1:n_constrains
                        iss=4-is;
                        if q(iss)<k_range{is}(1)||q(iss)>=k_range{is}(2)
                            correct(ic)=false;
                            break;
                        end
                end
           
                lattice(ic,1:3)=  q;
                ic=ic+1;                        
           end
        end
 end
 
 lattice = lattice(correct,:);
 
