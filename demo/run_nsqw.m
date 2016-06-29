nf=1:23;
fn = arrayfun(@(x)['HoraceDemoDataFile',num2str(x),'.tmp'],nf,'UniformOutput',false);
write_nsqw_to_sqw (fn,'test_sqw.sqw')