function det = get_hor_format(par_array,file_name)
% function transforms data obtained as par data array into Horace srtucture;

[path,name,ext]=fileparts(file_name);
det.filename   =[name,ext];
if isempty(path)
    path='.';
end
det.filepath = [path,filesep];
 
size_par  = size(par_array);
if(size_par(1)~=6)
	error('GET_HOR_FORMAT:invalid_file_format',' proper par array has to have 6 column but this one has %d',size_par(1));
end

det.group = par_array(6,:);        
	
det.x2    = par_array(1,:);
det.phi   = par_array(2,:);
det.azim  =-par_array(3,:); % Note sign change to get correct convention
det.width = par_array(4,:);
det.height= par_array(5,:);
