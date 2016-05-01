%% for quantization 
% I dont know why I have to iterate rather than using for loop it is just
% crazy
y_BP = fi(y0);
biti=5;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=3;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=4;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=2;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=6;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=7;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=8;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
biti=9;
ntBP = numerictype(1,biti+3,biti);
y(biti,:) = quantize(y_BP,ntBP);
y=double(y);