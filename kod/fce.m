function [med_lum, mean_lum , mean_light,lum1,light1, obsh, vysl,skel,tloustka_cev_obr,lum_perc90,light_perc90,      light_perc10,lum_perc10,std_light,std_lum] = fce(raz, dva, tri)
% [med_lum, mean_lum , mean_light,lum1,light1, obsh, vysl,skel,tloustka_cev_obr,lum_perc90,light_perc90,      light_perc10,lum_perc10,std_light,std_lum] = fce(raz, dva, tri)
% fce vytvari priznaky pro dalsi zpracovani:
% lum1, med_lum, mean_lum, lum_perc90, lum_perc10, std_lum - prvni kanal
% YCBCR obrazu a jeho staticsticke hodnoty: median, prumer, 90% percentil,
% 10% percentil a str.kvadr.odchylka.
% light1, med_light, mean_light, light_perc90, light_perc10, std_light -
% prvni kanal LAB obrazu a jeho staticsticke hodnoty.
% tloustka_cev_obr - obraz obsahujici na pozicich cevy hodnoty jejich
% tloustky
% + indexovani aktualniho obrazku (obsh) 
% + vysledek pokud neni prazdny (pouziva se pro zjisteni velikosti obrazku). 
% Pokud je prazdne - velikost obrazku defaultne je (1168x1752)fce_median_cevy
% ==================
% vstup:
% raz - vysledek, 
% dva - rgb obraz sitnice
% tri - binarni obraz cevniho reciste
% napriklad: 
% listing_Evy = dir("~\clasified");
% listing_images = dir("~\images");
% listing_bin = dir("~\manual1");
%     raz = fullfile(listing_Evy(1).folder,(listing_Evy(end).name)); nebo []
%     dva = fullfile(listing_images(1).folder,(listing_images(end).name));
%     tri = fullfile(listing_bin(1).folder,(listing_bin(end).name));

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
% 1. - 6. lum1, med_lum, mean_lum, lum_perc90, lum_perc10, std_lum - prvni kanal
% YCBCR obrazu a jeho staticsticke hodnoty: median, prumer, 90% percentil,
% 10% percentil a str.kvadr.odchylka.
% 7. - 12. light1, med_light, mean_light, light_perc90, light_perc10, std_light -
% prvni kanal LAB obrazu a jeho staticsticke hodnoty.
% 13. tloustka_cev_obr - obraz obsahujici na pozicich cevy hodnoty jejich
% tloustky

YCBCR = rgb2ycbcr(obr);
lum = YCBCR(:,:,1);
okno_med = 25;
med_lum = medfilt2(lum,[okno_med okno_med]); % zde a dale u kazdeho
% priznaku pred extragovanim priznaku upravujeme jas obazu 
% (presvicene mista a stiny) pomoci odecitani od originalu medianu obrazu
rozdil = (lum*1)-med_lum;
lum1 = rozdil;
rozdil = normalize(rozdil,"range");
pomer_lum = (rozdil).*(obr_bin);
[med_lum, std_lum, mean_lum,~]= fce_median_cevy(obsh, pomer_lum);

okno_med = 50;
med_light = medfilt2(lum,[okno_med okno_med]);
rozdil = (lum*1)-med_light;
lum_perc90 = prctile(rozdil,90,[3]);
lum_perc10 = prctile(rozdil,10,[3]);

lab = rgb2lab(obr);
light = lab(:,:,1);
okno_med = 25;
med_light = medfilt2(light,[okno_med okno_med]);
rozdil = (light*1)-med_light;
light1 = rozdil;
rozdil = normalize(rozdil,"range");
pomer_light = (rozdil).*(obr_bin);
[~, std_light, mean_light,~]= fce_median_cevy(obsh, pomer_light);

light_perc90 = prctile(light1,90,[3]);
light_perc10 = prctile(light1,10,[3]);

[tloustka_cev_obr] = fce_tloustka(obsh);
end