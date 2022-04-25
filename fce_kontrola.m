function [spravne, spatne] = fce_kontrola(obr, vysl)
% [spravne, spatne] = fce_kontrola(obr, vysl)
% funkce pro porovnani poctu spravne a spatne klasifikovanych pixelu
% =============
% na vstupu:
% 1. obr - nas klasifikovany obrazek
% 2. vysl - spravne klasifikovany obrazek
% =============
% na vystupu:
% pocet pixelu [spravne] a [spatne] klasifikovane
a = find(vysl==obr & vysl~=0);
spravne = length(a);

b = find(vysl~=obr & vysl~=0);
spatne = length(b);
end