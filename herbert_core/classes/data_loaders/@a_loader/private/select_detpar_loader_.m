function obj = select_detpar_loader_(obj,file_name_or_handle)

options = {'-nohorace','-array','-horace','-forcereload','-getphx'}; % if options changes, parse_par_file_arg should also change
[return_array,reload,file_provided,getphx,new_file_name,lext]=parse_par_file_arg(this,options,varargin{:});

if file_provided
    if ~strcmp('.nxspe',lext)
        this.par_file_name = new_file_name;
    else
        this.file_name = new_file_name;
    end
end

if isempty(this.par_file_name)
    [det,this] = load_nxspe_par(this,return_array,reload);
    if getphx % in this case return_array is true and we are converting only array
        det = convert_par2phx(det);
    end
else
    ascii_par_file = this.par_file_name;
    if return_array
        params = {ascii_par_file,'-nohor'};
    else
        params = {ascii_par_file};
    end
    if getphx
      params = {params{:},'-getphx'};
    end
    [det,this]=load_par@asciipar_loader(this,params{:});
end


end

