clear all
% clc
close all
%% nacitani obrazku
tic

vysl =   (imread("15_h_Eva.png"));
obr = imresize(im2double(imread("15_h.JPG")),size(vysl));
obr_bin = imresize(imread("15_h.tif"),size(vysl));
%% skeletonizace
obr_bin = logical( obr_bin );
skel = bwskel(obr_bin);
%% hledani uzlu. 
% vysledek M (logical) 
M = bwmorph(skel, 'branchpoints');
bimg = skel  & not(M);
bimg = bwmorph(bimg, 'clean');
%% deleni cev na kusy. 
% vysledek: obsh (na pozici jednotlivych useku cev pixely, ktere = 1, u dalsiho useku = 2, dalsiho 3 atd)
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
if 1
    figure()
    RGB = label2rgb(obsh,"prism");
    imshow(RGB);
end
%% ...

class50 = logical(zeros(size(obr,[1 2])));
class50(vysl==50)=1;
class50 = class50 & obr_bin;

class100 = logical(zeros(size(obr,[1 2])));
class100(vysl==100)=1;
class100 = class100 & obr_bin;

class150 = logical(zeros(size(obr,[1 2])));
class150(vysl==150)=1;
class150 = class150 & obr_bin;

% clip = 0.01; 
% Alpha = 0.1;
% r = adapthisteq(obr(:,:,1), "Distribution","rayleigh" ,"Alpha",Alpha);
% g = adapthisteq(obr(:,:,2),"Distribution","rayleigh" ,"Alpha",Alpha);
% b = adapthisteq(obr(:,:,3),"Distribution","rayleigh" ,"Alpha",Alpha);

r = adapthisteq(obr(:,:,1));
g = adapthisteq(obr(:,:,2));
b = adapthisteq(obr(:,:,3));

rr = (obr(:,:,1));
gg = (obr(:,:,2));
bb = (obr(:,:,3));
%% pomocne boxploty
% for rezim = 1:6
% % rezim = 4;
% if rezim==1
% pomer = r./b;
% Title = "r./b adapthisteq";
% elseif rezim==2
%     pomer = r./g;%%
%     Title = "r./g adapthisteq";
%    elseif rezim==3
%             pomer = b./g;%%
%             Title = "b./g adapthisteq";
%        elseif rezim==4
%             pomer = rr./bb;
%             Title = "r./b ";
%            elseif rezim==5
%                 pomer = rr./gg;
%                 Title = "r./g ";
%                elseif rezim==6
%                    pomer = bb./gg;
%                    Title = "b./g ";  
% %                    elseif rezim==7
% %                    pomer = g;
% %                    Title = "g adapthisteq ";  
% %                                       elseif rezim==8
% %                    pomer = gg;
% %                    Title = "g  "; 
% end
% 

% pomer = normalize(pomer,"range");
% 
% 
% f = pomer(class150);
% % f = f(:);
% XX_150 = NaN(1,100000);
% XX_150(1:length(f)) = f;
% YY_150 = NaN(1,100000);
% YY_150(1:length(f)) = (150)*ones(1,length(f));
% 
% s = pomer(class100);
% % s = s(:);
% XX_100 = NaN(1,100000);
% XX_100(1:length(s)) = s;
% YY_100 = NaN(1,100000);
% YY_100(1:length(s)) = (100)*ones(1,length(s));
% 
% t = pomer(class50);
% % t = (t(:));
% XX_50 = NaN(1,100000);
% XX_50(1:length(t)) = t;
% YY_50 = NaN(1,100000);
% YY_50(1:length(t)) = (50)*ones(1,length(t));
% 
% X = [XX_150 XX_100 XX_50];
% Y = [YY_150 YY_100 YY_50];
% figure()
% boxplot(X,Y);
% title(Title);
% end
%% klasifikace cev mezi uzly. 
% vysledek : pomocna (double) pixely jsou bud 0 = pozadi. 50 = nezname. 100
% = tepny nebo 150 zily. jeste to neni vysledek, protoze chceme v kazdem
% kusu cevy jen jeden druh pixelu.
pomer = b./g;
pomer = normalize(pomer,"range");
pomer1 = (pomer).*(obr_bin);%%

% f = pomer(class150);
% s = pomer(class100);
% t = pomer(class50);
% med_50 = nanmedian(t);
% med_100 = nanmedian(s);
% med_150 = nanmedian(f);
% 
% thresh_50_a_100 = (med_50 + med_100)/2; %  0.2608
% thresh_100_a_120 = (med_150 + med_100)/2; %   0.3456 ... 0.3

thresh_100_a_120 = 0.32; % 0.3200  ? pro b./g - na zaklade toho co je zakomentovane. 0.32 cca = (med_150 + med_100)/2; u vsech obrazku

pomocna = zeros(size(pomer1));
% pomocna(pomer1>0 & pomer1<=thresh_50_a_100) = 50;
pomocna(pomer1>=thresh_100_a_120) = 150;
% pomocna(pomer1>thresh_50_a_100 & pomer1<thresh_100_a_120) = 100;
pomocna(pomer1>0 & pomer1<thresh_100_a_120) = 100; %% lze zakomentovat tohle 
% a odkomentovat 2 zakomentovane radky a bude to zarazovat i do 50 (nezname), ale taky bude potreba definovat thresh_50_a_100



%% prumerovani hodnoty v jednotlivych kusech cevy
% vysledek : B (double) pixely jsou bud 0 = pozadi. 50 = nezname. 100
% = tepny nebo 150 zily
B = zeros(size(pomer1));
for i = 1:length(uzly)
    A = obsh;
    A(A~=i)=0;
    A(A==i)=1;
    A = logical(A);
    kus_cevy = pomocna.*A;
    kus_cevy=kus_cevy(:);
    kus_cevy = nonzeros(kus_cevy);

    B(A) = median(kus_cevy);
end

%% ...


figure();
subplot(121);
imshow(B,[]); 
title("pixely");
subplot(122);
imshow(vysl,[]); 


%% vysledky
vysl_skel = double(vysl).*double(skel);
obr_skel = double(B).*double(skel);
[spravne, spatne] = fce_kontrola(obr_skel, vysl_skel);
disp(["spravne = " + num2str(( spravne/(spravne+spatne)*100 )) + " %"]);
disp(["spatne = " + num2str((  spatne/(spravne+spatne) *100)) + " %"]);

disp(["spravne = " + num2str(spravne) + " px"]);
disp(["spatne = " + num2str(spatne) + " px"]);
toc
%%
function [A] = fce_jednotlive_cevy(stats,n,sz)
reg = stats(n).PixelList;
% sz = size(obr_bin);
A = zeros(sz);
X = reg(:,1);
Y = reg(:,2);
ind = sub2ind(sz,Y,X);
A = A(:); A(ind) = 1; A = reshape(A,sz);
A = logical(A);
end
function [spravne, spatne] = fce_kontrola(obr, vysl)
% ------ pocitane bez tridy "nerozpoznano" 50 , protoze nevime jestli je to chyba nebo ne
obr(vysl==50) = 0;
vysl(vysl==50) = 0;
% -------
% all = nnz(vysl);
a = find(vysl==obr & vysl~=0);
spravne = length(a);

b = find(vysl~=obr & vysl~=0);
spatne = length(b);

end
