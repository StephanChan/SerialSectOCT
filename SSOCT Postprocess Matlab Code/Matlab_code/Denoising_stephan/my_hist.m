function[y,x]=my_hist(data,bins)
y=zeros(1,bins);
m=min(data);
M=max(data);
for i=1:bins
    x(i)=m+i*(M-m)/bins;
end
for i=1:length(data)
    v=data(i);
    for j=1:bins
        if v<=x(j)
            y(j)=y(j)+1;
            break
        end
    end
end

        
