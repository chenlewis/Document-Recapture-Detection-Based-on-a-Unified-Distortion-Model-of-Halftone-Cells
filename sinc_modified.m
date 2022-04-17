function sinc_out = sinc_modified(T,f)
%sinc_modified

for i=1:length(f)
    if f(i)~=0
        sinc_out(i)=sin(pi*T.*f(i))./sin(pi.*f(i));
    else
        sinc_out(i)=T;
    end
end

end

