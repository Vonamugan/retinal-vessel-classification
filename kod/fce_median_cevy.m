function [med_D, kv_odch_D, mean_D, mode_D] = fce_median_cevy(obsh, D)
% [med_D, kv_odch_D, mean_D] = fce_median_cevy(obsh, D)
% funkce vytvari priznaky (median, prumer, kvadr.odch.) kazdeho useku cev
% =================
% vstup:
% 1. obsh - indexovane kusy cevy. kazdy kus ma hodnotu 1, 2, 3 atd..
% 2. D - obrazek, ve kterem chceme na vystupu dostat median, kvadratickou odch.
% a prumer jednotlivych kusu cev

med_D = zeros(size(obsh));
kv_odch_D = zeros(size(obsh));
mean_D = zeros(size(obsh));
mode_D = zeros(size(obsh));
for i = 1:max(max(obsh))
    A = obsh;
    A(A~=i)=0;
    A(A==i)=1;
    A = logical(A);
    kus_cevy = D.*A;
    kus_cevy=kus_cevy(:);
    kus_cevy = nonzeros(kus_cevy);

    med_D(A) = median(kus_cevy);
    kv_odch_D(A) = std(kus_cevy);
    mean_D(A) = mean(kus_cevy);
    mode_D(A) = mode(kus_cevy);
end
end