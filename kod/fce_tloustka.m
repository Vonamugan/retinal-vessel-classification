function [tloustka_cev_obr] = fce_tloustka(obsh)
tloustka_cev_obr = zeros(size(obsh));
for i = 1:max(max(obsh))
    A = obsh;
    A(A~=i)=0;
    A(A==i)=1;
    A = logical(A);
    skel_kusu = bwskel(A);
    akt_m_d = 1;
    tloustka_cev_obr(A) = akt_m_d;
    for SE = 2:15
    skel_kusu_dil = imdilate(skel_kusu,strel('square',SE));
    if sum(A,"all")<sum(skel_kusu_dil,"all")
        akt_m_d = SE-1;
        tloustka_cev_obr(A) = akt_m_d;
        break;
    end
    end

end
end