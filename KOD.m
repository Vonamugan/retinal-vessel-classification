clear all
clc
%% nacitani obr
obr = im2double(imread("01_dr.JPG"));
obr_mask = im2double(imread("01_dr_mask.tif"));
obr_bin = imread("01_dr.tif");
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

prah = 6.2;
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
% imshow(M);

% v M uzly jsou i na mistech, kde neni ceva, zbavime se techto hodnot:
M(skel==0)=0;

% pro ukazku. uzly tady stale nejsou bodem na ceve, ale oblasti. nekdy
% oblasti splyvaji 
C = imfuse(M,skel); 
imshow(C);

% vylepsit... do jednoho bodu???

%% klasifikace cev mezi uzly 
% ...

%% poskladat nejak rozumne klasifikace aby to davalo smysl
% ...




