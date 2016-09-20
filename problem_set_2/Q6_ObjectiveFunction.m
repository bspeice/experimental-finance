% Minimize the sum of squared differences between calculated prices and market prices
function Diff = Q6_ObjectiveFunction(call_price, put_price, S0, X, R, T, Steps, Div, ExDivDate, Sig1, Sig2, Sig3, Sig4, Sig5)
    Sig = [Sig1, Sig2, Sig3, Sig4, Sig5];
    if (R > 1 || R < 0 || min(Sig) <= 0)
        Diff = 1e9;
    else
        Diff = 0;
        for i=1:length(call_price)
            [~,C] = binprice(S0,X(i),R,T,T/Steps,Sig(i),1,0,Div,ExDivDate*Steps/T);
            [~,P] = binprice(S0,X(i),R,T,T/Steps,Sig(i),0,0,Div,ExDivDate*Steps/T);
            Diff = Diff + (call_price(i) - C(1))^2 + (put_price(i) - P(1))^2;
        end
    end
end