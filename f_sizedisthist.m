function f_sizedisthist(D,A,alpha,Unit_Real)
h=histogram(D,'EdgeAlpha',alpha);
binCenters=h.BinEdges + h.BinWidth/2;
binCenters(end)=[];
%CHANGE THIS TO REFECT REALITY BETTER - DO EACH BLOB INDIVIDUALLY!
areafrac=NaN(length(h.BinEdges)-1,1);
for i=1:length(h.BinEdges)-1
    range=[h.BinEdges(i),h.BinEdges(i+1)];
    idx=find((D>=range(1))...
        &(D<=range(2)));
    areafrac(i)=sum(A(idx));
end
%h.BinCounts=h.BinCounts.*ctoA;%normalise bin counts by area fraction
h.BinCounts=areafrac';
xlabel(strcat('Equivelant Area Diameter',{' ('},Unit_Real,')'))
ylabel('Area Fraction')