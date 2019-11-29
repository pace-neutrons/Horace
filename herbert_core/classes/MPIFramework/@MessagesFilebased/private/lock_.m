function lock_(filename)
fh = fopen(filename,'wb');
fwrite(fh,'lk');
fclose(fh);