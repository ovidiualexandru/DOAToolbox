function y = readbinary(filename, endianess)
FID = fopen(filename,'r', endianess);
y = fread(FID, inf, 'int16');
fclose(FID);
end