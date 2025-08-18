# Script to reduce the number of energy bins in a nxspe file so its
# size is small enough to be uploaded to github as test data

# this script has not been set up to run from the command line - input
# arguments are not available. Instead
# go down to the os.chdir call below to set the directory to work in, and
# set "infile" to the name of the file you wish to shrink in size *without* 
# the nxspe extension.
# A new file will be produced with "_OUT" added after "infile".
# Input and output files have been compared using h5dump -H to get a data
# summary

import h5py
import os

# the input and output files are named here so they can be seen inside def listgrp
nx = [] # the original h5py File object when it is set
nx2 = [] # this is the revised file with the reduced energy bins

def listgrp(name,obj):

    print(f"{name=}")

    # dedicated block for the 3 items with energy bins
    if name=='ws_out/data/energy':
        print("energy")
        short = obj[0:10]
        nx2.create_dataset(name, data=short)
        nx2ds = nx2[name]
        keys = obj.attrs.keys()
        for k in keys:
            val = obj.attrs.__getitem__(k)
            nx2ds.attrs.__setitem__(k,val)
        return
    elif name == 'ws_out/data/data':
        short = obj[:, 0:9]
        print("data")
        nx2.create_dataset(name, data=short)
        nx2ds = nx2[name]
        keys = obj.attrs.keys()
        for k in keys:
            val = obj.attrs.__getitem__(k)
            nx2ds.attrs.__setitem__(k,val)
        return
    elif name=='ws_out/data/error':
        short = obj[:,0:9]
        print("error")
        nx2.create_dataset(name, data=short)
        nx2ds = nx2[name]
        keys = obj.attrs.keys()
        for k in keys:
            val = obj.attrs.__getitem__(k)
            nx2ds.attrs.__setitem__(k,val)
        return

    # for other items, process generically as copies
    # distinguishing between groups and datasets
    try:

        groupname = name

        #item is dataset, extract the groupname from the dataset name and mark as not group
        if isinstance(obj, h5py.Dataset):
            groupname = groupname.rsplit('/',1)[0]
            isgroup = False
        #item is group, just accept what is given
        else:
            isgroup = True

        #get ouot the last item in name and create an opportunity for breaking at fixed_energy
        leaf = name.rsplit('/',1)
        if len(leaf)==2 and leaf[1]=='fixed_energy':
            print('')

        #item is dataset, ensure the group is created in nx2 and copy the dataset from nx to nx2
        if isinstance(obj, h5py.Dataset):
            id = nx2.require_group(groupname)
            nx.copy(obj.name, id)
        # item is group and there are no datasets in it, ensure the parent group is present nand copy the group
        else:
            if name=='ws_out/sample':
                print('')
            gid = nx2.require_group(groupname)

            keys = obj.attrs.keys()
            for k in keys:
                val = obj.attrs.__getitem__(k)
                gid.attrs.__setitem__(k,val)



        #for groups, copy the attributes if need be.
        if isgroup:
            pass

    except Exception as err:
        print(f"failed A {name}")

# end def listgrp

def listname(name):
    print(name)


# Press the green button in the gutter to run the script.
if __name__ == '__main__':

    wd = os.getcwd()
    print('pwd=',wd,'\n\n')
    os.chdir('C:\\Users\\nvl96446\STFC\PACE\\nxspe\merlin')


    infile = 'MER62984_59.9meV_1to1'
    nx = h5py.File('original/'+infile+'.nxspe','r')
    nx2 = h5py.File(infile+'_OUT.nxspe','w')


    # the listgrp copying does not do the top level attributes, so it is done explicitly here
    nxak = nx.attrs.keys()
    for i in nxak:
        nx2.attrs.__setitem__(i, nx.attrs.__getitem__(i))

    nx.visititems(listgrp)


    nx.close()
