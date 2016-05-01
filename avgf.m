function yf=avgf(y,n,w)
    L=length(y); yf(1:n)=0;
    for i=n:L
        sum=0;
        for j=1:n
            sum=sum+w(j)*y(i-n+j);
        end
        yf(i)=sum;
    end
end