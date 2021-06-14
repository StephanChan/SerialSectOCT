function[data]=my_smooth_1D(array,kernel)
data=zeros(size(array));
for i=1:length(array)
    data(i)=mean(array(i:min(i+kernel,length(array))));
end