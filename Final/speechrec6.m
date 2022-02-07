function [ phrase ] = speechrec6( codeword,phrase,i,words,ep,vcommand )
load diaper
load hunger
load attention


tempa(1) = sum(sum(abs(diaper-codeword)));
tempa(2) = sum(sum(abs(hunger-codeword)));
tempa(3) = sum(sum(abs(attention-codeword)));
 
comp = 999999;

x = 1;
    while x <= 3
        if tempa(x) < comp
        comp = tempa(x);
        ind = x;
        end
            
        x = x+1;
    end
phrase(i) =ind; 

    

   
end





        




