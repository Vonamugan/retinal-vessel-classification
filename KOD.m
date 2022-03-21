clear all
clc
%% nacitani obr
obr_rgb = imread("15_dr.JPG");
obr = im2double(imread("15_dr.JPG"));
obr_mask = im2double(imread("15_dr_mask.tif"));
obr_bin = imread("15_dr.tif");
%% skeletonizace
obr_bin = logical( obr_bin );
skel = bwskel(obr_bin);

%% hledani uzlu
kriz =  [1  0  0  0  0  0  1 ;
         0  1  0  0  0  1  0 ;
         0  0  1  0  1  0  0 ;
         0  0  0  1   0 0  0 ;
         0  0  1  0  1  0  0 ;
         0  1  0  0  0  1  0 ;
         1  0  0  0  0  0  1 ]/13;

kriz2 = [0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ;
         1  1  1  1  1  1  1 ;
         0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ;
         0  0  0  1  0  0  0 ]/13;



% kriz = [1  0  0  0  1 ;
%         0  1  0  1  0 ;
%         0  0  1  0  0 ;
%         0  1  0  1  0 ;
%         1  0  0  0  1]/9;
% 
% kriz2 = [0  0  1  0  0 ;
%          0  0  1  1  0 ;
%          1  1  1  1  1 ;
%          0  0  1  1  0 ;
%          0  0  1  0  0 ]/9;



M = zeros(size(skel));
prah = 7;
% prah = 6.2;
for i = 1:size(skel, 1)-6      % ve for cyklu prochazime cely obrazek, vystrihneme ctverec 7x7 a provedeme konvoluci s krizem a krizem2
                                    % za predpokladem ze v miste uzlu soucet konvolucnich obrazku bude > nez vybrany prah  
    for j = 1:size(skel, 2)-6  
        obr_7x7 =  skel(i:i+6,j:j+6);
        konv = conv2(kriz, obr_7x7, "same");
        konv2 = conv2(kriz2, obr_7x7, "same");
        if sum(sum(konv))>prah || sum(sum(konv2))>prah
        % do matice M ulozime 1 v pripade ze soucet konvolucnich obrazku je vetsi nez prah:
        M(i+3,j+3) = 1;
        end
    end
end

%% M do jednoho bodu
figure(1)
M = logical(M) ;
stredy_uzlu = regionprops(M,'centroid');
centroids = cat(1,stredy_uzlu.Centroid);
imshow(skel)
hold on
plot(centroids(:,1),centroids(:,2),'rx','MarkerSize',15,'LineWidth',2)
hold off

%% histogramy ruznych slozek

R = im2double(obr_rgb(:,:,1));
G = im2double(obr_rgb(:,:,2));
B = im2double(obr_rgb(:,:,3));
RG = im2double(R+G);
RB = im2double(R+B);
GB = im2double(B+G);
RGB = im2double(R+G+B);

figure(2)
subplot(171)
hodnoty_jen_cev = R(obr_bin);
bar(imhist(hodnoty_jen_cev));
title("R");

subplot(172)
hodnoty_jen_cev = G(obr_bin);
bar(imhist(hodnoty_jen_cev));
title("G");

subplot(173)
hodnoty_jen_cev = B(obr_bin) ;
bar(imhist(hodnoty_jen_cev));
title("B");


subplot(174)
hodnoty_jen_cev = RG(obr_bin);
bar(imhist(hodnoty_jen_cev));
title("R+G");

subplot(175)
hodnoty_jen_cev = GB(obr_bin);
bar(imhist(hodnoty_jen_cev));
title("G+B (↓↓↓BEST↓↓↓)");


subplot(176)
hodnoty_jen_cev = RB(obr_bin) ;
bar(imhist(hodnoty_jen_cev));
title("R+B");

subplot(177)
hodnoty_jen_cev = RGB(obr_bin) ;
bar(imhist(hodnoty_jen_cev));
title("RGB");

%% klasifikace cev mezi uzly 
% ...
% 1.rozdelit histogram na 2 casti

% 2. vymyslet indexovani casti cev na zaklade stredy_uzlu

%% poskladat nejak rozumne klasifikace aby to davalo smysl
% ...




