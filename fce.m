function [med_pomer_b_g, kv_odch_pomer_b_g, mean_pomer_b_g, pomer_b_g, obsh, vysl,skel] = fce(raz, dva, tri)
% [med_pomer_b_g, kv_odch_pomer_b_g, mean_pomer_b_g, obsh, vysl] = fce(raz, dva, tri)
% fce vytvari priznaky pro dalsi zpracovani + pomer modre a zelene 
% (mean_pomer_b_g) + indexovani aktualniho obrazku (obsh) + vysledek pokud
% je (pouziva se pro zjisteni velikosti obrazku). Pokud je prazdne -
% velikost obrazku defaultne je (1168x1752)
% ==================
% vstup: napriklad 
% raz = "15_h_Eva.png" nebo []
% dva = "15_h.JPG"
% tri = "15_h.tif"

%% nacitani obrazku
if ~isempty(raz)
vysl =   (imread(raz));
else
vysl =  zeros(1168,1752);
end
obr = imresize(im2double(imread(dva)),size(vysl));
obr_bin = imresize(imread(tri),size(vysl));
%% skeletonizace
obr_bin = logical( obr_bin );
skel = bwskel(obr_bin);
%% hledani uzlu a deleni cev na kusy
% vysledek M (logical) 
M = bwmorph(skel, 'branchpoints');
bimg = skel  & not(M);
bimg = bwmorph(bimg, 'clean');
%% zajisteni lepsiho indexovani kusu cev
% vysledek: obsh (na pozici jednotlivych useku cev pixely, ktere = 1, u 
% dalsiho useku = 2, dalsiho 3 atd)
sz = size(obr_bin);
uzly = regionprops(bimg,'PixelList');
obsh = (zeros(size(obr_bin)));
for i = 1:length(uzly)
    [t] = fce_jednotlive_cevy(uzly,i,sz);
    se = 9;
    jeden_kus = imdilate(t,strel('square',se));
    jeden_kus = jeden_kus & obr_bin; 
    obsh_pom = obsh + jeden_kus;
    podminka = find(obsh_pom>1);
    if podminka
        idx = ind2sub(size(jeden_kus),podminka);
        jeden_kus(idx) = 0;
        jeden_kus = jeden_kus*i;
    end
    obsh = obsh + jeden_kus;
end
%% pro zobrazeni UZLU dat "1" do if:
if 0
figure()
uzly = regionprops(M,'centroid');
centroids = cat(1,uzly.Centroid);
centroids = round(centroids);
imshow(skel);
hold on
plot(centroids(:,1),centroids(:,2),'rx','MarkerSize',15,'LineWidth',2);
title("uzly");
hold off
end
%% pro zobrazeni ROZDELENI CEV dat "1" do if:
if 0
    figure()
    RGB = label2rgb(obsh,"prism");
    imshow(RGB);
end
%% 
% vysledek :
% 1. med_pomer_b_g, kv_odch_pomer_b_g, mean_pomer_b_g - viz fce_median_cevy.m
% 2. pomer_b_g - hodnoty pomeru modre a zelene jen na miste kde jsou cevy,
% jinde = 0

% r = adapthisteq(obr(:,:,1));
g = adapthisteq(obr(:,:,2));
b = adapthisteq(obr(:,:,3));

pomer = b./g;
pomer = normalize(pomer,"range");
pomer_b_g = (pomer).*(obr_bin);

[med_pomer_b_g, kv_odch_pomer_b_g, mean_pomer_b_g]= fce_median_cevy(obsh, pomer_b_g);
end