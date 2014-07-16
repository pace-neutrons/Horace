function datahdr=data_to_dataheader(data)
% Take a structure containing the data section of an sqw object and return the fields as per 'h' option in get_sqw

datahdr.filename=data.filename;
datahdr.filepath=data.filepath;
datahdr.title=data.title;
datahdr.alatt=data.alatt;
datahdr.angdeg=data.angdeg;
datahdr.uoffset=data.uoffset;
datahdr.u_to_rlu=data.u_to_rlu;
datahdr.ulen=data.ulen;
datahdr.ulabel=data.ulabel;
datahdr.iax=data.iax;
datahdr.iint=data.iint;
datahdr.pax=data.pax;
datahdr.p=data.p;
datahdr.dax=data.dax;
